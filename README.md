# Flutter Base Kit — Monorepo

Production-ready Flutter monorepo template. Includes Clean Architecture, BLoC pattern, Firebase, RevenueCat, and security infrastructure.

---

## Monorepo Structure

```
flutter_base_kit_workspace/
├── melos.yaml                    # Melos workspace definition
├── pubspec.yaml                  # Workspace root (pub workspaces)
├── packages/
│   ├── flutter_kit_network/      # Networking layer (Dio, interceptors, cache)
│   ├── flutter_kit_core/         # Core abstractions (BaseBloc, BaseUseCase)
│   ├── flutter_kit_auth/         # Auth management + AuthBloc
│   ├── flutter_kit_firebase/     # Firebase + push notification integration
│   ├── flutter_kit_ui/           # Theme, shared widgets
│   └── flutter_kit_purchase/     # RevenueCat in-app purchase
└── apps/
    └── mobile/                   # Flutter application
        ├── lib/
        │   ├── core/             # App-specific: config, DI, navigation, splash
        │   └── features/         # Feature modules (home, etc.)
        └── pubspec.yaml
```

### Package Dependency Order

```
flutter_kit_network
    └── flutter_kit_core
            └── flutter_kit_auth
            └── flutter_kit_firebase
            └── flutter_kit_ui
            └── flutter_kit_purchase
```

---

## Setup

```bash
# Activate Melos globally
dart pub global activate melos

# Bootstrap the workspace from the root directory
melos bootstrap
```

---

## App Structure

```
apps/mobile/lib/
├── core/
│   ├── config/             # AppEnvironment, AppConfig (native channel)
│   ├── deeplink/           # DeepLinkManager
│   ├── di/                 # Injection.init() — all DI registrations
│   ├── enums/              # Asset helper enums
│   ├── firebase/           # FirebaseOptions (dev/staging/prod)
│   ├── initialize/         # Initialize — startup orchestrator
│   ├── localization/       # slang_flutter i18n files
│   ├── managers/
│   │   ├── device_info_manager/
│   │   └── navigation_manager/ # AppRouter, GoRouter, guards
│   ├── security/           # JailbreakDetector, JailbreakBlockApp
│   └── splash/             # SplashScreen, SplashCoordinator
└── features/
    └── home/               # Example feature (placeholder)
```

---

## Flavors

Three environments are available: `dev`, `staging`, `prod`.

| Flavor | Entry Point | Firebase |
|--------|-------------|----------|
| dev | `lib/main_dev.dart` | `firebase_options_dev.dart` |
| staging | `lib/main_staging.dart` | `firebase_options_staging.dart` |
| prod | `lib/main_prod.dart` | `firebase_options_prod.dart` |

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor prod -t lib/main_prod.dart
```

`AppConfig` reads `baseUrl`, `appName`, and `googleServerClientId` from the native layer (`strings.xml` / `Info.plist`):

```dart
AppConfig.instance.baseUrl
AppConfig.instance.isProd
AppConfig.instance.environment  // AppEnvironment enum
```

---

## Startup Flow

```
main_dev.dart
    └── mainCommon(AppEnvironment.dev)
            ├── Initialize.prepare(env)
            │       ├── _initBinding()           ← preserve splash
            │       ├── _initOrientation()
            │       ├── AppConfig.init(env)       ← read native config
            │       ├── _initFirebase(env)        ← calls setupFirebase()
            │       ├── _initDI(env)              ← Injection.init(apiConfig:)
            │       └── _initLocaleAndTheme()
            └── runApp(...)

SplashScreen (shown)
    └── Initialize.run()
            ├── setupNotifications()
            └── JailbreakDetector.isDeviceCompromised()
                    ├── compromised → JailbreakBlockApp
                    └── safe       → context.go('/home')
