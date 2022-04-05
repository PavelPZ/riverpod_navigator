import 'dart:async';
import 'dart:typed_data';

class HttpDateException implements Exception {
  HttpDateException(this._msg);
  final String _msg;
  @override
  String toString() => _msg;
}

/// Utility functions for working with dates with HTTP specific date
/// formats.
class HttpDate {
  HttpDate._();
  // From RFC-2616 section '3.3.1 Full Date',
  // http://tools.ietf.org/html/rfc2616#section-3.3.1
  //
  // HTTP-date    = rfc1123-date | rfc850-date | asctime-date
  // rfc1123-date = wkday ',' SP date1 SP time SP 'GMT'
  // rfc850-date  = weekday ',' SP date2 SP time SP 'GMT'
  // asctime-date = wkday SP date3 SP time SP 4DIGIT
  // date1        = 2DIGIT SP month SP 4DIGIT
  //                ; day month year (e.g., 02 Jun 1982)
  // date2        = 2DIGIT '-' month '-' 2DIGIT
  //                ; day-month-year (e.g., 02-Jun-82)
  // date3        = month SP ( 2DIGIT | ( SP 1DIGIT ))
  //                ; month day (e.g., Jun  2)
  // time         = 2DIGIT ':' 2DIGIT ':' 2DIGIT
  //                ; 00:00:00 - 23:59:59
  // wkday        = 'Mon' | 'Tue' | 'Wed'
  //              | 'Thu' | 'Fri' | 'Sat' | 'Sun'
  // weekday      = 'Monday' | 'Tuesday' | 'Wednesday'
  //              | 'Thursday' | 'Friday' | 'Saturday' | 'Sunday'
  // month        = 'Jan' | 'Feb' | 'Mar' | 'Apr'
  //              | 'May' | 'Jun' | 'Jul' | 'Aug'
  //              | 'Sep' | 'Oct' | 'Nov' | 'Dec'

  /// Format a date according to
  /// [RFC-1123](http://tools.ietf.org/html/rfc1123 'RFC-1123'),
  /// e.g. `Thu, 1 Jan 1970 00:00:00 GMT`.
  static String format(DateTime date) {
    const List wkday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const List month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    final DateTime d = date.toUtc();
    final StringBuffer sb = StringBuffer()
      ..write(wkday[d.weekday - 1])
      ..write(', ')
      ..write(d.day <= 9 ? '0' : '')
      ..write(d.day.toString())
      ..write(' ')
      ..write(month[d.month - 1])
      ..write(' ')
      ..write(d.year.toString())
      ..write(d.hour <= 9 ? ' 0' : ' ')
      ..write(d.hour.toString())
      ..write(d.minute <= 9 ? ':0' : ':')
      ..write(d.minute.toString())
      ..write(d.second <= 9 ? ':0' : ':')
      ..write(d.second.toString())
      ..write(' GMT');
    return sb.toString();
  }

