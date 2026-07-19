const crypto = require("node:crypto");

function normalizeVnpParams(input) {
  const params = {};
  for (const [key, rawValue] of Object.entries(input ?? {})) {
    if (!key.startsWith("vnp_") ||
        key === "vnp_SecureHash" ||
        key === "vnp_SecureHashType" ||
        rawValue == null) {
      continue;
    }
    const value = Array.isArray(rawValue) ? rawValue[0] : rawValue;
    if (typeof value === "object") continue;
    params[key] = String(value);
  }
  return params;
}

function sortedQuery(params) {
  const query = new URLSearchParams();
  for (const key of Object.keys(params).sort()) {
    const value = params[key];
    if (value != null && String(value).length > 0) {
      query.append(key, String(value));
    }
  }
  return query.toString();
}

function signVnpParams(params, hashSecret) {
  return crypto
    .createHmac("sha512", hashSecret)
    .update(sortedQuery(normalizeVnpParams(params)), "utf8")
    .digest("hex");
}

function buildVnpayPaymentUrl(baseUrl, params, hashSecret) {
  const normalized = normalizeVnpParams(params);
  const query = sortedQuery(normalized);
  const signature = signVnpParams(normalized, hashSecret);
  return `${baseUrl}?${query}&vnp_SecureHash=${signature}`;
}

function verifyVnpaySignature(input, hashSecret) {
  const received = String(input?.vnp_SecureHash ?? "").toLowerCase();
  if (!/^[a-f0-9]{128}$/.test(received)) return false;
  const expected = signVnpParams(input, hashSecret);
  return crypto.timingSafeEqual(
    Buffer.from(received, "hex"),
    Buffer.from(expected, "hex"),
  );
}

function classifyVnpayResult(params) {
  if (params?.vnp_ResponseCode === "00" &&
      params?.vnp_TransactionStatus === "00") {
    return "paid";
  }
  return params?.vnp_ResponseCode === "24" ? "cancelled" : "failed";
}

function formatVnpayDate(date) {
  const vietnamTime = new Date(date.getTime() + 7 * 60 * 60 * 1000);
  const pad = (value) => String(value).padStart(2, "0");
  return `${vietnamTime.getUTCFullYear()}` +
    `${pad(vietnamTime.getUTCMonth() + 1)}` +
    `${pad(vietnamTime.getUTCDate())}` +
    `${pad(vietnamTime.getUTCHours())}` +
    `${pad(vietnamTime.getUTCMinutes())}` +
    `${pad(vietnamTime.getUTCSeconds())}`;
}

module.exports = {
  buildVnpayPaymentUrl,
  classifyVnpayResult,
  formatVnpayDate,
  normalizeVnpParams,
  signVnpParams,
  sortedQuery,
  verifyVnpaySignature,
};
