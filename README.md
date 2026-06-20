# Flutter Base Kit — Monorepo

Production-ready Flutter monorepo template. Clean Architecture, BLoC pattern, Firebase, and security infrastructure.

---

## Monorepo Structure

```
flutter_base_kit/
├── melos.yaml                    # Melos workspace definition
├── pubspec.yaml                  # Workspace root (pub workspaces)
├── scripts/
│   └── gen_feature.dart          # Interactive feature scaffold generator
├── packages/
│   ├── flutter_kit_core/         # BaseBloc, BaseCubit, BaseState, validators
│   ├── flutter_kit_network/      # Dio, interceptors, Result<T,E>, ApiManager
│   ├── flutter_kit_auth/         # AuthManager, AuthBloc, token store
│   ├── flutter_kit_firebase/     # FCM, deep link callback
│   └── flutter_kit_ui/           # Theme, design tokens, ThemeCubit
└── apps/
    └── mobile/                   # Flutter application
        ├── lib/
        │   ├── core/             # DI, navigation, config, splash, localization
        │   └── features/         # Feature modules
        └── test/                 # Unit + bloc tests
```

### Package Dependency Graph

```
flutter_kit_core        (independent)
flutter_kit_network     (independent)
flutter_kit_ui          (independent)
flutter_kit_firebase    (independent)
flutter_kit_auth        → flutter_kit_network, flutter_kit_core
apps/mobile             → all 5 packages
```

> `flutter_kit_firebase` must NOT import `flutter_kit_auth` or any navigation package — circular dependency. Use the callback pattern instead (see Deep Link section).

---

## Setup

```bash
# Activate Melos globally (one-time)
dart pub global activate melos

# Bootstrap workspace from the root directory
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
│   ├── firebase/           # FirebaseOptions per flavor (dev/staging/prod)
│   ├── initialize/         # Initialize — startup orchestrator
│   ├── localization/       # slang_flutter i18n files
│   ├── managers/
│   │   ├── device_info_manager/
│   │   └── navigation_manager/ # AppNavigator, GoRouter, auth guard
│   └── splash/             # SplashScreen, SplashNavigator
└── features/
    ├── login/
    ├── register/
    ├── pokemon_home/
    ├── pokemon_detail/
    ├── pokemon_favorites/
    └── favorites/
```

---

## Flavors

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

### Build-time Secrets

Sensitive values (API keys, tokens) are passed via `--dart-define` at build time, never hardcoded.

#### Firebase

Each flavor requires its own `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) from the Firebase console. These files are gitignored and must be added manually:

1. Create three Firebase projects (or one with multiple apps): `dev`, `staging`, `prod`
2. Download the config files for each and place them:

```
android/app/src/dev/google-services.json
android/app/src/staging/google-services.json
android/app/src/prod/google-services.json

ios/config/dev/GoogleService-Info.plist
ios/config/staging/GoogleService-Info.plist
ios/config/prod/GoogleService-Info.plist
```

3. Regenerate the Dart options files:

```bash
# Run once per Firebase project
flutterfire configure --project=my-project-dev \
  --out=apps/mobile/lib/core/firebase/firebase_options_dev.dart

flutterfire configure --project=my-project-staging \
  --out=apps/mobile/lib/core/firebase/firebase_options_staging.dart

flutterfire configure --project=my-project-prod \
  --out=apps/mobile/lib/core/firebase/firebase_options_prod.dart
```

The correct `FirebaseOptions` file is selected automatically at startup based on the active flavor.

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
            └── route to ShellNavigator.dashboardPath
```

---

## Dependency Injection

GetIt is used. All registrations live in `apps/mobile/lib/core/di/injection.dart`.

Module registration order is **mandatory**:

```
1. setupNetworkModule   → FlutterSecureStorage, TokenStore, ApiManager
2. setupAuthModule      → AuthRemoteDataSource, AuthRepository, AuthManager, AuthBloc
                          (requires ApiManager and TokenStore)
3. setupNavigationModule → GoRouter, AppNavigator
                           (requires AuthBloc)
```

Changing this order causes `Object not registered` at runtime.

