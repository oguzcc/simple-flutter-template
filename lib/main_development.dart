import 'package:daisy/app/app.dart';
import 'package:daisy/app/bootstrap.dart';
import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/config/app_flavor.dart';

Future<void> main() async {
  AppFlavor(
    name: 'Development',
    flavorType: FlavorType.development,
    apiOptions: ApiOption.development(),
  );
  await bootstrap(() => const App());
}
