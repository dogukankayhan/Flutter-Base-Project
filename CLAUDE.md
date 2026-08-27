# CLAUDE.md — Flutter Base Kit Monorepo Guide

This file is prepared for AI assistants and new developers to understand the project codebase quickly.

---

## AI Coding Rules — Screen & API Wiring Recipe

When asked to build a screen or connect it to an API, follow these rules in order without asking — no clarification needed unless a field name is genuinely ambiguous.

### Rule 1 — New screen: decide Bloc vs Cubit first, then build on BaseBlocView

| Use | When |
|---|---|
| `BaseCubit` | No discrete events: load-and-show, toggles, tab/selection state, simple forms |
| `BaseBloc` | Discrete user events, multi-step flows, event transformers/debounce |
| `BaseBloc` + `PaginatedBloc` mixin | Infinite-scroll lists (see Critical Pattern 8) |

Every screen is a `StatelessWidget` wrapping `BaseBlocView` — the view never owns state:

```dart
class XxxScreen extends StatelessWidget {
  const XxxScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseBlocView<XxxCubit, XxxState>(
      create: () => XxxCubit(),
      builder: (context, state, cubit) => Scaffold(/* build UI from state */),
    );
  }
}
```

See Critical Pattern 3 for the exact lifecycle (`create()` → `onReady()` → `close()`) and Critical Pattern 4 for `safeEmit`. Every `Result.when` err branch must also clear `isLoading` — see Critical Pattern 2.

### Rule 2 — Screen-private widgets: `view/widgets/` with part / part of

See Critical Pattern 9 below.

### Rule 3 — Endpoint wiring chain

"Connect screen X to API Y" always creates this chain, in this order:

1. `core/service/api/<feature>_api.dart` — endpoint classes (Rule 4)
2. `core/domain/entity/<feature>_entity.dart` — request + response entities (pure Dart, no JSON)
3. `core/data/dto/<feature>_dto.dart` — `XxxRequestDto.fromEntity()` + `XxxResponseDto.fromJson()`/`toDomain()`
4. `core/domain/repository/<feature>_repository.dart` — abstract interface, returns `Result<Entity, ApiError>`
5. `core/data/repository/<feature>_repository_impl.dart` — `ApiManager` calls directly, no separate datasource layer; `on ApiException catch (e) => Err(e.error)`
6. `core/domain/usecase/<verb>_<feature>_usecase.dart` — passes the Result through, no try/catch
7. `core/di/modules/` — register the **repository only** (see DI rules below); use cases are **not** registered
8. Bloc/Cubit — use cases are built **here**, inline in a `.create` factory from the registered repository

Data must flow through the layers in this exact shape:

```
Request : Entity ──fromEntity()──▶ RequestDto ──▶ Endpoint.query/body(dto) ──▶ ApiManager
Response: JSON ──fromJson()──▶ ResponseDto ──toDomain()──▶ Entity ──▶ bloc/cubit state property (viewmodel)
```

**DI rules:**

Only **repositories** live in GetIt. A stateless pass-through use case carries no data, so registering it buys nothing — it is built inline instead. The bloc/cubit exposes two constructors:

- **Primary (unnamed) constructor** — pure, never touches `getIt`; takes every use case + repository as a named parameter. This is the **test seam**: tests pass mocks straight in.
- **`.create` named factory** — the only `getIt`-touching spot; resolves the repository **once** and builds each use case inline from it. `BaseBlocView` wires it with `create: XxxCubit.create`.

```dart
class XxxCubit extends BaseCubit<XxxState> {
  // Pure — the constructor tests use:
  XxxCubit({
    required GetXxxUseCase getXxx,
    required XxxRepository repo,
  }) : _getXxx = getXxx,
       _repo = repo,
       super(const XxxState());

  // Production wiring — resolve the repo once, build use cases from it:
  factory XxxCubit.create() {
    final repo = getIt<XxxRepository>();
    return XxxCubit(getXxx: GetXxxUseCase(repo), repo: repo);
  }
}
```

