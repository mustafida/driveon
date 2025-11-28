// lib/utils/format_price.dart

String formatPrice(int price) {
  final s = price.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    buffer.write(s[i]);
    final posFromRight = s.length - i - 1;
    if (posFromRight % 3 == 0 && posFromRight != 0) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}
