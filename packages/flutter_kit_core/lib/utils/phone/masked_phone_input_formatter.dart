import 'package:flutter/services.dart';

/// Lays [digits] into a `#`-slot [pattern], stopping as soon as the digits run
/// out so no trailing separator is left dangling.
///
/// ```dart
/// maskPhoneDigits('5551234567', '### ### ## ##'); // 555 123 45 67
/// maskPhoneDigits('5551234567', '(###) ###-####'); // (555) 123-4567
/// maskPhoneDigits('555', '### ### ## ##'); // 555   — not '555 '
/// ```
String maskPhoneDigits(String digits, String pattern) {
  final buffer = StringBuffer();
  var index = 0;
  for (final char in pattern.split('')) {
    if (index >= digits.length) break;
    if (char == '#') {
      buffer.write(digits[index]);
      index++;
    } else {
      buffer.write(char);
    }
  }
  return buffer.toString();
}

/// Formats a national phone number against a `#`-slot mask as it is typed.
///
/// The mask is per-country, so the field rebuilds this formatter whenever the
/// selected country changes.
///
/// International input (`+90…`, `0090…`) is deliberately passed through
/// untouched: it names a country that may not be the one [pattern] belongs to,
/// and truncating it here would destroy the dial code before anything had a
/// chance to read it. Resolving that is the caller's job — the screen parses
/// the pasted value, switches country, and writes back the national part.
class MaskedPhoneInputFormatter extends TextInputFormatter {
  MaskedPhoneInputFormatter({required this.pattern, this.trunkPrefix});

  /// National number mask, e.g. `### ### ## ##`.
  final String pattern;

  /// Domestic dialling prefix to drop — the `0` a Turkish user types in
  /// `0555…`. Null leaves a leading zero alone.
  final String? trunkPrefix;

  late final int _maxDigits = '#'.allMatches(pattern).length;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('+') || newValue.text.startsWith('00')) {
      return newValue;
    }

    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    final trunk = trunkPrefix;
    if (trunk != null && digits.startsWith(trunk)) {
      digits = digits.substring(trunk.length);
    }

    if (digits.length > _maxDigits) digits = digits.substring(0, _maxDigits);

    final formatted = maskPhoneDigits(digits, pattern);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