- Never resolve `getIt`/use cases inside a view or widget — wiring lives in `.create`.
- **Stateful repository** (holds a cache, a broadcast stream, session data) → `registerLazySingleton` — the shared instance is the point.
- **Stateless repository** (pure endpoint pass-through, keeps no data) → `registerFactory` — no reason for a permanent instance to sit in memory; a fresh one is created per resolution and garbage-collected afterwards. Resolve it **once** in `.create` (not per use case) so a factory repo isn't rebuilt N times.

```dart
// Holds cache + stream → single shared instance:
getIt.registerLazySingleton<FavoritesRepository>(() => FavoritesRepositoryImpl(...));
// Stateless pass-through → created on demand, released after use:
getIt.registerFactory<UserRepository>(() => UserRepositoryImpl(getIt<ApiManager>()));
// Use cases are NOT registered — they are built inside the bloc/cubit `.create` factory.
```

> Managers that are themselves DI singletons (e.g. `AuthManager`) or non-use-case deps (a callback/function) are still resolved via a `x ?? getIt<X>()` fallback in a single constructor — the `.create` split only pays off for features that own use cases. See `LoginBloc`.

> `flutter_kit_auth` is the reference implementation of this whole chain — see `AuthRepositoryImpl` (endpoint calls, no datasource layer) and the `password_reset_*` files (a from-scratch example built to demonstrate the pattern).

### Rule 4 — Endpoint file owns path/query/body; parameters are always Request DTOs

One `abstract final class` per endpoint in `core/service/api/<feature>_api.dart`. Path, query map and body map are defined **only here** — never inline in a datasource or repository impl.

Endpoint static methods take the **Request DTO** — never loose primitives (`id`, `name`, `limit`…). This applies to parametrized paths too:

```dart
abstract final class ListXxxEndpoint {
  static const path = '/xxx';
  static Map<String, dynamic> query(ListXxxRequestDto dto) =>
      {'limit': dto.limit, 'offset': dto.offset};
}

abstract final class GetXxxDetailEndpoint {
  static String path(GetXxxDetailRequestDto dto) => '/xxx/${dto.id}';
}

abstract final class UpdateUserProfileEndpoint {
  static const path = '/user/me';
  static Map<String, dynamic> body(UpdateUserProfileRequestDto dto) =>
      {'firstName': dto.firstName, 'lastName': dto.lastName};
}
```

- Use `'key': ?dto.nullableField` (Dart null-aware map element) to skip entries whose value is null.
- Response DTO `fromJson` always parses with `as T? ?? fallback` — never assume the API sends non-null.

> `apps/mobile/lib/core/service/api/user_api.dart` predates this rule and still takes loose primitives — treat it as legacy, not as a pattern to copy from; new endpoints follow Rule 4 as written above.

### Rule 5 — Navigator owns navigation AND screen-to-screen data

Every feature has a navigator file owning its `GoRoute` and a `show()` method. When a screen needs data from the caller, that data is a **typed parameter of `show()`** and travels via `extra` (or a path param). Raw `context.push('/route', extra: x)` at call sites is forbidden, as is constructing another feature's screen widget directly.

```dart
final class XxxDetailNavigator {
  static const String path = '/xxx/detail';

  static GoRoute get route => GoRoute(
    path: 'detail',
    builder: (_, state) => XxxDetailScreen(item: state.extra as XxxEntity),
  );

  /// The ONLY way to open this screen — the data contract is explicit and typed.
  static void show(BuildContext context, {required XxxEntity item}) {
    context.go(path, extra: item);
  }
}

// Caller:
XxxDetailNavigator.show(context, item: selected);
```

- The route path string exists in exactly one file: the navigator.
- If the caller already owns the entity, pass the entity — do not pass an id and refetch.

---

## Project Identity

Flutter monorepo: `flutter_base_kit_workspace`
- Orchestrated via **Pub workspaces** + **Melos**
- 3 flavors: `dev`, `staging`, `prod`
- Main application: `apps/mobile/`
- Shared packages: `packages/flutter_kit_*/`

