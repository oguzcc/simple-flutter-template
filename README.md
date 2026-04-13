# daisy

Üretim-hazır Flutter başlangıç şablonu. Clean Architecture + BLoC, çoklu flavor, Firebase ekosistemi, sosyal login, RevenueCat, lokalizasyon ve temel güvenlik/UX iyileştirmeleri ile gelir.

## Mimari

```
lib/
├── app/                  # App bootstrap, providers, listeners, locator (DI)
│   └── bootstrap/mixins/ # Firebase / analytics / environment / system UI init
├── core/                 # Paylaşılan altyapı
│   ├── analytics/        # Firebase Analytics wrapper
│   ├── bloc/             # Global state (conn, lang, settings, theme)
│   ├── config/           # App flavor, API options, auth/purchase config
│   ├── extension/        # Dart extension'ları (string, context, datetime, …)
│   ├── manager/          # Firebase, remote (Dio + interceptors), local services,
│   │                     # notifications, purchase, validation
│   ├── mixin/            # Paylaşılan mixin'ler (image picker, …)
│   ├── style/            # Material 3 tema + input/button alt temaları
│   ├── types/            # AppException hiyerarşisi + typedef'ler
│   └── util/             # Yardımcılar (regex, …)
├── data/                 # Veri katmanı
│   ├── dto/              # Request DTO'ları
│   ├── model/            # Domain modelleri (Equatable tabanlı)
│   ├── repo/             # Repository interface + impl
│   ├── service/          # Auth service (fpdart Either)
│   └── notification/     # Bildirim action modelleri + queue manager
├── feature/              # Feature-first sunum katmanı
│   ├── auth/             # Social login (Apple/Google/Anonymous)
│   ├── home/             # Örnek CRUD (tag)
│   ├── profile/          # Profil + logout
│   ├── purchase/         # RevenueCat native paywall wrapper
│   └── splash/           # Açılış ekranı
├── router/               # GoRouter (StatefulShellRoute + bottom nav)
├── localization/         # Generated locale keys
├── ui/                   # Yeniden kullanılabilir widget'lar (button, input,
│                         # gap, card, picker, modal, vs.)
├── firebase_options.dart # flutterfire configure çıktısı
└── main_*.dart           # Flavor entry point'leri
```

### Prensipler

- **Paket bağımsızlığı**: Mümkün olduğunca minimum external paket. `freezed`, `get_it`, `logger` gibi paketler kullanılmaz — mevcut `equatable`, `flutter_bloc`'un `RepositoryProvider`'ı, `dart:developer.log` yeterli.
- **State**: `flutter_bloc` + `hydrated_bloc` (auth/lang/settings persist edilir).
- **Hata yönetimi**: `fpdart` `Either<Err, T>` + sealed `AppException` hiyerarşisi (`NetworkException`, `AuthException`, `ParseException`, `PlatformException`).
- **Networking**: `Dio` + `RetryInterceptor` (exponential backoff) + `ErrorHandlerInterceptor` (401/403 otomatik logout callback).
- **DI**: Manuel `RepositoryProvider` / `BlocProvider` — `locator.dart`'ta kayıtlı.

## Flavors

Flavor yönetimi için [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr) kullanılır. `development`, `staging`, `production` flavor'ları mevcuttur.

```bash
# Flavor konfigürasyonunu üret (ios/android projelere uygula)
flutter pub run flutter_flavorizr

# Çalıştırma
flutter run --flavor development -t lib/main_development.dart
flutter run --flavor staging     -t lib/main_staging.dart
flutter run --flavor production  -t lib/main_production.dart
```

Her flavor'a özel `.env.development`, `.env.staging`, `.env.production` dosyaları `assets/` olarak bundle edilir. **Gerçek sırlar asla bu dosyalara yazılmamalıdır** — local override için `.env.*.local` pattern'i `.gitignore`'da ignore edilir.

## İlk Kurulum

1. **Dependency'ler**
   ```bash
   flutter pub get
   ```

2. **Firebase projeni bağla**
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   Bu `lib/firebase_options.dart`, `android/app/google-services.json` ve `ios/Runner/GoogleService-Info.plist` dosyalarını üretir/günceller.

3. **App ikonu ve splash**
   Logonu `assets/image/app_logo.png` konumuna koy, sonra:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

4. **Sosyal login / RevenueCat credentials**
   [lib/core/config/auth_config.dart](lib/core/config/auth_config.dart) ve [lib/core/config/purchase_config.dart](lib/core/config/purchase_config.dart)'taki `dummy*` değerlerini gerçek credential'larla değiştir. Her iki config'te de `productionChecklist` listesi var — deploy öncesi kontrol et.

5. **Flavor setup**
   ```bash
   ./script/flavorizr.sh
   ```

## Routing

`go_router` ile `StatefulShellRoute` pattern'i — bottom nav sekme state'i korunur. Route tanımları [lib/router/router.dart](lib/router/router.dart) ve `sub_routes/` altında. Bildirimlerden gelen deep link'ler [lib/data/notification/notification_queue_manager.dart](lib/data/notification/notification_queue_manager.dart) üzerinden `goRouter.go()`'ya yönlendirilir.

## Lokalizasyon