```dart
// Access from anywhere
final authManager = getIt<AuthManager>();
final router = getIt<GoRouter>();
```

---

## Networking — flutter_kit_network

Built on `DioClient`. All requests go through the `ApiManager` interface.

### Interceptors

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

### Result Pattern

Every async operation returns `Result<T, ApiError>`. Never throws, never uses try/catch at the call site:

```dart
result.when(
  ok: (data) => emit(state.copyWith(isLoading: false, items: data)),
  err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
);
```

Common mistake — forgetting to emit in the `err` branch leaves `isLoading: true` forever:

```dart
result.when(
  ok: (data) => emit(state.copyWith(data: data)),
  err: (_) {},  // BUG: isLoading never becomes false
);
```

---

## Auth — flutter_kit_auth

`AuthManager` handles token storage, session state, and all auth operations. Created via `AuthManager.create()` and registered in GetIt — no static singleton.

```dart
final auth = getIt<AuthManager>();

auth.isLoggedIn    // bool
auth.profile       // Profile?
auth.tokens        // AuthTokens?
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

All methods return `Result<T, ApiError>`:

```dart
final result = await auth.login(email, password);
result.when(
  ok: (_) => HomeNavigator.show(context),
  err: (e) => showSnackbar(e.message),
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
    └── onReady()    → post-frame callback, use for initial data load
    └── onInit()     → called when bloc is created

BaseCubit<S extends BaseState>
    └── safeEmit()   → skips emit if cubit is already closed (prevents crash in async callbacks)

BaseState
    └── isLoading    → shows LoadingOverlay automatically
    └── isValid      → for form validation
    └── errorMessage → error state
```

Always use `safeEmit()` instead of `emit()` inside async callbacks in a Cubit:

```dart
void doSomething() async {
  final result = await someApi();
  safeEmit(state.copyWith(data: result)); // no-op if cubit was closed while awaiting
}
```

### Screen Definition

Always use `BaseBlocView` — never construct a `Bloc()` directly inside a widget:

```dart
class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseBlocView<MyBloc, MyState>(
      create: () => MyBloc(getIt<MyRepository>()),
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

Infinite-scroll lists use `PaginatedBloc` mixin. Only `fetchPage()` and `paginatedState()` need to be implemented:

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
  MyListState paginatedState({required List<MyItem> items, required bool hasMore,
      required int offset, required bool isLoading, String? errorMessage}) =>
      state.copyWith(items: items, hasMore: hasMore, offset: offset,
          isLoading: isLoading, errorMessage: errorMessage);
}
```

### ActiveCubitHelper

When the same screen type can be open more than once in the navigation stack (e.g., two different user profiles), use `activeKey` to distinguish instances in GetIt:

```dart
BaseBlocView<ProfileCubit, ProfileState>(
  activeKey: userId,
  create: () => ProfileCubit(userId: userId),
  ...
)

// Access from another widget
final cubit = getActive<ProfileCubit>(key: userId);
```

Without a key, `_default_ProfileCubit` is used — assumes a single instance of that type.

---

## Navigation — Navigator Pattern

GoRouter is used. Every feature owns a navigator file that is the single source of truth for its route path.

```dart
// feature_navigator.dart
class DashboardNavigator {
  static const path = '/dashboard';

  static GoRoute route() => GoRoute(
    path: path,
    builder: (context, state) => const DashboardScreen(),
  );

  static void show(BuildContext context) => context.go(path);
}
```

All navigators are registered with `AppNavigator`, which assembles the `GoRouter` and manages the auth redirect guard.

**Rule: never call `context.go('/some-path')` directly. Always use the navigator:**

```dart
// Correct
DashboardNavigator.show(context);

// Wrong — path strings must live only in the navigator
context.go('/dashboard');
```

---

## Firebase — flutter_kit_firebase

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

```dart
final token = await NotificationManager.instance.getToken();
```

### Deep Link — Callback Pattern

`flutter_kit_firebase` does **not** import GoRouter or any auth package. Importing them would create a `firebase → navigation → auth → firebase` cycle. Instead, a static callback is set at app startup:

```dart
// In main_*.dart, after GoRouter is created
NotificationDeepLinkHandler.onNavigate = (path, params) {
  getIt<GoRouter>().go(path, extra: params);
};
```

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

After adding a new key:

```bash
dart run slang
```

---

## Validator — flutter_kit_core

```dart
final emailValidator = FieldValidator<String>([
  Validators.required(),
  Validators.email(),
  Validators.maxLength(100),
]);

final error = emailValidator.validate(state.email); // first error or null

final result = emailValidator.validateAll(state.email);
result.isValid;  // bool
result.errors;   // List<String>
```

`FormValidator` tracks multiple fields:

```dart
FormValidator get _form => FormValidator({
  'email':    () => emailValidator.validate(state.email),
  'password': () => passwordValidator.validate(state.password),
});

bool canSubmit = _form.isValid;
String? emailError = _form.errorFor('email');
```

**Available rules:** `required`, `email`, `minLength`, `maxLength`, `min`, `max`, `range`, `pattern`, `equals`, `custom`

---

## Adding a New Feature

### 1. Generate the scaffold

```bash
dart run scripts/gen_feature.dart
```

The interactive script prompts for a feature name, asks whether it needs pagination, and generates all files (bloc, event, state, screen, navigator, use case stubs, repository interface + impl).

### 2. Folder structure (generated)

```
apps/mobile/lib/features/my_feature/
├── bloc/
│   ├── my_feature_bloc.dart
│   ├── my_feature_event.dart
│   └── my_feature_state.dart
├── data/
│   ├── dto/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── view/
    ├── my_feature_navigator.dart
    └── my_feature_screen.dart
```

### 3. Register with DI

```dart
// In injection.dart
getIt.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(getIt<ApiManager>()),
);
```

### 4. Register the route

```dart
// In AppNavigator (or equivalent router file)
MyFeatureNavigator.route(),
```

Navigation is always done through the navigator:

```dart
MyFeatureNavigator.show(context);
```

---

## Testing

Tests live alongside each package and the app:

```
apps/mobile/test/          # BLoC, use case, repository tests for the app
packages/flutter_kit_auth/test/
packages/flutter_kit_core/test/
packages/flutter_kit_network/test/
```

### Run all tests

```bash
melos test
```

### Run a single package

```bash
cd packages/flutter_kit_auth
flutter test
```

### Regenerate mocks

```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