---

## Package Dependency Graph

```
flutter_kit_core        (independent — BLoC base, validator)
flutter_kit_network     (independent — Dio, interceptors, Result<T,E>)
flutter_kit_ui          (independent — theme, design tokens)
flutter_kit_firebase    (independent — FCM, deep link callback)
flutter_kit_auth        (dependent on network + core)
apps/mobile             (dependent on all 5 packages)
```

**Rule:** `flutter_kit_firebase` → `flutter_kit_auth` dependency is forbidden (circular). Resolved via the deep link routing callback pattern (see below).

---

## Critical Pattern 1: Navigator

Each feature has a `<feature>_navigator.dart` file. This file:
- Contains the `GoRoute` definition
- Exposes the navigation API via a static `show()` method, typed to whatever data the screen needs (see Rule 5)
- Is registered in `AppNavigator.instance`

```dart
// Usage — to open a feature:
DashboardNavigator.show(context);

// Never call context.go('/dashboard') directly, and never push another
// feature's screen with raw context.push(path, extra: x) —
// the path string and the data contract must live only in the navigator.
```

`AppNavigator` (singleton): collects all navigators and provides the route list to GoRouter. The `redirect()` method manages the auth guard.

---

## Critical Pattern 2: Result\<T, E\>

From the `flutter_kit_network` package. All async operations return a `Result` instead of throwing exceptions.

```dart
// Correct usage
final result = await getDashboardUseCase();
result.when(
  ok: (summary) => emit(state.copyWith(summary: summary, isLoading: false)),
  err: (error) => emit(state.copyWith(errorMessage: error.message, isLoading: false)),
);

// Common mistake: forgetting to emit in the err branch — the state hangs
result.when(
  ok: (data) => emit(state.copyWith(data: data)),
  err: (_) {},  // ← BUG: isLoading never becomes false
);
```

`ApiError` fields: `statusCode` (nullable int), `message` (String).

Use cases propagate the Result directly — do not wrap them in try/catch:
```dart
@override
Future<Result<DashboardSummary, ApiError>> call() =>
    _repository.getDashboard(); // pass the repository result as is
```

---

## Critical Pattern 3: BaseBloc + BaseBlocView Lifecycle

```
BaseBlocView.initState()
  └── bloc = create()          ← created from the factory
      └── BaseBloc constructor → on<Event> registrations are made

BaseBlocView: post-frame callback
  └── bloc.onReady()           ← initial data loading goes here
      e.g.: add(DashboardLoadRequested())

BaseBlocView.dispose()
  └── bloc.close()             ← stream is cleared
```

`BaseBlocView` both creates the bloc and manages its lifecycle.  
Do not invoke the `Bloc()` constructor inside a widget — always use `BaseBlocView`.

---

## Critical Pattern 4: safeEmit

The `safeEmit(state)` method of `BaseCubit` prevents the `emit()` call from crashing in async callbacks after the cubit is closed.

```dart
// Use safeEmit instead of emit inside a Cubit:
void doSomething() async {
  final result = await someApi();
  safeEmit(state.copyWith(data: result)); // quietly ignores if the cubit is closed
}
```

---

## Critical Pattern 5: DI Module Order

This order is **mandatory** inside `Injection.init()`:

```
1. setupNetworkModule   → FlutterSecureStorage, TokenStore, ApiManager
2. setupAuthModule      → AuthRepository, AuthManager, AuthBloc
                          (requires ApiManager and TokenStore)
3. setupNavigationModule → GoRouter, AppNavigator
                           (requires AuthBloc)
```

If the order is changed, `Object not registered` error is thrown.

See Rule 3's DI rules above for when a repository is a `registerLazySingleton` vs a `registerFactory` — that choice applies inside every module, not just auth.

---

## Critical Pattern 6: Callback-Based Deep Link

