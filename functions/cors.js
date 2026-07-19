const vnpayCallableCors = Object.freeze([
  /^http:\/\/localhost(?::\d+)?$/,
  /^http:\/\/127\.0\.0\.1(?::\d+)?$/,
  /^http:\/\/\[::1\](?::\d+)?$/,
  "https://sportbook-e74c7.web.app",
  "https://sportbook-e74c7.firebaseapp.com",
]);

module.exports = {vnpayCallableCors};
