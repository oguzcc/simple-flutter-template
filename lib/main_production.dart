import 'package:daisy/app/app.dart';
import 'package:daisy/app/bootstrap.dart';
import 'package:daisy/core/config/api_options.dart';
import 'package:daisy/core/config/app_flavor.dart';

Future<void> main() async {
  AppFlavor(
    name: 'Production',
    flavorType: FlavorType.production,
    apiOptions: ApiOption.production(),
  );
  await bootstrap(() => const App());
}