```

---

## Dependency Injection

GetIt is used. All registrations live in `apps/mobile/lib/core/di/injection.dart`.

Network registration is delegated to `flutter_kit_network`'s `setupNetworkingWithApiConfig()`:

```
1. TokenStore is registered
2. setupNetworkingWithApiConfig() is called — token providers wired
3. Auth data layer is registered
4. AuthManager.create() builds a single instance
5. Other managers, BLoCs, and router are registered
```

```dart
// Access from anywhere
final authManager = getIt<AuthManager>();
final router = getIt<GoRouter>();
```

**Adding a new service:**

```dart
// In injection.dart
getIt.registerLazySingleton<MyService>(() => MyService());

// In a Bloc
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final MyService _service = getIt<MyService>();
}
```

---

## Networking — flutter_kit_network

Built on `DioClient`. All requests go through the `ApiManager` interface.

### Interceptors (run automatically)

| Interceptor | Responsibility |
|---|---|
| `AuthInterceptor` | Attaches `Authorization: Bearer <token>` to every request |
| `RefreshTokenInterceptor` | Refreshes the token on 401 and retries the request |
| `ConnectivityInterceptor` | Throws an error when there is no internet |
| `RetryInterceptor` | Retries up to 3x on network errors |
| `CacheInterceptor` | Caches GET responses |
| `RateLimiterInterceptor` | Flood protection per endpoint |
| `LoggingInterceptor` | Logs requests/responses in non-prod environments |

### Token Flow

`AuthInterceptor` → `TokenStore.readAccess()` → `Authorization: Bearer <token>`

On 401 → `RefreshTokenInterceptor` → `/auth/refresh` (bare Dio, no circular dependency) → token saved → request retried

### Usage

`ApiManager` is not used directly; follow the **repository → usecase → bloc** chain:

```dart
// Inside a repository implementation
final response = await apiManager.get<Map<String, dynamic>>(path: '/users/me');
final response = await apiManager.post<Map<String, dynamic>>(
  path: '/auth/login',
  body: {'email': email, 'password': password},
);
```

### Result Pattern

Every API response returns `Result<T, ApiError>`, handled with `when`:

```dart
result.when(
  ok: (data) => emit(state.copyWith(item: MyModel.fromJson(data))),
  err: (error) => emit(state.copyWith(errorMessage: error.message)),
);
```

---

## Auth — flutter_kit_auth

`AuthManager` handles token storage, session state, and all authentication operations.

Created via `AuthManager.create()` and registered in getIt. No static singleton pattern.

```dart
final auth = getIt<AuthManager>();

auth.isLoggedIn    // bool
auth.profile       // Profile? (id, email, firstName, lastName, avatarUrl)
auth.tokens        // AuthTokens? (accessToken, refreshToken)
```

### Methods

```dart
await auth.login(email, password);
await auth.register(email: email, password: password);
await auth.logout();
await auth.signInWithApple(idToken);
await auth.signInWithGoogle(idToken);
await auth.signInAsGuest();
await auth.fetchMe();
await auth.updateProfile({'firstName': 'Ali'});
```

All methods return `Result<void, ApiError>`:

```dart
final result = await auth.login(email, password);
result.when(
  ok: (_) => context.go('/home'),
  err: (error) => showSnackbar(error.message),
);
```

### AuthBloc

Listens to `AuthManager` and keeps auth state reactive:

```dart
authBloc.state.isAuthenticated
authBloc.state.profile
authBloc.add(const AuthLogoutRequested());
```

---

## BLoC Architecture — flutter_kit_core

### Base Classes

```
BaseBloc<E, S extends BaseState>
    └── onReady()    → called after widget renders (post-frame)
    └── onInit()     → called when bloc is created

BaseCubit<S extends BaseState>
    └── safeEmit()   → skips emit if bloc is already closed

BaseState
    └── isLoading    → shows LoadingOverlay automatically
    └── isValid      → for form validation
    └── errorMessage → error state
```

> `BaseBloc` and `BaseCubit` no longer auto-inject `authManager` / `apiManager`. Blocs that need them receive them via constructor or pull from getIt directly.

### Screen Definition

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseBlocView<MyBloc, MyState>(
      create: () => MyBloc(getIt<MyRepository>()),
      loadingOverlay: const MyLoadingWidget(), // optional, defaults to CircularProgressIndicator
      builder: (context, state, bloc) {
        return Scaffold(
          body: ListView.builder(
            itemCount: state.items.length,
            itemBuilder: (_, i) => ListTile(title: Text(state.items[i].title)),
          ),
        );
      },
    );
  }
}
```

