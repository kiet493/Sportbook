/// Format an integer as a Vietnamese thousand-separated string.
///
/// Example: 1500000 -> "1.500.000".
String formatVnd(int num) {
  final str = num.toString();
  if (str.length <= 3) return str;

  final buffer = StringBuffer();
  var count = 0;
  for (var i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    count++;
    if (count == 3 && i != 0) {
      buffer.write('.');
      count = 0;
    }
  }
  return buffer.toString().split('').reversed.join();
}
