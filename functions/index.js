const {initializeApp} = require("firebase-admin/app");
const {
  FieldValue,
  Timestamp,
  getFirestore,
} = require("firebase-admin/firestore");
const {HttpsError, onCall, onRequest} = require("firebase-functions/v2/https");
const {logger} = require("firebase-functions");

const {
  buildVnpayPaymentUrl,
  classifyVnpayResult,
  formatVnpayDate,
  normalizeVnpParams,
  verifyVnpaySignature,
} = require("./vnpay");
const {vnpayCallableCors} = require("./cors");

initializeApp();

const db = getFirestore();
const region = "asia-southeast1";
const sandboxPaymentUrl =
  "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";

const callableFunctionOptions = {
  region,
  // onCall handles OPTIONS automatically and only accepts callable POSTs.
  cors: vnpayCallableCors,
};
const httpFunctionOptions = {
  region,
};

const vnpayEnvKeys = [
  "VNPAY_TMN_CODE",
  "VNPAY_HASH_SECRET",
  "VNPAY_RETURN_URL",
];

function readVnpayConfig() {
  const values = {
    VNPAY_TMN_CODE: String(process.env.VNPAY_TMN_CODE ?? "").trim(),
    VNPAY_HASH_SECRET: String(process.env.VNPAY_HASH_SECRET ?? "").trim(),
    VNPAY_RETURN_URL: String(process.env.VNPAY_RETURN_URL ?? "").trim(),
  };
  const missing = vnpayEnvKeys.filter((key) =>
    !values[key] || values[key].startsWith("YOUR_"));
  return {
    tmnCode: values.VNPAY_TMN_CODE,
    hashSecret: values.VNPAY_HASH_SECRET,
    returnUrl: values.VNPAY_RETURN_URL,
    localReturnUpdatesPayment:
      String(process.env.VNPAY_LOCAL_RETURN_UPDATES_PAYMENT ?? "")
        .trim()
        .toLowerCase() === "true",
    missing,
  };
}

function vnpayConfigErrorMessage(missing) {
  return `Thiếu cấu hình VNPay trong functions/.env: ${missing.join(", ")}.`;
}

function requireVnpayConfig() {
  const config = readVnpayConfig();
  if (config.missing.length > 0) {
    throw new HttpsError(
      "failed-precondition",
      vnpayConfigErrorMessage(config.missing),
      {missing: config.missing},
    );
  }
  return config;
}

function asDate(value) {
  const date = value instanceof Timestamp ? value.toDate() :
    value instanceof Date ? value :
    typeof value === "string" ? new Date(value) : null;
  return date && !Number.isNaN(date.getTime()) ? date : null;
}

function asInteger(value, fallback = 0) {
  return typeof value === "number" && Number.isFinite(value) ?
    Math.round(value) : fallback;
}

function bookingIdsFrom(data) {
  const values = Array.isArray(data?.bookingIds) ?
    data.bookingIds : [data?.bookingId];
  return [...new Set(values
    .map((value) => String(value ?? "").trim())
    .filter(Boolean))];
}

function sameBookingIds(left, right) {
  return left.length === right.length &&
    left.every((bookingId, index) => bookingId === right[index]);
}

function clientIp(request) {
  const forwarded = request.rawRequest.headers["x-forwarded-for"];
  const raw = Array.isArray(forwarded) ? forwarded[0] :
    String(forwarded ?? request.rawRequest.ip ?? "127.0.0.1").split(",")[0];
  return raw.trim().replace(/^::ffff:/, "") || "127.0.0.1";
}

function checkoutData(snapshot) {
  const data = snapshot.data();
  const expiresAt = asDate(data.expiresAt);
  if (!data.paymentUrl || !data.transactionId || !expiresAt) return null;
  return {
    paymentId: snapshot.id,
    transactionId: String(data.transactionId),
    paymentUrl: String(data.paymentUrl),
    amount: asInteger(data.amount),
    discount: asInteger(data.discount),
    couponCode: String(data.couponCode ?? ""),
    expiresAt: expiresAt.toISOString(),
    reused: true,
  };
}