`flutter_kit_firebase` **does not import** GoRouter — doing so would cause a `firebase → navigation → auth → firebase` cycle.

Solution: The `NotificationDeepLinkHandler.onNavigate` static callback is set by the app layer at startup:

```dart
// Inside main_*.dart, after GoRouter is initialized:
NotificationDeepLinkHandler.onNavigate = (path, params) {
  router.go(path, extra: params);
};
```

The same shape resolves `flutter_kit_auth`'s need for a push token without depending on `flutter_kit_firebase`: `setupAuth()` takes an optional `FcmTokenProvider? fcmTokenProvider` callback (`Future<String?> Function()`), wired from the app layer once Firebase is initialized. Left unset, `AuthManager` simply omits the token from login/register/social-sign-in requests.

---

## Critical Pattern 7: ActiveCubitHelper

If the same screen type is open **more than once** in the navigation stack (e.g., two different user profile pages), `activeKey` is used to distinguish the cubit in GetIt.

```dart
// Pass a unique key when opening the screen:
BaseBlocView<ProfileCubit, ProfileState>(
  activeKey: userId,
  create: () => ProfileCubit(userId: userId),
  ...
)

// To access it from another widget:
final cubit = getActive<ProfileCubit>(key: userId);
```

If no key is provided, `_default_ProfileCubit` is used — a single instance of that type is assumed.

---

## Critical Pattern 8: PaginatedBloc

The `PaginatedBloc` mixin is used for infinite-scroll lists. The subclass only implements `fetchPage()` and `paginatedState()`, and the pagination logic is managed by the mixin.

```dart
// Plain BaseBloc is sufficient:
class DashboardBloc extends BaseBloc<DashboardEvent, DashboardState> { ... }

// Add mixin for lists requiring pagination:
class AppointmentBloc extends BaseBloc<AppointmentEvent, AppointmentState>
    with PaginatedBloc<Appointment, AppointmentEvent, AppointmentState> {

  @override
  Future<(List<Appointment>, bool, int)> fetchPage(int offset, int size) =>
      _useCase(offset: offset, size: size);

  @override
  AppointmentState paginatedState({...}) => state.copyWith(...);
}
```

---

## Critical Pattern 9: Screen-Specific Widgets (`part of`)

A widget used by **exactly one** screen lives next to it in a `widgets/` folder and joins the screen's library via `part`/`part of`, instead of being a separately imported file. Classes stay **private** (`_Xxx`) — nothing outside the screen's library can reach them. This avoids re-importing the same entities/utils in every tab/section file and makes the "only this screen uses it" relationship explicit.

```
features/<feature>/view/<feature>_screen.dart       ← part 'widgets/stat_card.dart';
features/<feature>/view/widgets/stat_card.dart       ← part of '../<feature>_screen.dart';
```

```dart
// feature_screen.dart — the library file: all imports live here
import 'package:flutter/material.dart';
// ...other imports needed by the screen AND its parts

part 'widgets/feature_about_tab.dart';
part 'widgets/feature_stats_tab.dart';

class FeatureScreen extends StatelessWidget { ... }
```

```dart
// widgets/feature_about_tab.dart — no imports of its own
part of '../feature_screen.dart';

class _FeatureAboutTab extends StatelessWidget { ... } // only this screen can see it
```

See `pokemon_detail/view/pokemon_detail_screen.dart` (+ `view/widgets/*_tab.dart`) and `pokemon_compare/view/compare_screen.dart` (+ `widgets/pokemon_stat_chart.dart`).

Only components reused across features belong in `core/components/` as public widgets. **If a widget is used by more than one screen** (e.g. `PokemonCard`, used by both `pokemon_home` and `pokemon_favorites`), it must stay a normal standalone file that gets `import`-ed — never make a widget `part of` a screen it isn't exclusive to.

---

## Test Pattern Summary

