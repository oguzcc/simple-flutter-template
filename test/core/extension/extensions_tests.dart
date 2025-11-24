import 'package:daisy/core/config/core_strings.dart';
import 'package:daisy/core/extension/date_time_extension.dart';
import 'package:daisy/core/extension/string_extension.dart';
import 'package:daisy/core/extension/validation_extension.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_test/flutter_test.dart';

part '_tests/_date_time_extension.dart';
part '_tests/_duration_extension.dart';
part '_tests/_string_extension.dart';
part '_tests/_validation_extension.dart';

void main() {
  group('Core Extension Tests', () {
    _dateTimeExtensionTest(); // Tüm date time testlerini çağır
    _durationTests(); // Tüm duration testlerini çağır
    _stringTests(); // Tüm string testlerini çağır
    _validationTests(); // Tüm validation testlerini çağır
  });
}