async function createVnpayPayment(request) {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError("unauthenticated", "Vui lòng đăng nhập để thanh toán.");
  }

  const bookingIds = bookingIdsFrom(request.data);
  const bookingId = bookingIds[0] ?? "";
  const couponId = String(request.data?.couponId ?? "").trim();
  if (!bookingId) {
    throw new HttpsError("invalid-argument", "Thiếu mã booking.");
  }
  if (bookingIds.length > 20) {
    throw new HttpsError(
      "invalid-argument",
      "Chỉ có thể thanh toán tối đa 20 booking trong một giao dịch.",
    );
  }

  const {tmnCode, hashSecret, returnUrl} = requireVnpayConfig();
  const now = new Date();
  const expiresAt = new Date(now.getTime() + 15 * 60 * 1000);
  const bookingRefs = bookingIds.map((id) =>
    db.collection("bookings").doc(id));
  const paymentRef = db.collection("payments").doc();
  const transactionRef = db.collection("transactions").doc();
  const couponRef = couponId ? db.collection("coupons").doc(couponId) : null;
  return db.runTransaction(async (transaction) => {
    const bookingSnapshots = [];
    for (const bookingRef of bookingRefs) {
      bookingSnapshots.push(await transaction.get(bookingRef));
    }
    if (bookingSnapshots.some((snapshot) => !snapshot.exists)) {
      throw new HttpsError("not-found", "Có booking không còn tồn tại.");
    }
    const bookings = bookingSnapshots.map((snapshot) => snapshot.data());
    if (bookings.some((booking) => booking.userId !== uid)) {
      throw new HttpsError(
        "permission-denied",
        "Có booking không thuộc tài khoản này.",
      );
    }
    if (bookings.some((booking) => booking.status === "cancelled")) {
      throw new HttpsError("failed-precondition", "Có booking đã bị hủy.");
    }
    if (bookings.some((booking) => booking.paymentStatus === "paid")) {
      throw new HttpsError("already-exists", "Có booking đã được thanh toán.");
    }

    const previousPaymentIds = [...new Set(bookings
      .filter((booking) => booking.paymentStatus === "pending")
      .map((booking) => String(booking.paymentId ?? "").trim())
      .filter(Boolean))];
    const previousPaymentSnapshots = [];
    for (const previousPaymentId of previousPaymentIds) {
      const snapshot = await transaction.get(
        db.collection("payments").doc(previousPaymentId),
      );
      if (snapshot.exists) previousPaymentSnapshots.push(snapshot);
    }
    for (const previousSnapshot of previousPaymentSnapshots) {
      const previous = previousSnapshot.data();
      const previousExpiry = asDate(previous.expiresAt);
      if (previous.status !== "pending" ||
          previousExpiry?.getTime() <= now.getTime()) {
        continue;
      }
      const allBookingsUsePrevious = bookings.every((booking) =>
        booking.paymentStatus === "pending" &&
        String(booking.paymentId ?? "") === previousSnapshot.id);
      if (allBookingsUsePrevious &&
          sameBookingIds(bookingIdsFrom(previous), bookingIds)) {
        const existing = checkoutData(previousSnapshot);
        if (existing) return existing;
      }
      throw new HttpsError(
        "failed-precondition",
        "Một booking đang có giao dịch VNPay chưa hết hạn.",
      );
    }

    const subtotal = bookings.reduce(
      (total, booking) => total + asInteger(booking.totalPrice),
      0,
    );
    if (subtotal <= 0) {
      throw new HttpsError("failed-precondition", "Giá trị booking không hợp lệ.");
    }

    let discount = 0;
    let couponCode = "";
    if (couponRef) {
      const couponSnapshot = await transaction.get(couponRef);
      if (!couponSnapshot.exists) {
        throw new HttpsError("invalid-argument", "Mã giảm giá không tồn tại.");
      }
      const coupon = couponSnapshot.data();
      const couponExpiry = asDate(coupon.expiresAt);
      const valid = coupon.active !== false &&
        subtotal >= asInteger(coupon.minOrder) &&
        (!couponExpiry || couponExpiry.getTime() > now.getTime());
      if (!valid) {
        throw new HttpsError("failed-precondition", "Mã giảm giá không còn hợp lệ.");
      }
      discount = Math.min(
        Math.max(asInteger(coupon.discountAmount), 0),
        subtotal,
      );
      couponCode = String(coupon.code ?? "").trim().toUpperCase();
    }

    const amount = subtotal - discount;
    if (amount < 5000) {
      throw new HttpsError(
        "failed-precondition",
        "VNPay yêu cầu số tiền thanh toán tối thiểu 5.000đ.",
      );
    }

    const params = {
      vnp_Version: "2.1.0",
      vnp_Command: "pay",
      vnp_TmnCode: tmnCode,
      vnp_Amount: String(amount * 100),
      vnp_CreateDate: formatVnpayDate(now),
      vnp_CurrCode: "VND",
      vnp_ExpireDate: formatVnpayDate(expiresAt),
      vnp_IpAddr: clientIp(request),
      vnp_Locale: "vn",
      vnp_OrderInfo: bookingIds.length === 1 ?
        `Thanh toan booking ${bookingId}` :
        `Thanh toan ${bookingIds.length} booking`,
      vnp_OrderType: "other",
      vnp_ReturnUrl: returnUrl,
      vnp_TxnRef: paymentRef.id,
    };
    const paymentUrl = buildVnpayPaymentUrl(
      sandboxPaymentUrl,
      params,
      hashSecret,
    );

    for (const previousSnapshot of previousPaymentSnapshots) {
      if (previousSnapshot.data().status !== "pending") continue;
      transaction.update(previousSnapshot.ref, {
        status: "expired",
        updatedAt: FieldValue.serverTimestamp(),
      });
      const oldTransactionId = String(
        previousSnapshot.data().transactionId ?? "",
      );
      if (oldTransactionId) {
        transaction.update(
          db.collection("transactions").doc(oldTransactionId),
          {
            status: "expired",
            updatedAt: FieldValue.serverTimestamp(),
          },
        );
      }
    }

    const commonData = {
      bookingId,
      bookingIds,
      userId: uid,
      subtotal,
      amount,
      discount,
      couponCode,
      method: "vnpay",
      status: "pending",
      vnpTxnRef: paymentRef.id,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
      expiresAt: Timestamp.fromDate(expiresAt),
    };
    transaction.create(paymentRef, {
      ...commonData,
      _id: paymentRef.id,
      transactionId: transactionRef.id,
      paymentUrl,
      environment: "sandbox",
    });
    transaction.create(transactionRef, {
      ...commonData,
      _id: transactionRef.id,
      paymentId: paymentRef.id,
    });
    for (const bookingRef of bookingRefs) {
      transaction.update(bookingRef, {
        paymentStatus: "pending",
        paymentMethod: "vnpay",
        paymentId: paymentRef.id,
        updatedAt: FieldValue.serverTimestamp(),
      });
    }

    return {
      paymentId: paymentRef.id,
      transactionId: transactionRef.id,
      paymentUrl,
      amount,
      discount,
      couponCode,
      expiresAt: expiresAt.toISOString(),
      reused: false,
    };
  });
}

