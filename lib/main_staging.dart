import 'package:daisy/app/app.dart';
import 'package:daisy/app/bootstrap.dart';
import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/config/app_flavor.dart';

Future<void> main() async {
  AppFlavor(
    name: 'Staging',
    flavorType: FlavorType.staging,
    apiOptions: ApiOption.staging(),
  );
  await bootstrap(() => const App());
}