[easy_localization](https://pub.dev/packages/easy_localization) kullanılır. Yeni string eklemek için:

1. `assets/translation/en-US.json` ve `tr-TR.json` içine ekle
2. Anahtarları üret:
   ```bash
   dart run easy_localization:generate -O lib/localization/locale_keys -f keys -o locale_keys.g.dart -S assets/translation
   ```
   veya `./script/lang.sh`
3. Kullanım:
   ```dart
   import 'package:daisy/core/extension/string_extension.dart';
   Text(LocaleKeys.auth_logout.t)
   ```

## Tema

Material 3 + seed-based color scheme + özelleştirilmiş input/button temaları. Yeni color scheme üretmek için:

- [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/)'a git, paletini üret
- Üretilen kodu [lib/core/style/theme.dart](lib/core/style/theme.dart)'a yapıştır

Input ve button temaları [lib/core/style/theme/input_theme.dart](lib/core/style/theme/input_theme.dart) ve [button_theme.dart](lib/core/style/theme/button_theme.dart) dosyalarında — 12dp rounded corners, outline borders, filled input variant.

## Test

```bash
flutter test                 # tüm testler
flutter test test/core       # core layer testleri
flutter test test/modules    # feature/cubit testleri
```

Test'ler `bloc_test` + `mocktail` kullanır. Mevcut kapsama:
- `test/core/retry_interceptor_test.dart` — Dio retry politikası
- `test/core/dio_integration_test.dart` — Dio client integration
- `test/core/network/network_tests.dart` — Network tests
- `test/core/manager/_tests/` — Firebase auth client tests
- `test/modules/auth/auth_unit_test.dart` — AuthService
- `test/modules/home/home_cubit_test.dart` — HomeCubit state transitions
- `test/modules/purchase/purchase_cubit_test.dart` — PurchaseCubit state transitions

## In-App Purchase (RevenueCat)

Template, satın alma akışı için **RevenueCat'in native paywall**'unu kullanır ([purchases_ui_flutter](https://pub.dev/packages/purchases_ui_flutter)). Custom paywall UI yok — tüm paywall tasarımı RevenueCat dashboard'unda yapılandırılır.

**Setup:**
1. [purchase_config.dart](lib/core/config/purchase_config.dart)'ta `dummyRevenueCatApiKey`, `dummyEntitlements` ve `dummyProductIds`'i gerçek değerlerle değiştir
2. RevenueCat dashboard'unda paywall'u yapılandır (Offerings → Paywall tab)

**Kullanım:**

```dart
// Paywall'u göster (navigate to PurchaseScreen)
context.pushNamed(Screens.purchase.name);

// Veya doğrudan:
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
final result = await RevenueCatUI.presentPaywall();
if (result == PaywallResult.purchased) {
  await context.read<PurchaseCubit>().refresh();
}

// Entitlement kontrolü (senkron, cache'lenmiş)
final hasPremium = context.read<PurchaseCubit>().state.hasPremium;
final hasCustomEntitlement =
    context.read<PurchaseCubit>().checkEntitlement('my_entitlement_id');
```

[PurchaseCubit](lib/feature/purchase/cubit/purchase_cubit.dart) satın alma akışını yönetmez — sadece SDK init, `CustomerInfo` refresh ve entitlement state okuma yapar. [PurchaseService](lib/core/manager/purchase/purchase_service.dart) de ince bir RevenueCat wrapper'ıdır. Custom UI istersen [purchase_screen.dart](lib/feature/purchase/view/purchase_screen.dart)'ı kendi tasarımınla değiştir.

## Force / Soft Update

[ForceUpdateManager](lib/core/manager/remote/force_update_manager.dart) Firebase Remote Config üzerinden versiyon politikasını okur. Başlangıçta çağır:

```dart
final manager = ForceUpdateManager();
await manager.initialize();
if (context.mounted) {
  await manager.showUpdateDialogIfNeeded(context);
}
```

`showUpdateDialogIfNeeded`:
- Force update gerekirse → dismissless dialog, sadece "Update"
- Soft update önerisiyse → "Later" + "Update" butonları
- "Update"'e basıldığında `url_launcher` ile store'a yönlendirir

Remote Config anahtarları: `android_min_version`, `ios_min_version`, `is_force_update_required`, `android_store_url`, `ios_store_url`, `update_message_tr`, `update_message_en`.

## Scripts

`script/` altındaki yardımcı shell script'ler:

| Script | Açıklama |
|--------|----------|
| `flavorizr.sh` | `flutter_flavorizr` çalıştırır |
| `lang.sh` | Lokalizasyon keys üretir |
| `launcher_icons.sh` | App ikonlarını üretir |
| `native_splash.sh` | Splash screen üretir |
| `build_ios.sh` / `build_android.sh` | Release build scriptleri |
| `upload_firebase_ios.sh` / `upload_firebase_android.sh` | Firebase App Distribution upload |

## Mason

Feature scaffolding için [Mason](https://pub.dev/packages/mason_cli) kullanılabilir:

```bash
dart pub global activate mason_cli
mason make <brick-name> -o <output-dir>
```

## Önemli Dosyalar

- [lib/app/bootstrap.dart](lib/app/bootstrap.dart) — uygulama başlatma
- [lib/app/locator.dart](lib/app/locator.dart) — DI (RepositoryProvider'lar)
- [lib/app/provider.dart](lib/app/provider.dart) — global BLoC/Cubit kayıtları
- [lib/core/manager/remote/dio_client.dart](lib/core/manager/remote/dio_client.dart) — HTTP client
- [lib/core/types/data_exception.dart](lib/core/types/data_exception.dart) — `AppException` hiyerarşisi
- [lib/core/manager/validation/environment_validation_service.dart](lib/core/manager/validation/environment_validation_service.dart) — startup config doğrulama
- [lib/feature/auth/cubit/auth_cubit.dart](lib/feature/auth/cubit/auth_cubit.dart) — auth state management

## Katkıda Bulunma

- `flutter analyze` temiz olmalı
- Yeni feature için `test/modules/<feature>/` altına testini ekle
- Package ekleme öncesi değerlendir: template paket-minimalist felsefe ile gelir
- Commit mesajı Conventional Commits (`feat:`, `fix:`, `refactor:`, vs.)
