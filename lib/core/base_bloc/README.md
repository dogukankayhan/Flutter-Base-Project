# Base Bloc Architecture

Flutter Bloc paketini kullanarak oluşturulmuş, **flutter_base_kit** projesine özel Base Architecture yapısı.

## 📁 Dosya Yapısı

```
lib/core/base_bloc/
├── base_state.dart              # Base state sınıfları
├── base_cubit.dart              # Base cubit sınıfı
├── base_bloc_view.dart          # Base view widget'ı
├── active_cubit_helper.dart     # Active key helper fonksiyonları
├── example_usage.dart           # Örnek kullanım
└── README.md                   # Bu dosya
```

## 🎯 Özellikler

### BaseCubit
- ✅ **Lifecycle Management**: `onInit`, `onReady`, `close`
- ✅ **Auth Integration**: `AuthManager.instance` singleton
- ✅ **API Integration**: `ApiManager` (GetIt'ten)
- ✅ **Result Pattern**: `Result<T, ApiError>` desteği
- ✅ **Safe Emit**: Cubit kapalıyken emit hatalarını önler
- ✅ **Context Access**: BuildContext erişimi

### BaseBlocView
- ✅ **Active Key System**: GetIt ile key-based cubit management
- ✅ **Lifecycle Callbacks**: onInit, onReady, onDispose
- ✅ **Post-Frame Support**: Opsiyonel post-frame callback
- ✅ **Auto Cleanup**: Cubit otomatik dispose edilir

### BaseState
- ✅ **Equatable**: Performans optimizasyonu
- ✅ **Common Properties**: isLoading, isValid, errorMessage
- ✅ **Type Safety**: Compile-time type checking

## 🚀 Kurulum

### 1. Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0  # Zaten projede var
```

### 2. Dosyaları Ekle

```bash
# base_bloc klasörünü lib/core/ altına kopyala
cp -r base_bloc/ lib/core/
```

### 3. Proje Yapısı

```
lib/
  core/
    base_bloc/              ← YENİ
      base_state.dart
      base_cubit.dart
      base_bloc_view.dart
      active_cubit_helper.dart
      example_usage.dart
      README.md
    managers/
      auth_manager/
    networking/
      core/
        di/
          service_locator.dart  # GetIt setup
```

## 📚 Kullanım

### Basit Örnek

#### 1. State Oluştur

```dart
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';

class CounterState extends BaseState {
  final int count;

  const CounterState({
    required this.count,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  CounterState copyWith({
    int? count,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
  }) {
    return CounterState(
      count: count ?? this.count,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [count, ...super.props];
}
```

#### 2. Cubit Oluştur

```dart
import 'package:flutter_base_kit/core/base_bloc/base_cubit.dart';

class CounterCubit extends BaseCubit<CounterState> {
  CounterCubit() : super(const CounterState(count: 0));

  @override
  void onInit() {
    super.onInit();
    print('Counter initialized');
  }

  @override
  void onReady() {
    super.onReady();
    // API çağrıları buraya
  }

  void increment() {
    safeEmit(state.copyWith(count: state.count + 1));
  }

  void decrement() {
    safeEmit(state.copyWith(count: state.count - 1));
  }
}
```

#### 3. View Oluştur

```dart
import 'package:flutter_base_kit/core/base_bloc/base_bloc_view.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<CounterCubit, CounterState>(
      create: () => CounterCubit(),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Counter')),
          body: Center(
            child: Text(
              '${state.count}',
              style: const TextStyle(fontSize: 48),
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                onPressed: () => context.read<CounterCubit>().increment(),
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                onPressed: () => context.read<CounterCubit>().decrement(),
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## 🔥 AuthManager ve ApiManager Kullanımı

### AuthManager (Singleton)

```dart
class LoginCubit extends BaseCubit<LoginState> {
  Future<void> login(String email, String password) async {
    safeEmit(state.copyWith(isLoading: true));
    
    // AuthManager singleton instance
    final result = await authManager.login(email, password);
    
    result.when(
      ok: (_) {
        // Login başarılı
        safeEmit(state.copyWith(isLoading: false));
      },
      err: (error) {
        // Hata
        safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }
}
```

### ApiManager (GetIt)

```dart
class UserCubit extends BaseCubit<UserState> {
  Future<void> loadUser() async {
    safeEmit(state.copyWith(isLoading: true));
    
    try {
      // ApiManager GetIt'ten gelir
      final response = await apiManager.get<UserDto>(
        path: '/users/me',
        fromJson: (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      
      safeEmit(state.copyWith(
        user: response.data,
        isLoading: false,
      ));
    } catch (e) {
      safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load user: $e',
      ));
    }
  }
}
```

## 🎓 İleri Seviye Özellikler

### 1. Active Key System

Aynı tipten birden fazla ekran açıkken bunları ayırt etmek için:

```dart
// Ekran 1
BaseBlocView<DetailCubit, DetailState>(
  create: () => DetailCubit('item-123'),
  activeKey: 'detail-123',
  builder: (context, state) => DetailUI(),
)

// Ekran 2
BaseBlocView<DetailCubit, DetailState>(
  create: () => DetailCubit('item-456'),
  activeKey: 'detail-456',
  builder: (context, state) => DetailUI(),
)

// Başka bir yerden erişim
import 'package:flutter_base_kit/core/base_bloc/active_cubit_helper.dart';

final cubit = getActiveOrNull<DetailCubit>(key: 'detail-123');
cubit?.doSomething();
```

### 2. Lifecycle Callbacks

```dart
BaseBlocView<MyCubit, MyState>(
  create: () => MyCubit(),
  onInit: (cubit) {
    print('View initialized');
  },
  onReady: (cubit) {
    print('View ready, making API calls');
    cubit.loadData();
  },
  onDispose: (cubit) {
    print('View disposing');
  },
  builder: (context, state) => MyUI(),
)
```

### 3. Post-Frame Control

```dart
BaseBlocView<MyCubit, MyState>(
  create: () => MyCubit(),
  usePostFrame: false, // onReady hemen çağrılır
  builder: (context, state) => MyUI(),
)
```

### 4. Result Pattern ile Error Handling

```dart
class DataCubit extends BaseCubit<DataState> {
  Future<void> loadData() async {
    safeEmit(state.copyWith(isLoading: true));
    
    try {
      final response = await apiManager.get<DataDto>(
        path: '/data',
        fromJson: (json) => DataDto.fromJson(json as Map<String, dynamic>),
      );
      
      safeEmit(state.copyWith(
        data: response.data,
        isLoading: false,
      ));
    } on ApiException catch (e) {
      safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: e.error.message,
      ));
    } catch (e) {
      safeEmit(state.copyWith(
        isLoading: false,
        errorMessage: 'Beklenmeyen hata: $e',
      ));
    }
  }
}
```

## 🔄 Mevcut Yapı ile Entegrasyon

### GetIt Setup

Proje zaten GetIt kullanıyor (`service_locator.dart`):

```dart
// lib/core/networking/core/di/service_locator.dart
final getIt = GetIt.instance;

Future<void> setupDI({...}) async {
  // ApiManager zaten kayıtlı
  getIt.registerLazySingleton<ApiManager>(...);
}
```

Base Cubit bu yapıyı kullanır:

```dart
abstract class BaseCubit<T extends BaseState> extends Cubit<T> {
  // GetIt'ten ApiManager al
  ApiManager get apiManager => getIt<ApiManager>();
  
  // Singleton AuthManager
  AuthManager get authManager => AuthManager.instance;
}
```

### AuthManager Singleton

AuthManager zaten singleton pattern kullanıyor:

```dart
class AuthManager extends ChangeNotifier {
  static late final AuthManager instance;
  
  static Future<void> init({...}) async {
    instance = AuthManager._(...);
  }
}
```

Base Cubit direkt erişir:

```dart
final result = await authManager.login(email, password);
```

## 📖 Best Practices

### 1. State İsimlendirme

```dart
// ✅ İyi
class UserState extends BaseState { ... }
class ProductListState extends BaseState { ... }

// ❌ Kötü  
class UserData extends BaseState { ... }
```

### 2. copyWith Pattern

```dart
// ✅ İyi - Her field için override
UserState copyWith({
  User? user,
  bool? isLoading,
  String? errorMessage,
}) {
  return UserState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
```

### 3. API Çağrıları

```dart
// ✅ İyi - onReady'de
@override
void onReady() {
  super.onReady();
  loadInitialData();
}

// ❌ Kötü - onInit'de
@override
void onInit() {
  super.onInit();
  loadInitialData(); // Widget henüz render edilmedi!
}
```

### 4. Error Handling

```dart
// ✅ İyi - Result pattern kullan
result.when(
  ok: (data) => handleSuccess(data),
  err: (error) => handleError(error),
);

// ❌ Kötü - Throw catch without proper handling
try {
  await riskyOperation();
} catch (e) {
  print(e); // Sadece log yeterli değil
}
```

## 🐛 Common Issues

### Issue 1: "Bad state: Cannot emit new states after calling close"

**Çözüm**: `safeEmit` kullan

```dart
// ✅ İyi
void updateData() {
  safeEmit(state.copyWith(data: newData));
}

// ❌ Kötü
void updateData() {
  emit(state.copyWith(data: newData));
}
```

### Issue 2: State güncellenmiyor

**Çözüm**: Equatable props'ları kontrol et

```dart
// ✅ İyi
@override
List<Object?> get props => [user, posts, ...super.props];

// ❌ Kötü
@override
List<Object?> get props => super.props;
```

### Issue 3: GetIt registration error

**Çözüm**: setupDI çağrıldığından emin ol

```dart
// main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup DI
  await setupDI(baseUrl: 'https://api.example.com');
  
  // Initialize AuthManager
  await AuthManager.init(...);
  
  runApp(MyApp());
}
```

## 📊 Proje Yapısı Örneği

```
lib/
  features/
    auth/
      login/
        cubit/
          login_cubit.dart
          login_state.dart
        view/
          login_screen.dart
    home/
      cubit/
        home_cubit.dart
        home_state.dart
      view/
        home_screen.dart
  core/
    base_bloc/          ← Base yapı
    managers/
      auth_manager/     ← Singleton AuthManager
    networking/
      core/
        di/
          service_locator.dart  ← GetIt setup
        network/
          api/
            api_manager.dart    ← ApiManager
```

## 🔗 İlgili Dosyalar

- `lib/core/managers/auth_manager/auth/manager/auth_manager.dart` - AuthManager singleton
- `lib/core/networking/core/di/service_locator.dart` - GetIt setup
- `lib/core/networking/core/network/api/api_manager.dart` - ApiManager implementation
- `lib/core/networking/core/utils/result.dart` - Result<T, E> pattern

## 📖 Daha Fazla Bilgi

- [Flutter Bloc Documentation](https://bloclibrary.dev/)
- [Equatable Package](https://pub.dev/packages/equatable)
- [GetIt - Service Locator](https://pub.dev/packages/get_it)

## ✨ Özet

Bu base_bloc yapısı:
- ✅ Mevcut `flutter_base_kit` projesine tamamen uyumlu
- ✅ GetIt dependency injection kullanır
- ✅ AuthManager singleton pattern'ı destekler
- ✅ Result<T, ApiError> pattern ile çalışır
- ✅ Active key sistemi ile multiple instance management
- ✅ Lifecycle management (onInit, onReady, close)
- ✅ Type-safe state management
- ✅ Test-friendly architecture

Detaylı örnekler için `example_usage.dart` dosyasına bakın! 🚀
