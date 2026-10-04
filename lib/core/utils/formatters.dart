import 'package:intl/intl.dart';

class Formatters {
  static final _currency = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
  static final _date = DateFormat('MMM d, y • h:mm a');
  static final _shortDate = DateFormat('MMM d');

  static String money(num? v) => _currency.format(v ?? 0);
  static String date(DateTime? d) => d == null ? '-' : _date.format(d);
  static String shortDate(DateTime d) => _shortDate.format(d);
  static String compact(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }
}