### Bloc Definition

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final MyRepository _repo;

  MyBloc(this._repo) : super(const MyState()) {
    on<MyFetched>(_onFetched);
  }

  @override
  void onReady() => add(const MyFetched());

  Future<void> _onFetched(MyFetched event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getItems();
    result.when(
      ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
      err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

### PaginatedBloc

```dart
class MyListBloc extends BaseBloc<MyListEvent, MyListState>
    with PaginatedBloc<MyItem, MyListEvent, MyListState> {

  MyListBloc() : super(const MyListState()) {
    on<MyListStarted>((e, emit) => handleLoadInitial(emit));
    on<MyListLoadMore>((e, emit) => handleLoadMore(emit));
  }

  @override
  Future<(List<MyItem>, bool, int)> fetchPage(int offset, int size) async {
    final items = await _repo.getPage(offset: offset, size: size);
    return (items, items.length >= size, offset + items.length);
  }

  @override
  MyListState paginatedState({...}) => state.copyWith(...);
}
```

---

## Navigation

GoRouter is used. Access the router via `getIt<GoRouter>()`.

### Adding a Route

```dart
// In app_router.dart
GoRoute(
  path: '/my-screen',
  parentNavigatorKey: rootKey,
  builder: (context, state) => const MyScreen(),
),
```

### Navigation

```dart
context.go('/my-screen');
context.push('/my-screen');
context.go('/my-screen', extra: data);
context.pop();
```

### Auth Guard

```dart
GoRoute(
  path: '/protected',
  redirect: (context, state) {
    final auth = getIt<AuthBloc>().state;
    return auth.isAuthenticated ? null : '/login';
  },
  builder: (context, state) => const ProtectedScreen(),
),
```

---

## Firebase — flutter_kit_firebase

A separate `FirebaseOptions` file exists for each flavor:

```
apps/mobile/lib/core/firebase/
├── firebase_options_dev.dart
├── firebase_options_staging.dart
└── firebase_options_prod.dart
```

`setupFirebase(options:)` is called automatically in `Initialize._initFirebase(env)`.

```bash
# Connect a new Firebase project
flutterfire configure --project=my-project-dev \
  --out=apps/mobile/lib/core/firebase/firebase_options_dev.dart
```

### Notifications

`setupNotifications()` is called during the splash screen (`Initialize.run()`).

**FCM Token:**

```dart
final token = await NotificationManager.instance.getToken();
```

**Deep Link Handler — Callback Pattern:**

The router dependency is broken via a callback, keeping `flutter_kit_firebase` router-free:

```dart
// Set once at app startup
NotificationDeepLinkHandler.onNavigate = (path, params) {
  getIt<GoRouter>().go(path, extra: params);
};
```

**Approval Notifications:**

```dart
NotificationManager.instance.onApprovalAction = (approvalId, isApproved) async {
  if (isApproved) await myService.approve(approvalId);
  else await myService.reject(approvalId);
};
```

---

## RevenueCat — flutter_kit_purchase

Single instance: `RevenueCatManager.instance`.

Update product IDs in:

```
packages/flutter_kit_purchase/lib/constants/store_product_ids.dart
```

```dart
await RevenueCatManager.instance.init();
await RevenueCatManager.instance.logIn(userId);   // after login

final offerings = await RevenueCatManager.instance.fetchOfferings();
final packs = RevenueCatManager.instance.buildCrystalPacks(offerings);

final result = await RevenueCatManager.instance.purchase(package);
result.when(
  (success) => handleSuccess(success.productId),
  (cancelled) => showMessage('Cancelled'),
  (failure) => showError(failure.message),
  (restore) => handleRestore(restore.hasPremium),
);

final isPremium = await RevenueCatManager.instance.hasPremiumEntitlement();
```

---

## Security — Jailbreak / Root Detection

Uses a native platform channel to detect jailbroken (iOS) or rooted (Android) devices.

Checked automatically in `Initialize.run()`. If the device is compromised, `JailbreakBlockApp` is shown and the app becomes unusable.

Update the `com.base.project/security` channel ID with your own bundle ID on the native side.

---

## Theme — flutter_kit_ui

```dart
context.read<ThemeCubit>().setLight();
context.read<ThemeCubit>().setDark();
context.read<ThemeCubit>().setSystem();

AppColors.primary
AppColors.background
AppTheme.light
AppTheme.dark
```

Theme is managed by `ThemeCubit` and persisted to `SharedPreferences`.

---

## Localization

`slang_flutter` is used. Translation files:

```
apps/mobile/lib/core/localization/i18n/
├── en.i18n.json
└── tr.i18n.json
```

```dart
Text(context.t.someKey)
LocaleSettings.setLocale(AppLocale.tr);
```

After adding a new key, run `dart run slang` to regenerate.

---

## Validator — flutter_kit_core

`FieldValidator` takes a list of `Validator` rules. `Validators` provides static factories for all built-in rules.

```dart
// Single field
final emailValidator = FieldValidator<String>([
  Validators.required(),
  Validators.email(),
  Validators.maxLength(100),
]);

// Validate — returns first error message or null
final error = emailValidator.validate(state.email);

// Validate all — returns ValidationResult with every error
final result = emailValidator.validateAll(state.password);
result.isValid;   // bool
result.errors;    // List<String>

// Extend with more rules
final strictValidator = emailValidator.and([Validators.pattern(r'\.com$')]);

// Use in a TextFormField
TextFormField(
  validator: (value) => emailValidator.validate(value),
)
```

`FormValidator` tracks multiple fields and overall form validity:

```dart
FormValidator get _form => FormValidator({
  'email':    () => emailValidator.validate(state.email),
  'password': () => passwordValidator.validate(state.password),
});

bool canSubmit = _form.isValid;
String? emailError = _form.errorFor('email');
Map<String, String> active = _form.activeErrors; // only failing fields
```

**Available rules:** `required`, `email`, `minLength`, `maxLength`, `min`, `max`, `range`, `pattern`, `equals`, `custom`

---

## Adding a New Feature

### 1. Folder structure

```
apps/mobile/lib/features/my_feature/
├── bloc/
│   ├── my_feature_event.dart
│   ├── my_feature_state.dart
│   └── my_feature_bloc.dart
├── data/
│   ├── dto/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── view/
    └── my_feature_screen.dart
```

### 2. Entity and Repository

```dart
abstract class MyRepository {
  Future<Result<List<MyItem>, ApiError>> getItems();
}
```

### 3. Register with DI

```dart
// In injection.dart
getIt.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(getIt<ApiManager>()),
);
```

### 4. Bloc

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final MyRepository _repo;

  MyBloc(this._repo) : super(const MyState()) {
    on<MyFetched>(_onFetched);
  }

  @override
  void onReady() => add(const MyFetched());

  Future<void> _onFetched(MyFetched event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repo.getItems();
    result.when(
      ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
      err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

### 5. Add route

```dart
GoRoute(
  path: '/my-feature',
  parentNavigatorKey: rootKey,
  builder: (context, state) => const MyScreen(),
),
```

---

## Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | BLoC / Cubit state management |
| `get_it` | Dependency injection |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `firebase_core/messaging/analytics/crashlytics` | Firebase |
| `flutter_local_notifications` | Local notifications |
| `google_sign_in` + `sign_in_with_apple` | Social auth |
| `purchases_flutter` | RevenueCat in-app purchases |
| `flutter_secure_storage` | Encrypted token storage |
| `shared_preferences` | Lightweight local storage |
| `slang_flutter` | Localization |
| `equatable` | Value equality |
| `connectivity_plus` | Network status |
| `app_links` | Deep linking |
| `flutter_native_splash` | Native splash screen |
| `flutter_screenutil` | Responsive sizing |
| `melos` | Monorepo management |
