# Mimari Rehberi

## Katman Diyagramı

```
┌─────────────────────────────────────────────────────┐
│                   Presentation                      │
│  Screen ← BlocBuilder ← Bloc/Cubit                 │
│  BaseBlocView: oluşturma, lifecycle, loading overlay │
├─────────────────────────────────────────────────────┤
│                     Domain                          │
│  UseCase → Repository (interface) → Entity          │
│  Saf Dart: platform bağımsız iş mantığı             │
├─────────────────────────────────────────────────────┤
│                      Data                           │
│  RepositoryImpl → RemoteDataSource → DTO            │
│  fromJson / toDomain dönüşümleri burada             │
├─────────────────────────────────────────────────────┤
│                    Network                          │
│  ApiManager → Dio + 8 Interceptor                   │
│  Result<T, E> tüm yanıtları sarar                   │
└─────────────────────────────────────────────────────┘
```

Bağımlılık yönü: Presentation → Domain → Data → Network. Ters yönde bağımlılık yoktur.

---

## Dashboard Feature — Tam Veri Akışı

Somut örnek üzerinden tüm katmanlar:

```
1. BaseBlocView.initState() → DashboardBloc oluşturulur

2. (post-frame) DashboardBloc.onReady()
   └── add(DashboardLoadRequested())

3. DashboardBloc._onLoad(event, emit)
   └── emit(state.copyWith(isLoading: true))
   └── GetDashboardUseCase.call()

4. GetDashboardUseCase.call()
   └── DashboardRepository.getDashboard()  ← interface

5. DashboardRepositoryImpl.getDashboard()
   └── DashboardRemoteDataSourceImpl.getDashboard(path)

6. DashboardRemoteDataSourceImpl.getDashboard(path)
   └── ApiManager.get<DashboardDto>(path: path)

7. ApiManager (Dio + interceptor zinciri)
   AuthInterceptor       → Bearer token ekler
   ConnectivityInterceptor → çevrimdışıysa hata
   RetryInterceptor      → 5xx'te exponential backoff (3 deneme)
   CacheInterceptor      → GET yanıtlarını SQLite'a önbelleğe alır
   RefreshTokenInterceptor → 401'de token yeniler
   RateLimiterInterceptor → endpoint başına istek sınırı
   LoggingInterceptor    → HTTP log
   CertPinningInterceptor → SSL sertifika doğrulama

8. Yanıt → DashboardDto.fromJson(json)
   └── DashboardMapper.toDomain(dto) → DashboardSummary entity

9. Result<DashboardSummary, ApiError> her katmandan akar yukarı

10. DashboardBloc._onLoad
    result.when(
      ok: (s) => emit(state.copyWith(summary: s, isLoading: false)),
      err: (e) => emit(state.copyWith(errorMessage: e.message, isLoading: false)),
    )

11. DashboardScreen: BlocBuilder yeni state'i alır, UI güncellenir
    isLoading: true  → BaseBlocView LoadingOverlay gösterir
    errorMessage set → AppErrorBanner gösterilir
    summary set      → stat kartları render edilir
```

---

## Navigation Mimarisi — Navigator Pattern

```
AppNavigator (singleton)
├── LoginNavigator      → GoRoute('/login')
├── RegisterNavigator   → GoRoute('/register')
├── ShellNavigator      → StatefulShellRoute (bottom nav)
│   ├── DashboardNavigator  → GoRoute('/dashboard')
│   ├── AppointmentsNavigator
│   ├── CustomersNavigator
│   └── MoreNavigator
└── HomeNavigator       → GoRoute('/home', '/home/showcase')
```

Her Navigator:
- Kendi path constant'ını tutar: `static const path = '/dashboard'`
- `show(BuildContext context)` static metodu: `context.go(path)`
- `route` getter: `GoRoute(path: path, builder: (_, __) => Screen())`

**Auth Guard:** `AppNavigator.redirect(isLoggedIn, path)` login/register sayfalarına auth kontrolü yapar. GoRouter'ın `redirect:` callback'i bu metodu çağırır.

**Navigation Facade:** `NavigationFacade` low-level helper (`push`, `pop`, `replace`). Feature screen'lerden doğrudan kullanılmaz — her feature kendi navigator'ını kullanır.

---

## Paket İzolasyon Kuralları

```
flutter_kit_core     → hiçbir flutter_kit_* paketine bağımlı olamaz
flutter_kit_network  → hiçbir flutter_kit_* paketine bağımlı olamaz
flutter_kit_ui       → hiçbir flutter_kit_* paketine bağımlı olamaz
flutter_kit_firebase → hiçbir flutter_kit_* paketine bağımlı olamaz
flutter_kit_auth     → flutter_kit_network + flutter_kit_core'a bağımlı olabilir
apps/mobile          → hepsine bağımlı olabilir
```

`flutter_kit_firebase`'in GoRouter veya `flutter_kit_auth`'a bağımlı olması yasaktır (circular dependency yaratır). Çözüm: callback pattern (`NotificationDeepLinkHandler.onNavigate`).

---

## BaseState.isLoading → LoadingOverlay Akışı

```
DashboardBloc.emit(state.copyWith(isLoading: true))
  └── BlocBuilder state değişikliğini algılar
      └── BaseBlocView._shouldShowLoading(state) → true
          └── LoadingOverlay gösterilir (flutter_kit_ui)

DashboardBloc.emit(state.copyWith(isLoading: false))
  └── LoadingOverlay gizlenir
```

`BaseBlocView` `isLoading`'i otomatik izler — feature screen'lerin loading overlay'i manuel yönetmesi gerekmez.

---

## DI: Factory vs Singleton Kararları

| Tür | Kayıt | Neden |
|-----|-------|-------|
| `ApiManager` | `lazySingleton` | Interceptor zinciri bir kez kurulur, uygulama boyunca yaşar |
| `TokenStore` | `lazySingleton` | SecureStorage wrapper, stateful değil |
| `AuthManager` | `lazySingleton` | Auth state tek kaynak olmalı |
| `AuthBloc` | `singleton` | Tüm app auth state'ini dinler, navigasyon guard'ı kullanır |
| Feature BLoC/Cubit | GetIt'e kayıt yok | `BaseBlocView.create` factory'si üretir, dispose'da kapatır |

Feature BLoC'lar GetIt'e kayıtlı **değildir** — `BaseBlocView` lifecycle'ı yönetir. `getIt<DashboardBloc>()` çalışmaz ve çalışmamalı.

---

## Interceptor Zinciri Sırası

Dio interceptor'ları listeye eklendikleri sırayla çalışır (istek: ilkten sona, yanıt: sondan ilke):

```
İstek yönü (ilk → son):
  1. CertificatePinningInterceptor  ← SSL doğrulama
  2. ConnectivityInterceptor        ← çevrimdışı kontrolü
  3. RateLimiterInterceptor         ← throttle
  4. AuthInterceptor                ← Bearer token ekle
  5. CacheInterceptor               ← önbellekten dön (GET)
  6. LoggingInterceptor             ← istek logu
  7. RetryInterceptor               ← hata sonrası yeniden dene
  8. RefreshTokenInterceptor        ← 401 → token yenile → tekrar dene
```

---

## Lokalizasyon

`slang_flutter` kullanılır. Çeviri dosyaları: `apps/mobile/assets/i18n/`.
Üretilen dosya: `strings.g.dart` (commit edilmez, build_runner üretir).

```dart
// Kullanım
Text(context.t.login.title)
Text(context.t.errors.networkError)
```

Hard-coded string kullanmaktan kaçının — her UI metni `strings.g.dart` üzerinden gelmeli.
