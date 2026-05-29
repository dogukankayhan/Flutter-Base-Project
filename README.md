# Flutter Base Project

Production-ready Flutter starter template. Includes Clean Architecture, BLoC pattern, Firebase, RevenueCat, and security infrastructure.

---

## Table of Contents

- [Project Structure](#project-structure)
- [Flavors](#flavors)
- [Startup Flow](#startup-flow)
- [Dependency Injection](#dependency-injection)
- [Networking — ApiManager](#networking--apimanager)
- [Auth — AuthManager](#auth--authmanager)
- [BLoC Architecture](#bloc-architecture)
- [Navigation](#navigation)
- [Firebase](#firebase)
- [Notification Manager](#notification-manager)
- [RevenueCat](#revenuecat)
- [Security — Jailbreak / Root Detection](#security--jailbreak--root-detection)
- [Theme](#theme)
- [Localization](#localization)
- [Validator](#validator)
- [Adding a New Feature](#adding-a-new-feature)

---

## Project Structure

```
lib/
├── core/
│   ├── base_bloc/          # BaseBloc, BaseCubit, BaseBlocView, PaginatedBloc
│   ├── config/             # AppEnvironment, AppConfig
│   ├── deeplink/           # DeepLinkManager
│   ├── di/                 # GetIt injection setup
│   ├── domain/             # BaseRepository, BaseUseCase
│   ├── enums/              # SvgEnum, PngEnum (asset helpers)
│   ├── firebase/           # FirebaseOptions per flavor
│   ├── initialize/         # Initialize — app startup orchestrator
│   ├── localization/       # slang_flutter i18n
│   ├── managers/
│   │   ├── auth_manager/   # AuthManager + AuthBloc + Social Auth
│   │   ├── device_info_manager/
│   │   ├── navigation_manager/  # AppRouter, GoRouter, guards
│   │   ├── notification_manager/
│   │   └── revenuecat_manager/
│   ├── networking/         # ApiManager, interceptors, Result, ApiError
│   ├── security/           # JailbreakDetector, JailbreakBlockApp
│   ├── splash/             # SplashScreen, SplashCoordinator
│   ├── theme/              # AppTheme, AppColors, AppTextTheme
│   ├── utils/validator/    # Form and field validation system
│   └── widgets/            # AppImage, AuthGate, LoadingOverlay
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

**Running:**

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

**Accessing environment info via `AppConfig`:**

```dart
AppConfig.instance.baseUrl       // API base URL
AppConfig.instance.isProd        // bool
AppConfig.instance.environment   // AppEnvironment enum
```

---

## Startup Flow

`Initialize.prepare(env)` → `runApp()` → `SplashScreen` → `Initialize.run()` → navigation

```
main_dev.dart
    └── mainCommon(AppEnvironment.dev)
            ├── Initialize.prepare(env)
            │       ├── AppConfig.init(env)
            │       ├── Firebase.initializeApp(options)
            │       ├── Injection.init()           ← all DI
            │       └── LocaleSettings + ThemeCubit
            └── runApp(...)

SplashScreen (displayed)
    └── Initialize.run()
            ├── NotificationManager.instance.init()
            └── JailbreakDetector.isDeviceCompromised()
                    ├── compromised → runApp(JailbreakBlockApp())
                    └── safe       → context.go('/home')
```

---

## Dependency Injection

GetIt is used. All registrations are in `lib/core/di/injection.dart`.

```dart
// Registration (inside Injection.init())
getIt.registerLazySingleton<AuthManager>(() => AuthManager.instance);
getIt.registerLazySingleton<GoRouter>(() { ... });

// Usage (from anywhere)
final authManager = getIt<AuthManager>();
final router = getIt<GoRouter>();
```

**Adding a new service:**

```dart
// Add to injection.dart
getIt.registerLazySingleton<MyService>(() => MyService());

// Usage in a Bloc
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final MyService _service = getIt<MyService>();
  ...
}
```

---

## Networking — ApiManager

Built on top of `DioClient`. All requests pass through the `ApiManager` interface.

### Interceptors (run automatically)

| Interceptor | Responsibility |
|---|---|
| `AuthInterceptor` | Attaches `Authorization: Bearer <token>` to every request |
| `RefreshTokenInterceptor` | Refreshes the token on 401 and retries the request |
| `ConnectivityInterceptor` | Throws an error when there is no internet connection |
| `RetryInterceptor` | Retries up to 3x on network errors |
| `CacheInterceptor` | Caches GET responses |
| `RateLimiterInterceptor` | Flood protection per endpoint |
| `LoggingInterceptor` | Logs requests/responses in dev environment |

### Usage

`ApiManager` is not used directly; the **repository** → **usecase** → **bloc** chain is followed.

```dart
// Inside a repository implementation
final response = await apiManager.get<Map<String, dynamic>>(
  path: '/users/me',
);

final response = await apiManager.post<Map<String, dynamic>>(
  path: '/auth/login',
  body: {'email': email, 'password': password},
);

final response = await apiManager.patch<Map<String, dynamic>>(
  path: '/users/me',
  body: {'firstName': 'Ali'},
);
```

### Result Pattern

Every API response returns `Result<T, ApiError>`, handled with `when`:

```dart
final result = await apiManager.get<Map<String, dynamic>>(path: '/items');

result.when(
  ok: (data) {
    final item = MyModel.fromJson(data);
    emit(state.copyWith(item: item, isLoading: false));
  },
  err: (error) {
    emit(state.copyWith(errorMessage: error.message, isLoading: false));
  },
);
```

### ApiError

```dart
error.message        // user-facing error message
error.statusCode     // HTTP status code (nullable)
error.type           // ApiErrorType enum
```

---

## Auth — AuthManager

Singleton. Manages token storage, session state, and all authentication operations.

`AuthManager.init(...)` is called during `Injection.init()`. On startup, persisted tokens are loaded automatically and a `/me` request is made.

### Access

```dart
final auth = AuthManager.instance;   // getIt<AuthManager>() also works

auth.isLoggedIn    // bool
auth.profile       // Profile? (id, email, firstName, lastName, avatarUrl)
auth.tokens        // AuthTokens? (accessToken, refreshToken)
```

### Methods

```dart
// Email / password
await auth.login(email, password);
await auth.register(email: email, password: password);
await auth.logout();

// Social auth
await auth.signInWithApple(idToken);
await auth.signInWithGoogle(idToken);
await auth.signInAsGuest();

// Profile
await auth.fetchMe();
await auth.updateProfile({'firstName': 'Ali'});

// Token
await auth.refreshIfNeeded();
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

Listens to `AuthManager` and keeps auth state reactive. The router and global UI subscribe here.

```dart
// Already registered in Injection.init()
getIt.registerLazySingleton<AuthBloc>(() => AuthBloc());

// Access
final authBloc = getIt<AuthBloc>();
authBloc.state.isAuthenticated
authBloc.state.profile

// Dispatch an event
authBloc.add(const AuthLogoutRequested());
```

### Token Management

Tokens are stored encrypted via `flutter_secure_storage`. `RefreshTokenInterceptor` automatically refreshes on 401; if refresh fails, the session is cleared and the router redirects to login.

---

## BLoC Architecture

### Layers

```
BaseBloc / BaseCubit
    └── authManager  → getIt<AuthManager>()   (auto-injected)
    └── apiManager   → getIt<ApiManager>()    (auto-injected)

BaseState
    └── isLoading    → LoadingOverlay shown automatically
    └── isValid      → for form validation
    └── errorMessage → error state

BaseBlocView<C, S>
    └── create       → creates and disposes the bloc
    └── builder      → provides access to state and bloc
    └── activeKey    → distinguishes multiple screens of the same type
    └── onInit       → called when the bloc is created
    └── onReady      → called after widget renders (post-frame)
    └── onDispose    → called when the screen closes
```

### Feature BLoC Structure

```
features/my_feature/
├── bloc/
│   ├── my_feature_event.dart
│   ├── my_feature_state.dart
│   └── my_feature_bloc.dart
└── view/
    └── my_feature_screen.dart
```

### Defining State

```dart
class MyState extends BaseState {
  final List<MyItem> items;
  final MyItem? selectedItem;

  const MyState({
    this.items = const [],
    this.selectedItem,
    super.isLoading,
    super.errorMessage,
  });

  MyState copyWith({
    List<MyItem>? items,
    MyItem? selectedItem,
    bool? isLoading,
    String? errorMessage,
  }) => MyState(
    items: items ?? this.items,
    selectedItem: selectedItem ?? this.selectedItem,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [...super.props, items, selectedItem];
}
```

### Defining Events

```dart
sealed class MyEvent extends Equatable {
  const MyEvent();
  @override
  List<Object?> get props => [];
}

class MyFetched extends MyEvent { const MyFetched(); }
class MyRefreshed extends MyEvent { const MyRefreshed(); }
class MyItemSelected extends MyEvent {
  final String id;
  const MyItemSelected(this.id);
  @override
  List<Object?> get props => [id];
}
```

### Defining a Bloc

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  MyBloc() : super(const MyState()) {
    on<MyFetched>(_onFetched);
    on<MyRefreshed>(_onRefreshed);
    on<MyItemSelected>(_onItemSelected);
  }

  // Runs automatically after the widget renders — not in initState!
  @override
  void onReady() => add(const MyFetched());

  Future<void> _onFetched(MyFetched event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));

    // In a real project, use a repository/usecase:
    // final result = await _getItemsUseCase();
    // result.when(
    //   ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
    //   err: (error) => emit(state.copyWith(isLoading: false, errorMessage: error.message)),
    // );

    // Direct apiManager usage:
    // final response = await apiManager.get<List<dynamic>>(path: '/items');
    // response.when(...);
  }

  Future<void> _onRefreshed(MyRefreshed event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true));
    await _onFetched(const MyFetched(), emit);
  }

  void _onItemSelected(MyItemSelected event, Emitter<MyState> emit) {
    final item = state.items.firstWhere((i) => i.id == event.id);
    emit(state.copyWith(selectedItem: item));
  }
}
```

### Defining a Screen

```dart
class MyScreen extends StatelessWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<MyBloc, MyState>(
      create: () => MyBloc(),
      // LoadingOverlay is shown automatically when state.isLoading is true
      builder: (context, state, bloc) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Screen'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => bloc.add(const MyRefreshed()),
              ),
            ],
          ),
          body: state.errorMessage != null
              ? Center(child: Text(state.errorMessage!))
              : ListView.builder(
                  itemCount: state.items.length,
                  itemBuilder: (_, i) => ListTile(
                    title: Text(state.items[i].title),
                    onTap: () => bloc.add(MyItemSelected(state.items[i].id)),
                  ),
                ),
        );
      },
    );
  }
}
```

### PaginatedBloc

A mixin for lists that require pagination:

```dart
class MyListBloc extends BaseBloc<MyListEvent, MyListState>
    with PaginatedBloc<MyItem, MyListEvent, MyListState> {

  MyListBloc() : super(const MyListState()) {
    on<MyListStarted>((e, emit) => handleLoadInitial(emit));
    on<MyListLoadMore>((e, emit) => handleLoadMore(emit));
    on<MyListRefreshed>((e, emit) => handleLoadInitial(emit));
  }

  @override
  void onReady() => add(MyListStarted());

  @override
  Future<(List<MyItem>, bool, int)> fetchPage(int offset, int size) async {
    // Fetch a page from the API; return (items, hasMore, nextOffset)
    final items = await _repository.getPage(offset: offset, size: size);
    return (items, items.length >= size, offset + items.length);
  }

  @override
  MyListState paginatedState({
    List<MyItem>? items,
    bool? hasMore,
    int? nextOffset,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) => state.copyWith(
    items: items,
    hasMore: hasMore,
    nextOffset: nextOffset,
    isLoading: isLoading,
    errorMessage: clearError ? null : errorMessage,
  );
}
```

### BaseCubit (without events)

Use `BaseCubit` for form screens:

```dart
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit() : super(const LoginState());

  void setEmail(String value) => safeEmit(state.copyWith(email: value));
  void setPassword(String value) => safeEmit(state.copyWith(password: value));

  Future<void> login() async {
    safeEmit(state.copyWith(isLoading: true));
    final result = await authManager.login(state.email, state.password);
    result.when(
      ok: (_) => safeEmit(state.copyWith(isLoading: false)),
      err: (e) => safeEmit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

> `safeEmit` — does not emit if the bloc is already closed (prevents post-dispose crashes).

### Active Key

When multiple screens of the same type are open, distinguish them with `activeKey`:

```dart
BaseBlocView<DetailBloc, DetailState>(
  create: () => DetailBloc(itemId),
  activeKey: 'detail-$itemId',   // unique per instance
  builder: (context, state, bloc) => ...,
);

// Access from another widget
final bloc = getActiveOrNull<DetailBloc>(key: 'detail-$itemId');
bloc?.add(SomeEvent());
```

---

## Navigation

GoRouter is used. Access the router via `getIt<GoRouter>()`.

### Adding a Route

Add routes to `lib/core/managers/navigation_manager/app_router.dart`:

```dart
GoRoute(
  path: '/my-screen',
  parentNavigatorKey: rootKey,
  pageBuilder: (context, state) => fadeTransitionPage(
    key: state.pageKey,
    child: const MyScreen(),
  ),
),
```

### Coordinator Pattern (recommended)

```dart
final class MyCoordinator {
  MyCoordinator._();

  static const String path = '/my-screen';

  static GoRoute route(GlobalKey<NavigatorState> parentKey) {
    return GoRoute(
      path: path,
      parentNavigatorKey: parentKey,
      builder: (context, state) => const MyScreen(),
    );
  }
}
```

### Navigating

```dart
context.go('/my-screen');               // Replace
context.push('/my-screen');             // Push
context.go('/my-screen', extra: data);  // Pass data
context.pop();                          // Go back
```

### Auth Guard

Add a guard to routes that require authentication:

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

## Firebase

A separate `FirebaseOptions` file exists for each flavor:

```
lib/core/firebase/
├── firebase_options_dev.dart
├── firebase_options_staging.dart
└── firebase_options_prod.dart
```

The correct file is selected automatically in `Initialize._initFirebase(env)`. No manual intervention required.

**To connect a new Firebase project:**

```bash
flutterfire configure --project=my-project-dev --out=lib/core/firebase/firebase_options_dev.dart
flutterfire configure --project=my-project-prod --out=lib/core/firebase/firebase_options_prod.dart
```

---

## Notification Manager

FCM + `flutter_local_notifications` integration. Single instance: `NotificationManager.instance`.

Initialised inside `Initialize.run()` (during the splash screen).

### Channel System

```dart
enum AppNotificationChannel {
  general,      // General notifications
  promotional,  // Campaigns (with images)
  critical,     // Critical / security notifications
}
```

### FCM Token

```dart
final token = await NotificationManager.instance.getToken();
// Send the token to your backend
```

### Payload Structure

FCM data fields sent from the backend:

| Field | Type | Description |
|---|---|---|
| `path` | String | Route to navigate to (`/home`, `/store`) |
| `tab` | String | Tab index (e.g. `"2"`) |
| `action_type` | String | `navigate`, `open_url`, `dismiss`, `approval` |
| `image_url` | String | Notification image |
| `url` | String | URL to open |
| `params` | JSON String | Extra route parameters |
| `approval_id` | String | ID for approval action notifications |

### Deep Link Handler

When a notification is tapped, `NotificationDeepLinkHandler.handle(payload)` runs and navigates to `payload.path`.

To customise the behaviour, edit the `_navigate` method in `notification_deep_link_handler.dart`.

### Approval Notifications

When the user taps "Approve" / "Reject":

```dart
// While the app is in the foreground
NotificationManager.instance.onApprovalAction = (approvalId, isApproved) async {
  if (isApproved) {
    await myService.approve(approvalId);
  } else {
    await myService.reject(approvalId);
  }
};
```

---

## RevenueCat

In-app purchase and subscription management. Single instance: `RevenueCatManager.instance`.

Update the `StoreProductIds` constants with your own product IDs:

```
lib/core/managers/revenuecat_manager/constants/store_product_ids.dart
```

### Initialisation

```dart
// At app startup (inside Initialize.run or Injection)
await RevenueCatManager.instance.init();

// After the user logs in
await RevenueCatManager.instance.logIn(userId);

// After the user logs out
await RevenueCatManager.instance.logOut();
```

### Loading Products

```dart
final offerings = await RevenueCatManager.instance.fetchOfferings();

// Consumable packs
final packs = RevenueCatManager.instance.buildCrystalPacks(offerings);

// Subscription plans
final plans = RevenueCatManager.instance.buildSubscriptionPlans(offerings);
```

### Purchasing

```dart
final result = await RevenueCatManager.instance.purchase(package);

result.when(   // PurchaseResult sealed class
  (success) => handleSuccess(success.productId),
  (cancelled) => showMessage('Cancelled'),
  (failure) => showError(failure.message),
  (restore) => handleRestore(restore.hasPremium),
);
```

### Checking Premium Entitlement

```dart
final isPremium = await RevenueCatManager.instance.hasPremiumEntitlement();
```

---

## Security — Jailbreak / Root Detection

Uses a native platform channel to detect jailbroken (iOS) or rooted (Android) devices.

```dart
final isCompromised = await JailbreakDetector.isDeviceCompromised();
```

Checked automatically inside `Initialize.run()`. If the device is compromised, `JailbreakBlockApp` is displayed and the application becomes unusable.

The channel must be implemented on the native side (`ios/Runner/JailbreakDetector.swift` and its Android equivalent). Update the `com.base.project/security` channel ID with your own bundle ID.

---

## Theme

```dart
// Change theme mode
context.read<ThemeCubit>().setLight();
context.read<ThemeCubit>().setDark();
context.read<ThemeCubit>().setSystem();

// Using colours
AppColors.primary
AppColors.background
AppColors.error

// Using text styles
AppTextTheme.titleLarge
AppTextTheme.bodyMedium
```

Theme is managed by `ThemeCubit` and persisted to `SharedPreferences`.

---

## Localization

`slang_flutter` is used. Translation files:

```
lib/core/localization/i18n/
├── en.i18n.json
└── tr.i18n.json
```

**Usage:**

```dart
// Inside a widget
Text(context.t.someKey)

// In Dart code
final str = LocaleSettings.currentLocale.translations.someKey;
```

**Adding a new key:**

1. Add the key to both `en.i18n.json` and `tr.i18n.json`
2. Run `dart run slang` to regenerate

**Changing language:**

```dart
LocaleSettings.setLocale(AppLocale.tr);
LocaleSettings.setLocale(AppLocale.en);
```

---

## Validator

Fluent API for form validation:

```dart
// Field validator
final validator = FieldValidator<String>()
  .required()
  .email()
  .maxLength(100);

// Usage in a form widget
TextFormField(
  validator: validator.build(),
)

// Multiple rules
final passwordValidator = FieldValidator<String>()
  .required()
  .minLength(8)
  .pattern(RegExp(r'[A-Z]'), message: 'At least one uppercase letter required')
  .custom((value) => value != email ? null : 'Password cannot match email');
```

**Available rules:** `required`, `email`, `minLength`, `maxLength`, `min`, `max`, `range`, `pattern`, `equals`, `custom`

---

## Adding a New Feature

### 1. Create the folder structure

```
lib/features/my_feature/
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
    ├── my_feature_screen.dart
    └── widgets/
```

### 2. Define the entity and repository

```dart
// domain/entities/my_item.dart
class MyItem {
  final String id;
  final String title;
  const MyItem({required this.id, required this.title});
}

// domain/repositories/my_repository.dart
abstract class MyRepository {
  Future<Result<List<MyItem>, ApiError>> getItems();
}
```

### 3. Write the use case

```dart
class GetItemsUseCase {
  final MyRepository repository;
  const GetItemsUseCase(this.repository);
  Future<Result<List<MyItem>, ApiError>> call() => repository.getItems();
}
```

### 4. Register with DI

```dart
// Add to lib/core/di/injection.dart
getIt.registerLazySingleton<MyRepository>(
  () => MyRepositoryImpl(getIt<ApiManager>()),
);
getIt.registerLazySingleton<GetItemsUseCase>(
  () => GetItemsUseCase(getIt<MyRepository>()),
);
```

### 5. Write the Bloc

```dart
class MyBloc extends BaseBloc<MyEvent, MyState> {
  final GetItemsUseCase _getItems = getIt<GetItemsUseCase>();

  MyBloc() : super(const MyState()) {
    on<MyFetched>(_onFetched);
  }

  @override
  void onReady() => add(const MyFetched());

  Future<void> _onFetched(MyFetched event, Emitter<MyState> emit) async {
    emit(state.copyWith(isLoading: true));
    final result = await _getItems();
    result.when(
      ok: (items) => emit(state.copyWith(isLoading: false, items: items)),
      err: (e) => emit(state.copyWith(isLoading: false, errorMessage: e.message)),
    );
  }
}
```

### 6. Add the route

```dart
// Add to app_router.dart
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