function checkoutServerError(error) {
  const code = String(error?.code ?? "").replace(/^functions\//, "");
  if (code === "8" || code === "resource-exhausted") {
    return new HttpsError(
      "resource-exhausted",
      "Máy chủ thanh toán đang bận. Vui lòng thử lại sau.",
      {reason: "payment-service-busy"},
    );
  }
  if (code === "10" || code === "aborted") {
    return new HttpsError(
      "aborted",
      "Dữ liệu booking vừa thay đổi. Vui lòng tải lại và thử lại.",
      {reason: "booking-data-changed"},
    );
  }
  if (code === "14" || code === "unavailable") {
    return new HttpsError(
      "unavailable",
      "Không thể kết nối dịch vụ thanh toán. Vui lòng thử lại.",
      {reason: "payment-service-unavailable"},
    );
  }
  return new HttpsError(
    "internal",
    "Không thể khởi tạo thanh toán VNPay. Vui lòng thử lại.",
    {reason: "vnpay-checkout-failed"},
  );
}

exports.createVnpayPayment = onCall(
  callableFunctionOptions,
  async (request) => {
    try {
      return await createVnpayPayment(request);
    } catch (error) {
      if (error instanceof HttpsError) throw error;

      logger.error("createVnpayPayment failed", {
        uid: request.auth?.uid ?? null,
        bookingId: String(request.data?.bookingId ?? ""),
        bookingIds: bookingIdsFrom(request.data),
        code: error?.code ?? null,
        message: error instanceof Error ? error.message : String(error),
        stack: error instanceof Error ? error.stack : null,
      });
      throw checkoutServerError(error);
    }
  },
);

async function applyVnpayResult(params, confirmationSource) {
  const paymentId = String(params.vnp_TxnRef ?? "").trim();
  if (!paymentId) return {outcome: "invalid-data", updated: false};

  const paymentRef = db.collection("payments").doc(paymentId);
  return db.runTransaction(async (transaction) => {
    const paymentSnapshot = await transaction.get(paymentRef);
    if (!paymentSnapshot.exists) {
      return {outcome: "not-found", paymentId, updated: false};
    }

    const payment = paymentSnapshot.data();
    const bookingIds = bookingIdsFrom(payment);
    const bookingId = bookingIds[0] ?? "";
    const transactionId = String(payment.transactionId ?? "").trim();
    const expectedAmount = String(asInteger(payment.amount) * 100);
    if (!params.vnp_Amount || params.vnp_Amount !== expectedAmount) {
      return {
        outcome: "invalid-amount",
        paymentId,
        bookingId,
        updated: false,
      };
    }
    if (!bookingId || !transactionId) {
      return {
        outcome: "invalid-data",
        paymentId,
        bookingId,
        updated: false,
      };
    }

    if (payment.status === "paid") {
      return {
        outcome: "paid",
        paymentId,
        bookingId,
        updated: false,
      };
    }

    const nextStatus = classifyVnpayResult(params);
    if (nextStatus !== "paid" && payment.status !== "pending") {
      return {
        outcome: String(payment.status ?? nextStatus),
        paymentId,
        bookingId,
        updated: false,
      };
    }

    const bookingRefs = bookingIds.map((id) =>
      db.collection("bookings").doc(id));
    const transactionRef = db.collection("transactions").doc(transactionId);
    const bookingSnapshots = [];
    for (const bookingRef of bookingRefs) {
      bookingSnapshots.push(await transaction.get(bookingRef));
    }
    const transactionSnapshot = await transaction.get(transactionRef);
    if (bookingSnapshots.some((snapshot) => !snapshot.exists) ||
        !transactionSnapshot.exists) {
      return {
        outcome: "invalid-data",
        paymentId,
        bookingId,
        updated: false,
      };
    }

    const bookings = bookingSnapshots.map((snapshot) => snapshot.data());
    if (bookings.some((booking) =>
      String(booking.paymentId ?? "") !== paymentId)) {
      return {
        outcome: "booking-mismatch",
        paymentId,
        bookingId,
        updated: false,
      };
    }

    const serverTime = FieldValue.serverTimestamp();
    const gatewayData = {
      status: nextStatus,
      vnpTransactionNo: String(params.vnp_TransactionNo ?? ""),
      vnpResponseCode: String(params.vnp_ResponseCode ?? ""),
      vnpTransactionStatus: String(params.vnp_TransactionStatus ?? ""),
      bankCode: String(params.vnp_BankCode ?? ""),
      vnpBankCode: String(params.vnp_BankCode ?? ""),
      vnpPayDate: String(params.vnp_PayDate ?? ""),
      confirmationSource,
      confirmedAt: serverTime,
      updatedAt: serverTime,
    };
    if (nextStatus === "paid") {
      gatewayData.paidAt = serverTime;
    } else if (nextStatus === "cancelled") {
      gatewayData.cancelledAt = serverTime;
    } else {
      gatewayData.failedAt = serverTime;
    }

    transaction.update(paymentRef, gatewayData);
    transaction.update(transactionRef, gatewayData);
    if (nextStatus === "paid") {
      for (let index = 0; index < bookingRefs.length; index++) {
        const booking = bookings[index];
        const terminalStatus = booking.status === "cancelled" ||
          booking.status === "completed";
        transaction.update(bookingRefs[index], {
          paymentStatus: "paid",
          paymentMethod: "vnpay",
          status: terminalStatus ? booking.status : "booked",
          paidAt: serverTime,
          updatedAt: serverTime,
        });
      }
    } else {
      for (let index = 0; index < bookingRefs.length; index++) {
        if (bookings[index].paymentStatus === "paid") continue;
        transaction.update(bookingRefs[index], {
          paymentStatus: "unpaid",
          paymentMethod: "vnpay",
          paymentId: FieldValue.delete(),
          updatedAt: serverTime,
        });
      }
    }

    return {
      outcome: nextStatus,
      paymentId,
      bookingId,
      updated: true,
    };
  });
}

function sendVnpayReturnPage(response, options) {
  const escapeHtml = (value) => String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
  const successful = options.status === "paid";
  const color = successful ? "#16a34a" : "#dc2626";
  const title = escapeHtml(options.title);
  const detail = escapeHtml(options.detail);
  const payload = successful && options.paymentId && options.bookingId ? {
    type: "VNPAY_PAYMENT_RESULT",
    status: "paid",
    paymentId: options.paymentId,
    bookingId: options.bookingId,
  } : null;
  const payloadJson = JSON.stringify(payload).replace(/</g, "\\u003c");
  const autoClose = successful ?
    "setTimeout(() => window.close(), 2500);" : "";

  response.status(options.httpStatus ?? 200).type("html").send(`<!doctype html>
<html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${title}</title><style>body{font-family:Arial,sans-serif;background:#f8fafc;margin:0;display:grid;place-items:center;min-height:100vh;color:#0f172a}.card{background:#fff;max-width:440px;margin:20px;padding:32px;border-radius:20px;box-shadow:0 12px 35px #0f172a1f;text-align:center}.icon{font-size:54px;color:${color}}h1{font-size:24px}p{color:#475569;line-height:1.6}button{border:0;border-radius:12px;background:#2563eb;color:#fff;padding:13px 22px;font-weight:700;cursor:pointer}</style></head>
<body><main class="card"><div class="icon">${successful ? "✓" : "!"}</div><h1>${title}</h1><p>${detail}</p><p>Quay lại ứng dụng SportBook để xem trạng thái đơn đặt sân.</p><button onclick="window.close()">Đóng trang</button></main><script>const result=${payloadJson};if(result){try{window.opener?.postMessage(result,"*");}catch(_){ }${autoClose}}</script></body></html>`);
}

exports.vnpayIpn = onRequest(httpFunctionOptions, async (request, response) => {
  const config = readVnpayConfig();
  if (config.missing.length > 0) {
    response.status(503).json({
      RspCode: "99",
      Message: vnpayConfigErrorMessage(config.missing),
    });
    return;
  }

  const params = normalizeVnpParams(request.query);
  const receivedHash = String(request.query.vnp_SecureHash ?? "");
  const source = {...params, vnp_SecureHash: receivedHash};

  if (!verifyVnpaySignature(source, config.hashSecret)) {
    response.status(200).json({RspCode: "97", Message: "Invalid signature"});
    return;
  }
  if (params.vnp_TmnCode !== config.tmnCode) {
    response.status(200).json({RspCode: "97", Message: "Invalid TmnCode"});
    return;
  }

  try {
    const result = await applyVnpayResult(params, "ipn");
    if (result.outcome === "not-found") {
      response.status(200).json({RspCode: "01", Message: "Order not found"});
    } else if (result.outcome === "invalid-amount") {
      response.status(200).json({RspCode: "04", Message: "Invalid amount"});
    } else if (!result.updated) {
      response.status(200).json({RspCode: "02", Message: "Order already confirmed"});
    } else {
      response.status(200).json({RspCode: "00", Message: "Confirm success"});
    }
  } catch (error) {
    logger.error("VNPay IPN processing failed", error);
    response.status(200).json({RspCode: "99", Message: "Unknown error"});
  }
});

exports.vnpayReturn = onRequest(httpFunctionOptions, async (request, response) => {
  const config = readVnpayConfig();
  if (config.missing.length > 0) {
    const message = vnpayConfigErrorMessage(config.missing);
    response.status(503).type("html").send(`<!doctype html>
<html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Thiếu cấu hình VNPay</title></head><body><main><h1>Thiếu cấu hình VNPay</h1><p>${message}</p></main></body></html>`);
    return;
  }

  const params = normalizeVnpParams(request.query);
  const source = {
    ...params,
    vnp_SecureHash: String(request.query.vnp_SecureHash ?? ""),
  };
  const valid = verifyVnpaySignature(source, config.hashSecret) &&
    params.vnp_TmnCode === config.tmnCode;
  if (!valid) {
    sendVnpayReturnPage(response, {
      status: "failed",
      title: "Phản hồi VNPay không hợp lệ",
      detail: "Chữ ký hoặc mã website trong phản hồi không hợp lệ.",
      httpStatus: 400,
    });
    return;
  }

  const gatewayStatus = classifyVnpayResult(params);
  if (!config.localReturnUpdatesPayment) {
    const responseCode = params.vnp_ResponseCode || "Không xác định";
    sendVnpayReturnPage(response, gatewayStatus === "paid" ? {
      status: "paid-pending-ipn",
      title: "Đã nhận kết quả thanh toán",
      detail: "Giao dịch hợp lệ và đang chờ VNPay IPN xác nhận.",
    } : {
      status: gatewayStatus,
      title: gatewayStatus === "cancelled" ?
        "Thanh toán đã bị hủy" : "Thanh toán chưa thành công",
      detail: `Mã phản hồi VNPay: ${responseCode}`,
    });
    return;
  }

  try {
    const result = await applyVnpayResult(params, "return-local");
    if (result.outcome === "paid") {
      sendVnpayReturnPage(response, {
        status: "paid",
        title: "Thanh toán thành công",
        detail: "Thanh toán thành công. Trạng thái đơn đặt sân đã được cập nhật.",
        paymentId: result.paymentId,
        bookingId: result.bookingId,
      });
      return;
    }
    if (result.outcome === "cancelled" || result.outcome === "failed") {
      sendVnpayReturnPage(response, {
        status: result.outcome,
        title: result.outcome === "cancelled" ?
          "Thanh toán đã bị hủy" : "Thanh toán chưa thành công",
        detail: result.outcome === "cancelled" ?
          "Bạn đã hủy giao dịch VNPay." :
          `Mã phản hồi VNPay: ${params.vnp_ResponseCode || "Không xác định"}`,
      });
      return;
    }

    const detail = result.outcome === "invalid-amount" ?
      "Số tiền VNPay trả về không khớp với đơn thanh toán." :
      result.outcome === "not-found" ?
        "Không tìm thấy đơn thanh toán tương ứng." :
        "Không thể cập nhật đơn thanh toán từ phản hồi này.";
    sendVnpayReturnPage(response, {
      status: "failed",
      title: "Không thể xác nhận thanh toán",
      detail,
      httpStatus: 400,
    });
  } catch (error) {
    logger.error("VNPay local return processing failed", {
      paymentId: String(params.vnp_TxnRef ?? ""),
      message: error instanceof Error ? error.message : String(error),
      stack: error instanceof Error ? error.stack : null,
    });
    sendVnpayReturnPage(response, {
      status: "failed",
      title: "Không thể cập nhật thanh toán",
      detail: "Máy chủ local gặp lỗi khi cập nhật trạng thái. Vui lòng thử kiểm tra lại.",
      httpStatus: 500,
    });
  }
});
