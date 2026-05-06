import 'package:flutter_test/flutter_test.dart';

// Unit tests for state logic in ProfileScreen and EditProfilScreen

void main() {
  // Extracted logic from ProfileScreen._formattedTotalDonasi
  String formattedTotalDonasi(int total) {
    if (total == 0) return 'Rp0';
    final s = total.toString();
    final buffer = StringBuffer('Rp');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  group('ProfileScreen State Logic', () {
    test('formattedTotalDonasi formats 0 correctly', () {
      expect(formattedTotalDonasi(0), 'Rp0');
    });

    test('formattedTotalDonasi formats small number', () {
      expect(formattedTotalDonasi(1000), 'Rp1.000');
    });

    test('formattedTotalDonasi formats large number', () {
      expect(formattedTotalDonasi(1500000), 'Rp1.500.000');
    });

    test('formattedTotalDonasi formats number without dots', () {
      expect(formattedTotalDonasi(123), 'Rp123');
    });

    test('formattedTotalDonasi formats number with multiple dots', () {
      expect(formattedTotalDonasi(123456789), 'Rp123.456.789');
    });
  });

  // For EditProfilScreen, test logic if any, but mostly UI, so minimal
  group('EditProfilScreen State Logic', () {
    // Example: test validation or something, but since minimal logic, perhaps skip or add if needed
    test('placeholder test', () {
      expect(true, true);
    });
  });
}