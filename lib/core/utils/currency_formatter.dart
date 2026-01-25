import 'package:intl/intl.dart';

class CurrencyFormatter {
  static NumberFormat get rupiah {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
  }

  static String format(int amount) {
    return rupiah.format(amount);
  }
}
