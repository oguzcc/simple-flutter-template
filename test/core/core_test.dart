import 'package:flutter_test/flutter_test.dart';

import 'extension/extensions_tests.dart' as extension_test;
import 'manager/manager_test.dart' as manager_test;
import 'network/network_tests.dart' as network_test;

void main() {
  group('Core  Tests', () {
    network_test.main();
    extension_test.main();
    manager_test.main();
  });
}
