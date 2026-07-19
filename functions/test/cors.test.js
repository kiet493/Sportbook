const http = require("node:http");
const test = require("node:test");
const assert = require("node:assert/strict");

const {vnpayCallableCors} = require("../cors");

function allowsOrigin(origin) {
  return vnpayCallableCors.some((allowed) =>
    typeof allowed === "string" ? allowed === origin : allowed.test(origin));
}

test("VNPay callable allows local Flutter Web origins", () => {
  assert.equal(allowsOrigin("http://localhost"), true);
  assert.equal(allowsOrigin("http://localhost:5173"), true);
  assert.equal(allowsOrigin("http://127.0.0.1:7357"), true);
  assert.equal(allowsOrigin("http://[::1]:8080"), true);
});

test("VNPay callable rejects unrelated browser origins", () => {
  assert.equal(allowsOrigin("https://example.com"), false);
  assert.equal(allowsOrigin("https://sportbook-e74c7.web.app.evil.test"), false);
});

test("createVnpayPayment answers callable preflight for POST", async (t) => {
  const {createVnpayPayment} = require("../index");
  const server = http.createServer(createVnpayPayment);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  t.after(() => new Promise((resolve) => server.close(resolve)));

  const address = server.address();
  const response = await fetch(`http://127.0.0.1:${address.port}`, {
    method: "OPTIONS",
    headers: {
      Origin: "http://localhost:54321",
      "Access-Control-Request-Method": "POST",
      "Access-Control-Request-Headers": "authorization,content-type",
    },
  });

  assert.equal(response.status, 204);
  assert.equal(
    response.headers.get("access-control-allow-origin"),
    "http://localhost:54321",
  );
  assert.equal(response.headers.get("access-control-allow-methods"), "POST");
  assert.match(
    response.headers.get("access-control-allow-headers") ?? "",
    /authorization/i,
  );
});

test("createVnpayPayment reports missing local VNPay variables", async () => {
  const keys = [
    "VNPAY_TMN_CODE",
    "VNPAY_HASH_SECRET",
    "VNPAY_RETURN_URL",
  ];
  const previous = Object.fromEntries(keys.map((key) =>
    [key, process.env[key]]));
  for (const key of keys) process.env[key] = `YOUR_${key}`;

  try {
    const {createVnpayPayment} = require("../index");
    await assert.rejects(
      createVnpayPayment.run({
        auth: {uid: "local-test-user"},
        data: {bookingId: "local-test-booking"},
      }),
      (error) => {
        assert.equal(error.code, "failed-precondition");
        assert.match(error.message, /functions\/\.env/);
        assert.deepEqual(error.details.missing, keys);
        return true;
      },
    );
  } finally {
    for (const key of keys) {
      if (previous[key] === undefined) delete process.env[key];
      else process.env[key] = previous[key];
    }
  }
});
