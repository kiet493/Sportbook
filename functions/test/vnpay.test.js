const test = require("node:test");
const assert = require("node:assert/strict");

const {
  buildVnpayPaymentUrl,
  classifyVnpayResult,
  formatVnpayDate,
  signVnpParams,
  verifyVnpaySignature,
} = require("../vnpay");

test("VNPay result is paid only when both response statuses are 00", () => {
  assert.equal(classifyVnpayResult({
    vnp_ResponseCode: "00",
    vnp_TransactionStatus: "00",
  }), "paid");
  assert.equal(classifyVnpayResult({
    vnp_ResponseCode: "00",
    vnp_TransactionStatus: "01",
  }), "failed");
  assert.equal(classifyVnpayResult({
    vnp_ResponseCode: "24",
    vnp_TransactionStatus: "02",
  }), "cancelled");
});

test("VNPay parameters are signed in alphabetic order", () => {
  const secret = "sandbox-secret";
  const first = signVnpParams({vnp_TxnRef: "abc", vnp_Amount: "500000"}, secret);
  const second = signVnpParams({vnp_Amount: "500000", vnp_TxnRef: "abc"}, secret);
  assert.equal(first, second);
});

test("VNPay signature rejects tampered payment data", () => {
  const secret = "sandbox-secret";
  const params = {vnp_Amount: "500000", vnp_TxnRef: "payment-1"};
  const signature = signVnpParams(params, secret);
  assert.equal(
    verifyVnpaySignature({...params, vnp_SecureHash: signature}, secret),
    true,
  );
  assert.equal(
    verifyVnpaySignature({...params, vnp_Amount: "600000", vnp_SecureHash: signature}, secret),
    false,
  );
});

test("payment URL includes HMACSHA512 signature and GMT+7 date", () => {
  const url = buildVnpayPaymentUrl(
    "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html",
    {vnp_OrderInfo: "Thanh toan booking 1", vnp_Amount: "500000"},
    "sandbox-secret",
  );
  assert.match(url, /vnp_OrderInfo=Thanh\+toan\+booking\+1/);
  assert.match(url, /vnp_SecureHash=[a-f0-9]{128}$/);
  assert.equal(formatVnpayDate(new Date("2026-07-19T00:00:00.000Z")), "20260719070000");
});