  /// Parse a date string in either of the formats
  /// [RFC-1123](http://tools.ietf.org/html/rfc1123 'RFC-1123'),
  /// [RFC-850](http://tools.ietf.org/html/rfc850 'RFC-850') or
  /// ANSI C's asctime() format. These formats are listed here.
  ///
  ///     Thu, 1 Jan 1970 00:00:00 GMT
  ///     Thursday, 1-Jan-1970 00:00:00 GMT
  ///     Thu Jan  1 00:00:00 1970
  ///
  /// For more information see
  /// [RFC-2616 section 3.1.1](https://tools.ietf.org/html/rfc2616#section-3.3.1).
  static DateTime parse(String date) {
    const int SP = 32;
    const List wkdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const List weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const List months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    const int formatRfc1123 = 0;
    const int formatRfc850 = 1;
    const int formatAsctime = 2;

    int index = 0;
    String tmp;
    int? format;

    void expect(String s) {
      if (date.length - index < s.length) {
        throw HttpDateException('Invalid HTTP date $date');
      }
      final String tmp = date.substring(index, index + s.length);
      if (tmp != s) {
        throw HttpDateException('Invalid HTTP date $date');
      }
      index += s.length;
    }

    int expectWeekday() {
      int weekday;
      // The formatting of the weekday signals the format of the date string.
      final int pos = date.indexOf(',', index);
      if (pos == -1) {
        final int pos = date.indexOf(' ', index);
        if (pos == -1) throw HttpDateException('Invalid HTTP date $date');
        tmp = date.substring(index, pos);
        index = pos + 1;
        weekday = wkdays.indexOf(tmp);
        if (weekday != -1) {
          format = formatAsctime;
          return weekday;
        }
      } else {
        tmp = date.substring(index, pos);
        index = pos + 1;
        weekday = wkdays.indexOf(tmp);
        if (weekday != -1) {
          format = formatRfc1123;
          return weekday;
        }
        weekday = weekdays.indexOf(tmp);
        if (weekday != -1) {
          format = formatRfc850;
          return weekday;
        }
      }
      throw HttpDateException('Invalid HTTP date $date');
    }

    int expectMonth(String separator) {
      final int pos = date.indexOf(separator, index);
      if (pos - index != 3) throw HttpDateException('Invalid HTTP date $date');
      tmp = date.substring(index, pos);
      index = pos + 1;
      final int month = months.indexOf(tmp);
      if (month != -1) return month;
      throw HttpDateException('Invalid HTTP date $date');
    }

    int expectNum(String separator) {
      int pos;
      if (separator.isNotEmpty) {
        pos = date.indexOf(separator, index);
      } else {
        pos = date.length;
      }
      final String tmp = date.substring(index, pos);
      index = pos + separator.length;
      try {
        final int value = int.parse(tmp);
        return value;
      } on FormatException {
        throw HttpDateException('Invalid HTTP date $date');
      }
    }

    void expectEnd() {
      if (index != date.length) {
        throw HttpDateException('Invalid HTTP date $date');
      }
    }

    expectWeekday();
    int day;
    int month;
    int year;
    int hours;
    int minutes;
    int seconds;
    if (format == formatAsctime) {
      month = expectMonth(' ');
      if (date.codeUnitAt(index) == SP) index++;
      day = expectNum(' ');
      hours = expectNum(':');
      minutes = expectNum(':');
      seconds = expectNum(' ');
      year = expectNum('');
    } else {
      expect(' ');
      day = expectNum(format == formatRfc1123 ? ' ' : '-');
      month = expectMonth(format == formatRfc1123 ? ' ' : '-');
      year = expectNum(' ');
      hours = expectNum(':');
      minutes = expectNum(':');
      seconds = expectNum(' ');
      expect('GMT');
    }
    expectEnd();
    return DateTime.utc(year, month + 1, day, hours, minutes, seconds, 0);
  }
}

class Day {
  Day._();
  static int get now => epochDifference(null);
  static int get nowSec => dateNow(null).difference(epoch).inSeconds;
  static int get nowSecUtc => dateNow(null).toUtc().difference(epoch).inSeconds;
  static int get nowMilisec => dateNow(null).difference(epoch).inMilliseconds;
  static Duration tillMidnight() {
    final nowDate = dateNow(null);
    final nextDay = DateTime(nowDate.year, nowDate.month, nowDate.day + 1);
    return nextDay.difference(nowDate);
  }

  static int get nowEx => getNowEx != null ? getNowEx!() : now;
  static int Function()? getNowEx;

  static const DAYSECS = 3600 * 24;
  static final epoch = DateTime(2020);

  static DateTime? _nowMock;
  static void mockSet(int? day) => _nowMock = day == null ? null : toDate(day);
  static void mockNow(DateTime now) => _nowMock = now;

  static DateTime dateNow([DateTime? date]) {
    assert((() {
      date ??= _nowMock;
      return true;
    })());
    return date ?? DateTime.now();
  }

  static int epochDifference(DateTime? date) => dateNow(date).difference(epoch).inDays;
  static int epochDifferenceSec([DateTime? date]) => dateNow(date).difference(epoch).inSeconds;

  static Duration toDuration([int? day]) => Duration(days: day ?? now);
  static DateTime toDate([int? day]) => epoch.add(toDuration(day));
}

abstract class IFileCommon {
  // Future<bool> platformExists();
  // Future platformWriteBytes(List<int> bytes);
  // Future<Uint8List> platformReadBytes();
  Future platformDelete();
  // message file operations
  Future platformAppend(List<int> bytes);
  Future platformAppends(Iterable<Uint8List> bytess, {bool recreate});
  Stream<Uint8List> platformReads();
}