```dart
@GenerateMocks([AuthManager, SomeUseCase])
void main() {
  late MockAuthManager mockAuthManager;
  late LoginBloc loginBloc;

  setUp(() {
    // Prevents Mockito generic type warnings:
    provideDummy<Result<AuthTokens, ApiError>>(
      Ok(AuthTokens(accessToken: '', refreshToken: null)),
    );
    mockAuthManager = MockAuthManager();
    loginBloc = LoginBloc(authManager: mockAuthManager);
  });

  tearDown(() async => loginBloc.close());

  group('LoginSubmitted — success', () {
    test('emits isLoading then isSuccess', () async {
      when(mockAuthManager.login(any, any))
          .thenAnswer((_) async => Ok(AuthTokens(...)));
      // ...
    });
  });
}
```

To generate mock files:
```bash
cd apps/mobile
dart run build_runner build --delete-conflicting-outputs
```

---

## File Naming Conventions

| File | Name |
|-------|-----|
| Bloc | `feature_bloc.dart` |
| Event | `feature_event.dart` |
| State | `feature_state.dart` |
| Screen | `feature_screen.dart` |
| Screen-only widget (single consumer) | `widgets/feature_thing.dart`, `part of '../feature_screen.dart'` |
| Navigator | `feature_navigator.dart` |
| Endpoint | `core/service/api/feature_api.dart` (Rule 4) |
| Entity | `core/domain/entity/feature_entity.dart` (request + response) |
| DTO | `core/data/dto/feature_dto.dart` |
| Repository (interface) | `core/domain/repository/feature_repository.dart` |
| Repository (impl) | `core/data/repository/feature_repository_impl.dart` |
| Use case | `core/domain/usecase/verb_feature_usecase.dart` |
| Test | `feature_bloc_test.dart` |
| Mocks | `feature_bloc_test.mocks.dart` (auto-generated) |

---

## Melos Commands

```bash
melos bootstrap       # Install dependencies (first setup or pubspec changes)
melos run gen:i18n    # Generate strings*.g.dart (REQUIRED after a fresh checkout)
melos analyze         # Run lint checks in all packages
melos test            # Run tests in all packages
melos format          # Format code
melos format:check    # Check formatting (used in CI, does not modify files)
```

The slang output (`lib/core/localization/i18n/strings*.g.dart`) is **not tracked in git** — its generated header carries a build timestamp and string count, so every merge conflicted on it. A fresh checkout does not compile until `gen:i18n` has run; CI runs it right after `melos bootstrap`. Edit the `.i18n.json` files, never the `.g.dart` output.

---

## DO NOT List

| Forbidden | Reason |
|-------|-------|
| Calling `context.go('/dashboard')` directly | Path string spreads — use `DashboardNavigator.show(context)` |
| Passing screen data with raw `context.push(path, extra: x)` | The navigator's `show()` is the typed data contract (Rule 5) |
| Constructing `Bloc()` inside a widget | `BaseBlocView` manages the lifecycle — always use it |
| Adding `ApiManager` or `AuthManager` as field to `BaseBloc` | Breaks package isolation — inject use case instead |
| Resolving `getIt`/use cases inside a view or widget | Wiring lives in the bloc/cubit `.create` factory (Rule 3) |
| Registering a use case in GetIt | Stateless pass-through — build it inline in `.create` from the repo (Rule 3) |
| Registering a stateless repository as `lazySingleton` | No state to share — `registerFactory`, created per use (Rule 3) |
| Building query/body maps inline in datasource/repo impl | The endpoint class owns the request shape (Rule 4) |
| Endpoint methods taking primitives (`id`, `name`, `limit`) | Always a Request DTO — `Endpoint.query(XxxRequestDto)` (Rule 4) |
| Hardcoding path strings in repository impl | Untestable and cannot change by environment — add default param to constructor |
| Importing `auth` or `router` inside `firebase` package | Circular dependency — use callback pattern |
| Calling `emit()` directly in async callbacks | Crash after cubit is closed — use `safeEmit()` |
| Making a widget `part of` a screen it isn't exclusive to | Breaks reuse — widgets used by 2+ screens must stay standalone, `import`-ed files |
