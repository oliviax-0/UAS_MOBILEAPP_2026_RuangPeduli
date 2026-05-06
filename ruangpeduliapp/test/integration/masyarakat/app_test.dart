// integration_test/app_test.dart
//
// Master runner — imports all integration test groups so they can
// be executed with a single `flutter test integration_test/app_test.dart`
// command (or via `flutter drive`).

import 'package:integration_test/integration_test.dart';

import 'donation_flow_test.dart' as donation;
import 'content_screens_test.dart' as content;
import 'utility_screens_test.dart' as utility;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  donation.main();
  content.main();
  utility.main();
}
