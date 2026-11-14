import 'dart:ui' show Locale;

import 'package:flutter_test/flutter_test.dart';

import 'package:daftari/core/money/format_money.dart';
import 'package:daftari/core/money/money.dart';

void main() {
  group('Money', () {
    test('stores the signed piasters value it is constructed with', () {
      expect(const Money.fromPiasters(125000).asPiasters, 125000);
      expect(const Money.fromPiasters(-250).asPiasters, -250);
      expect(const Money.fromPiasters(0).asPiasters, 0);
    });

    test('adds amounts with integer math', () {
      const a = Money.fromPiasters(125000);
      const b = Money.fromPiasters(250);

      expect(a + b, const Money.fromPiasters(125250));
    });

    test('subtracts amounts with integer math', () {
      const a = Money.fromPiasters(125000);
      const b = Money.fromPiasters(250);

      expect(a - b, const Money.fromPiasters(124750));
    });

    test('subtracting more than the amount goes negative', () {
      const a = Money.fromPiasters(100);
      const b = Money.fromPiasters(250);

      expect(a - b, const Money.fromPiasters(-150));
    });

    test('negate flips the sign', () {
      expect(
        const Money.fromPiasters(1250).negate(),
        const Money.fromPiasters(-1250),
      );
      expect(
        const Money.fromPiasters(-1250).negate(),
        const Money.fromPiasters(1250),
      );
      expect(const Money.fromPiasters(0).negate(), const Money.fromPiasters(0));
    });

    test('amounts with the same value are equal', () {
      expect(const Money.fromPiasters(1250), const Money.fromPiasters(1250));
      expect(
        const Money.fromPiasters(1250).hashCode,
        const Money.fromPiasters(1250).hashCode,
      );
      expect(
        const Money.fromPiasters(1250),
        isNot(const Money.fromPiasters(1251)),
      );
    });

    test('compares by signed value', () {
      expect(
        const Money.fromPiasters(-1) < const Money.fromPiasters(0),
        isTrue,
      );
      expect(const Money.fromPiasters(0) < const Money.fromPiasters(1), isTrue);
      expect(
        const Money.fromPiasters(100) > const Money.fromPiasters(99),
        isTrue,
      );
      expect(
        const Money.fromPiasters(-100) > const Money.fromPiasters(-200),
        isTrue,
      );
      expect(
        const Money.fromPiasters(100) <= const Money.fromPiasters(100),
        isTrue,
      );
      expect(
        const Money.fromPiasters(100) >= const Money.fromPiasters(100),
        isTrue,
      );
    });
  });

  group('formatMoney', () {
    test('formats whole pounds with grouping and the Arabic suffix', () {
      expect(
        formatMoney(const Money.fromPiasters(125000), const Locale('ar')),
        '1,250 ج.م',
      );
    });

    test('formats whole pounds with grouping and the English suffix', () {
      expect(
        formatMoney(const Money.fromPiasters(125000), const Locale('en')),
        '1,250 EGP',
      );
    });

    test('keeps Western digits in Arabic', () {
      final formatted = formatMoney(
        const Money.fromPiasters(125000),
        const Locale('ar'),
      );

      expect(formatted, startsWith('1,250'));
      expect(formatted.contains(RegExp(r'[\u0660-\u0669]')), isFalse);
    });

    test('formats piasters as a two-digit fraction', () {
      expect(
        formatMoney(const Money.fromPiasters(125050), const Locale('ar')),
        '1,250.50 ج.م',
      );
      expect(
        formatMoney(const Money.fromPiasters(125005), const Locale('en')),
        '1,250.05 EGP',
      );
    });

    test('formats negative amounts with a leading minus', () {
      expect(
        formatMoney(const Money.fromPiasters(-125050), const Locale('ar')),
        '-1,250.50 ج.م',
      );
      expect(
        formatMoney(const Money.fromPiasters(-125000), const Locale('en')),
        '-1,250 EGP',
      );
    });

    test('formats zero without a fraction', () {
      expect(
        formatMoney(const Money.fromPiasters(0), const Locale('ar')),
        '0 ج.م',
      );
      expect(
        formatMoney(const Money.fromPiasters(0), const Locale('en')),
        '0 EGP',
      );
    });
  });

  group('formatMoneyAmount', () {
    test('renders the number only, without a currency suffix', () {
      expect(formatMoneyAmount(const Money.fromPiasters(125000)), '1,250');
      expect(formatMoneyAmount(const Money.fromPiasters(125050)), '1,250.50');
      expect(formatMoneyAmount(const Money.fromPiasters(-125050)), '-1,250.50');
      expect(formatMoneyAmount(const Money.fromPiasters(0)), '0');
    });
  });
}
