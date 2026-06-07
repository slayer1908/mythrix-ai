import 'package:intl/intl.dart';

/// Number / currency / date formatters used across the app.
class Fmt {
  Fmt._();

  static final _compact = NumberFormat.compact();
  static final _decimal = NumberFormat('#,###');
  static final _percent = NumberFormat.percentPattern()..maximumFractionDigits = 1;
  static final _usd = NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2);
  static final _date = DateFormat('MMM d, yyyy');
  static final _dateTime = DateFormat('MMM d • h:mm a');
  static final _time = DateFormat('h:mm a');

  static String compact(num n) => _compact.format(n);
  static String decimal(num n) => _decimal.format(n);
  static String percent(num n) => _percent.format(n);
  static String money(num n, {String? code}) =>
      code == null ? _usd.format(n) : NumberFormat.simpleCurrency(name: code).format(n);

  static String date(DateTime d) => _date.format(d);
  static String dateTime(DateTime d) => _dateTime.format(d);
  static String time(DateTime d) => _time.format(d);

  static String relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _date.format(d);
  }

  static String signed(num n, {int decimals = 1}) {
    final s = n.toStringAsFixed(decimals);
    return n >= 0 ? '+$s' : s;
  }
}
