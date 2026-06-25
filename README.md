# daisy

Üretim-hazır Flutter başlangıç şablonu. Clean Architecture + BLoC, çoklu flavor, Firebase ekosistemi, sosyal login, RevenueCat, lokalizasyon ve temel güvenlik/UX iyileştirmeleri ile gelir.

> 🚀 **Yeni bir projeye mi uyarlıyorsun?** Aşağı inip [Template Setup Checklist](#template-setup-checklist) bölümünü takip et.

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

## Template Setup Checklist

Template'i yeni bir projeye adapte etmek için aşağıdaki adımları **sırayla** uygula. Her adımın başındaki kutucuğu kontrol et — hiçbirini atlama, aksi halde build kırılır veya store'a yüklenemez.

### 1. Proje ismi değiştir (`daisy` → senin projen)

`daisy` referansı tüm Dart importlarında ve platform config'lerde geçiyor. Toplu değiştir:

```bash
# 1. pubspec.yaml'daki name alanını değiştir
# 2. Tüm Dart importlarını güncelle:
find lib test -name "*.dart" -exec sed -i '' 's|package:daisy/|package:PROJECT_NAME/|g' {} +

# 3. Android MainActivity'nin paket yolunu taşı (örneğin com.yourco.projectname):
#    android/app/src/main/kotlin/com/example/daisy/MainActivity.kt
#    → android/app/src/main/kotlin/com/yourco/projectname/MainActivity.kt
#    Dosyanın içindeki `package com.example.daisy` satırını da güncelle.

# 4. Değiştir:
flutter clean && flutter pub get
```

### 2. Bundle ID / Application ID

- **Android**: [android/app/build.gradle:16-32](android/app/build.gradle#L16) — 3 flavor için `applicationId` (örn. `com.yourco.app.dev`, `.stg`, `.app`). `namespace` alanı da güncellenecek.
- **iOS**: Xcode → Runner target → Signing & Capabilities → Bundle Identifier, flavor scheme'lerine göre (`com.yourco.app`, `.dev`, `.stg`)
- [flavorizr.yaml](flavorizr.yaml) — tüm flavor bundle ID ve görünen isimleri tek yerden yönetilir. Güncelledikten sonra `./script/flavorizr.sh` çalıştır.

### 3. Firebase projesini bağla

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Bu komut `lib/firebase_options.dart`, `android/app/google-services.json` ve `ios/Runner/GoogleService-Info.plist` dosyalarını senin projene göre üretir.

- [validators/firebase_validator.dart:32](lib/core/manager/validation/validators/firebase_validator.dart#L32) — `'daisy-c1c2c'` hardcoded string'i artık senin project ID'nle eşleşmeyecek, dolayısıyla `isDummyProject` check'i doğru çalışacak. İstersen bu string'i kendi dummy project ID'nle değiştirebilirsin.

### 4. Credentials & TODO'lar

Template'te 4 kritik TODO var (hepsi `⚠️ PRODUCTION TODO` etiketli):

| Dosya | Ne | Kaynak |
|-------|-----|--------|
| [auth_config.dart:14](lib/core/config/auth_config.dart#L14) | Google OAuth Client ID | Google Cloud Console > OAuth credentials |
| [auth_config.dart:20](lib/core/config/auth_config.dart#L20) | Apple Service ID | Apple Developer > Identifiers |
| [purchase_config.dart:15](lib/core/config/purchase_config.dart#L15) | RevenueCat API Key | RevenueCat Dashboard > API Keys |
| [purchase_config.dart:22](lib/core/config/purchase_config.dart#L22) | Entitlement ID'leri | RevenueCat Dashboard > Entitlements |

iOS Google Sign-In için ayrıca [ios/Runner/Info.plist](ios/Runner/Info.plist)'teki `REPLACE-WITH-REVERSED-CLIENT-ID` placeholder'ını `GoogleService-Info.plist`'ten aldığın `REVERSED_CLIENT_ID` ile değiştir.

### 5. API URL'leri ve Environment

- [core_strings.dart:6-8](lib/core/config/core_strings.dart#L6-L8) — `devUrl`, `stgUrl`, `prodUrl` placeholder'larını (`localhost:3000`, `staging.example.com`, `example.com`) senin backend'inle değiştir.
- `.env.development`, `.env.staging`, `.env.production` — uygulamaya bundle edilen env dosyaları. Placeholder'ları güncelle. **Gerçek sırlar buraya yazılmamalı** — local override için `.env.*.local` kullan (gitignore'da).

### 6. Branding (logo, splash, renkler, font)

- **Logo**: `assets/image/app_logo.png` — senin logonu bu isimle koy, sonra:
  ```bash
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```
- **Splash rengi**: [pubspec.yaml](pubspec.yaml) `flutter_native_splash > color` (template mavisi `#42a5f5`)
- **Tema renkleri**: [lib/core/style/theme.dart](lib/core/style/theme.dart) — [Material Theme Builder](https://material-foundation.github.io/material-theme-builder/) ile kendi paletini üret ve `ColorScheme` değerlerini yapıştır
- **Font**: [lib/app/app.dart:19](lib/app/app.dart#L19) — `'Rubik'` yerine [Google Fonts](https://fonts.google.com/) katalogundan istediğin fontu yaz
- **Uygulama başlığı**: [lib/app/app.dart:23](lib/app/app.dart#L23) — `title: 'Flutter Template'`

### 7. Release Signing & Store hazırlığı

- **Android**: [android/app/build.gradle:61-65](android/app/build.gradle#L61) — release build şu an debug key ile imzalanıyor, Play Store'a yüklenemez. `android/key.properties` oluştur ve release signing config'ini tanımla ([Flutter docs](https://docs.flutter.dev/deployment/android#signing-the-app))
- **iOS**: Xcode → Runner → Signing & Capabilities → Team seçimi + provisioning profile
- **Android minSdk**: [android/app/build.gradle](android/app/build.gradle) — şu an 23, Firebase 24+ öneriyor (dev seçimi)

### 8. Localization içeriği

- [assets/translation/en-US.json](assets/translation/en-US.json) ve [tr-TR.json](assets/translation/tr-TR.json) — jenerik şablon string'leri içeriyor, domain'ine göre güncelle
- Yeni dil eklenecekse aynı formatta JSON dosyası + [app.dart](lib/app/app.dart)'ta `supportedLocales` güncelle
- String ekledikten sonra locale keys'i regenerate et:
  ```bash
  ./script/lang.sh
  ```

### 9. (Opsiyonel) Firebase Remote Config — Force/Soft Update

[ForceUpdateManager](lib/core/manager/remote/force_update_manager.dart) kullanılacaksa Firebase Remote Config'e şu anahtarları ekle:
- `android_min_version`, `ios_min_version` (semver, ör. `1.2.0` veya `1.2.0+45`)
- `is_force_update_required` (bool) — `true` ise modal kapatılamaz
- `android_store_url`, `ios_store_url`
- `update_message_tr`, `update_message_en` (opsiyonel; boş bırakılırsa `LocaleKeys.update_messageDefault` kullanılır)

### 10. Doğrulama

Tüm adımlar tamamlandıktan sonra:

```bash
flutter clean
flutter pub get
flutter analyze                                          # temiz olmalı
flutter test                                             # testler geçmeli
flutter run --flavor development -t lib/main_development.dart  # çalışmalı
```

İlk çalıştırmada `EnvironmentValidationService` bootstrap'te tüm config'leri kontrol edip log basar — "dummy" kalan alanlar olursa konsol çıktısında görünür.

---

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
1. [purchase_config.dart](lib/core/config/purchase_config.dart)'ta `dummyRevenueCatApiKey` ve `dummyEntitlements`'ı gerçek değerlerle değiştir
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

Versiyon politikası [ForceUpdateManager](lib/core/manager/remote/force_update_manager.dart) ile Firebase Remote Config üzerinden okunur. Uygulama genelinde [AppUpdateCubit](lib/core/bloc/app_update/app_update_cubit.dart) bunu sarar ve splash başlangıcında + uygulama foreground'a döndüğünde otomatik tekrar kontrol eder.

```dart
// Provider olarak (lib/app/provider.dart içinde zaten kayıtlı)
BlocProvider<AppUpdateCubit>(create: (_) => AppUpdateCubit()),

// Kontrol tetikleme (splash bunu otomatik yapar)
await context.read<AppUpdateCubit>().check(
  languageCode: context.locale.languageCode,
);

final state = context.read<AppUpdateCubit>().state;
if (state.isForced) { /* dismissless modal göster */ }
else if (state.hasUpdate) { /* opsiyonel modal */ }
```

Davranış:
- `forced` → modal kapatılamaz, sadece "Update" butonu store'a yönlendirir.
- `optional` → "Later" + "Update" butonları; kullanıcı uygulamaya devam edebilir.
- Boş / hatalı Remote Config → güncelleme yok kabul edilir.
- `kDebugMode`: her açılışta fetch; release: 1 saatte bir.

Yerelleştirme: modal başlık/buton stringleri `easy_localization` ile [`update.*`](assets/translation/en-US.json) anahtarları üzerinden gelir; Remote Config'deki `update_message_*` alanları opsiyonel override'dır.

Remote Config anahtarları: `android_min_version`, `ios_min_version`, `is_force_update_required`, `android_store_url`, `ios_store_url`, `update_message_tr`, `update_message_en`.

## Push Notifications (FCM)

Push akışı Firebase Cloud Messaging üzerinden çalışır ve şu parçalardan oluşur:

| Dosya | Sorumluluk |
|-------|-----------|
| [`FcmService`](lib/core/manager/notification/fcm_service.dart) | Tek giriş noktası: izin, token, foreground/opened/initial mesaj akışı, topic helper'ları. |
| [`firebaseMessagingBackgroundHandler`](lib/core/manager/notification/fcm_background_handler.dart) | Top-level (`@pragma('vm:entry-point')`) background handler — Android için zorunlu. |
| [`LocalNotificationHandler`](lib/core/manager/notification/local_notification_handler.dart) | Android'de foreground mesajları için lokal notification gösterir; iOS'ta sistem banner'ı otomatik. |
| [`NotificationQueueManager`](lib/data/notification/notification_queue_manager.dart) | Splash hazır olana kadar gelen aksiyonları kuyruğa alır, hazır olunca işler (`deepLink`/`navigation`/`general`). |

Bootstrap (`lib/app/bootstrap.dart` → `_FirebaseMixin`) `FcmService().initialize()` çağırır; token alma `unawaited` ile fire-and-forget'tir (iOS Simulator APNS yokken bootstrap'i bloklamasın diye). Token backend'e göndermek için `firebase_mixin.dart` içindeki `TODO(template)` satırına dokunmak yeterli.

**Backend payload örnekleri**

```jsonc
// Notification mesajı (sistem hem ön plan hem arka planda banner gösterir).
{
  "message": {
    "token": "<device-fcm-token>",
    "notification": { "title": "Hello", "body": "World" },
    "data": { "route": "/profile" }      // tap → goRouter.go('/profile')
  }
}

// Data-only (sessiz / arka planda da iletilir).
{
  "message": {
    "token": "<device-fcm-token>",
    "data": {
      "title": "Promo",
      "body": "30% off this weekend",
      "url": "https://example.com/promo"  // tap → external browser
    }
  }
}
```

`data.route` veya `data.url` taşıyan payload'lar tap'lendiğinde otomatik olarak `NotificationQueueManager` üzerinden yönlendirilir; sonradan eklenmek istenen tipler için [`NotificationActionType`](lib/data/notification/models/notification_action.dart) genişletilebilir.

**Manuel kurulum adımları**

Android:
- `AndroidManifest.xml`'de `POST_NOTIFICATIONS` izni ve default channel/icon/color meta-data eklendi. Renk / icon değiştirmek istersen `mipmap/launcher_icon` ve `@android:color/white` referanslarını güncelle.
- Android 13+ için runtime izin: [`PermissionClient.requestNotificationPermission()`](lib/core/manager/local/permission_client.dart) tetiklenmeli (örn. onboarding ekranında).

iOS:
- Xcode → Runner → Signing & Capabilities → **Push Notifications** capability'sini her flavor için ekle.
- `Runner.entitlements`'taki `aps-environment` debug için `development`. Store/TestFlight build'lerinde Xcode bunu `production`a çevirir (kapasiteyi açtığında otomatik).
- Firebase Console → Project Settings → Cloud Messaging → Apple → APNs Auth Key (`.p8`) yükle.
- Simülatörde push almak için Xcode 14+ gerekir; aksi halde `getToken()` `null` döner ve loglarda `APNS token not ready` mesajı görülür (beklenen davranış).

**Topic kullanımı**

```dart
final fcm = FcmService();
await fcm.subscribeToTopic('news_en');
await fcm.unsubscribeFromTopic('news_en');
```

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