### Test pattern

```dart
@GenerateMocks([MyRepository])
void main() {
  late MockMyRepository mockRepo;
  late MyBloc bloc;

  setUp(() {
    provideDummy<Result<MyEntity, ApiError>>(Ok(MyEntity()));
    mockRepo = MockMyRepository();
    bloc = MyBloc(mockRepo);
  });

  tearDown(() async => bloc.close());

  test('emits loaded state on success', () async {
    when(mockRepo.getItems()).thenAnswer((_) async => Ok([MyEntity()]));

    bloc.add(const MyFetched());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<MyState>().having((s) => s.isLoading, 'loading', true),
        isA<MyState>().having((s) => s.items.length, 'items', 1),
      ]),
    );
  });
}
```

Use `@GenerateNiceMocks([MockSpec<ConcreteClass>()])` for concrete classes (e.g., `FlutterSecureStorage`). Use `provideDummy<Result<T,E>>(Ok(...))` whenever a mock returns a generic `Result` type.

---

## Melos Commands

```bash
melos bootstrap       # Install dependencies (first setup or after pubspec changes)
melos analyze         # Lint all packages
melos test            # Run all tests
melos format          # Format code
melos format:check    # Format check (CI — does not write files)
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
| `flutter_secure_storage` | Encrypted token storage |
| `shared_preferences` | Lightweight local storage |
| `sqflite` | Local SQLite database |
| `slang_flutter` | Localization |
| `equatable` | Value equality |
| `connectivity_plus` | Network status |
| `app_links` | Deep linking |
| `flutter_native_splash` | Native splash screen |
| `flutter_screenutil` | Responsive sizing |
| `cached_network_image` | Image caching |
| `melos` | Monorepo management |
