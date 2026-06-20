# apps/mobile

SaloonManager uygulamasının Flutter mobil uygulaması. Tüm `flutter_kit_*` paketlerini tüketir.

## Genel Bakış

```
apps/mobile/lib/
├── core/
│   ├── components/    ← Uygulama geneli UI bileşenleri (AppButton, AppTextField, AppCard…)
│   ├── config/        ← AppEnvironment (baseUrl native'den alınır)
│   ├── data/          ← Repository impls, DTO'lar, remote datasource'lar
│   ├── di/            ← GetIt modülleri (NetworkModule, AuthModule, NavigationModule)
│   ├── domain/        ← Entity'ler, repository interface'leri, use case'ler
│   └── managers/      ← AppNavigator, AppRouter, DeepLinkManager
├── features/
│   ├── login/
│   ├── register/
│   ├── dashboard/
│   ├── home/
│   └── shell/
└── main.dart / main_dev.dart / main_staging.dart / main_prod.dart
```

---

## Flavor ile Çalıştırma

| Flavor | Komut |
|--------|-------|
| Development | `flutter run --flavor dev -t lib/main_dev.dart` |
| Staging | `flutter run --flavor staging -t lib/main_staging.dart` |
| Production | `flutter run --flavor prod -t lib/main_prod.dart` |

VS Code'da **Run & Debug** panelinde `dev`, `staging`, `prod` konfigürasyonları hazır gelir (`.vscode/launch.json`).

---

## Entry Point'ler

Her flavor'ın kendi `main_*.dart` dosyası vardır:

```dart
// main_dev.dart
void main() => Initialize.prepare(AppEnvironment.dev);
```

`Initialize.prepare(env)`:
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `ScreenUtil` başlatılır (tasarım boyutu: 390×844)
3. `setupFirebase(options: firebaseOptions)` çalışır
4. `Injection.init(apiConfig: AppConfig.apiConfig)` — DI modülleri sırayla kurulur
5. `runApp(SaloonManagerApp())` çalışır

---

## DI Modül Sırası

`Injection.init()` içinde modüller **bu sırayla** çalışmalıdır:

```
1. setupNetworkModule(getIt, apiConfig: apiConfig)
   → FlutterSecureStorage, TokenStore, ApiManager kaydedilir

2. setupAuthModule(getIt)
   → AuthRemoteDataSource, AuthRepository, AuthManager, AuthBloc kaydedilir
   → AuthManager, ApiManager ve TokenStore'a ihtiyaç duyar (1. adıma bağımlı)

3. setupNavigationModule(getIt)
   → GoRouter, AuthRouterNotifier kaydedilir
   → AuthBloc'a ihtiyaç duyar (2. adıma bağımlı)
```

Sıra bozulursa GetIt `Object not registered` hatası verir.

---

## Feature Dizin Yapısı

Her feature şu dosyaları içerir:

```
features/<name>/
├── bloc/
│   ├── <name>_bloc.dart          # extends BaseBloc<Event, State>
│   ├── <name>_event.dart         # Sealed class events
│   └── <name>_state.dart         # extends BaseState, copyWith
├── view/
│   └── <name>_screen.dart        # UI katmanı
└── <name>_navigator.dart       # GoRoute + show() metodu
```

`<name>_navigator.dart` dosyası `AppNavigator`'a route'u kaydeder. Tüm navigation bu koordinatörler üzerinden akar.

---

## Testleri Çalıştırma

```bash
# Tüm workspace testleri (proje kökünden)
melos test

# Sadece mobile app testleri
cd apps/mobile && flutter test
```

Test dosyaları `apps/mobile/test/` altında feature mirroring yapısındadır:
```
test/
├── features/
│   ├── login/login_bloc_test.dart
│   ├── dashboard/dashboard_bloc_test.dart
│   └── shell/shell_cubit_test.dart
└── core/
    ├── domain/get_dashboard_usecase_test.dart
    └── data/dashboard_repository_impl_test.dart
```

---

## Firebase Olmadan Yerel Geliştirme

Firebase dosyaları (`.plist`, `.json`) repo'ya commit edilmez. Ekibin Firebase projesi yoksa ya da yalnızca UI geliştirmesi yapılıyorsa iki yerde bypass yapılır:

**1. `Initialize` Dart bayrağı** — `apps/mobile/lib/core/initialize/initialize.dart`:
```dart
static const bool _firebaseEnabled = false; // Firebase init'i ve bildirimleri atla
```

**2. iOS build script** — `apps/mobile/ios/copy_google_services.sh`:
- `GoogleService-Info.plist` bulunamazsa `exit 0` döner (uyarı verir ama build'i patlatmaz).
- Gerçek plist eklendiğinde bu davranış otomatik olarak düzelir.

Firebase aktifleştirilmek istendiğinde:
1. `_firebaseEnabled` değerini `true` yap.
2. Flavor başına doğru `GoogleService-Info.plist` dosyasını `ios/config/<flavor>/` altına koy.

---

## CI/CD — Gerekli Secrets

GitHub Actions'da şu secret'lar tanımlı olmalıdır:

| Secret | Amaç |
|--------|------|
| `FIREBASE_SERVICE_ACCOUNT` | Firebase App Distribution için servis hesabı JSON |
| `FIREBASE_STAGING_APP_ID` | Staging flavor Firebase App ID |
| `FIREBASE_PROD_APP_ID` | Prod flavor Firebase App ID |

Workflow'lar:
- **`ci.yml`** — her PR'da lint, analyze, test çalıştırır (ubuntu runner)
- **`android-staging.yml`** — her PR'da staging APK build + Firebase dağıtımı
- **`android-prod.yml`** — `v*` tag push'unda prod APK build + Firebase dağıtımı
