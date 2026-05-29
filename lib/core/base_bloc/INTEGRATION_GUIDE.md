# Migration Guide: flutter_base_kit için Base Bloc Entegrasyonu

Bu rehber, `flutter_base_kit` projesine Base Bloc yapısının nasıl entegre edileceğini açıklar.

## 📋 Ön Hazırlık

### 1. Dependencies Kontrol

`pubspec.yaml` dosyanızda şunlar olmalı:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3         # EKLE
  equatable: ^2.0.5             # EKLE
  get_it: ^7.6.0                # ZATEN VAR
  connectivity_plus: ^5.0.0     # ZATEN VAR
  dio: ^5.4.0                   # ZATEN VAR
```

### 2. Proje Yapısını Kontrol

Projenizde şu yapı olmalı:

```
lib/
  core/
    managers/
      auth_manager/
        auth/
          manager/
            auth_manager.dart    # ✅ Var
    networking/
      core/
        di/
          service_locator.dart   # ✅ Var
        network/
          api/
            api_manager.dart     # ✅ Var
```

---

## 🚀 Kurulum Adımları

### Adım 1: Base Bloc Dosyalarını Ekle

```bash
# base_bloc klasörünü lib/core/ altına kopyala
cp -r base_bloc/ your_project/lib/core/
```

Sonuç yapısı:

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
    networking/
```

### Adım 2: Dependencies Yükle

```bash
flutter pub get
```

### Adım 3: Main.dart Kontrolü

`main.dart` dosyanızda GetIt ve AuthManager init edildiğinden emin olun:

```dart
import 'package:flutter_base_kit/core/networking/core/di/service_locator.dart';
import 'package:flutter_base_kit/core/managers/auth_manager/auth/manager/auth_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Setup Dependency Injection
  await setupDI(
    baseUrl: 'https://your-api.com',
    tokenProvider: () async {
      // Token provider logic
      return null;
    },
  );
  
  // 2. Initialize AuthManager
  await AuthManager.init(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    meUseCase: getIt<MeUseCase>(),
    updateProfileUseCase: getIt<UpdateProfileUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
    refreshUseCase: getIt<RefreshUseCase>(),
  );
  
  runApp(const MyApp());
}
```

---

## 📝 İlk Feature'ınızı Oluşturun

### Örnek: Login Ekranı

#### 1. State Oluştur

`lib/features/auth/login/cubit/login_state.dart`:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter_base_kit/core/base_bloc/base_state.dart';

class LoginState extends BaseState {
  final String email;
  final String password;
  final bool isPasswordVisible;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isPasswordVisible = false,
    super.isLoading,
    super.isValid,
    super.errorMessage,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isPasswordVisible,
    bool? isLoading,
    bool? isValid,
    String? errorMessage,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isValid: isValid ?? this.isValid,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isPasswordVisible,
        ...super.props,
      ];
}
```

#### 2. Cubit Oluştur

`lib/features/auth/login/cubit/login_cubit.dart`:

```dart
import 'package:flutter_base_kit/core/base_bloc/base_cubit.dart';
import 'package:flutter_base_kit/features/auth/login/cubit/login_state.dart';

class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit() : super(const LoginState());

  @override
  void onInit() {
    super.onInit();
    // Initialization logic
  }

  @override
  void onReady() {
    super.onReady();
    // Widget render'dan sonra çalışacak kod
  }

  void setEmail(String value) {
    safeEmit(state.copyWith(email: value));
    _validateForm();
  }

  void setPassword(String value) {
    safeEmit(state.copyWith(password: value));
    _validateForm();
  }

  void togglePasswordVisibility() {
    safeEmit(state.copyWith(
      isPasswordVisible: !state.isPasswordVisible,
    ));
  }

  void _validateForm() {
    final isValid = state.email.isNotEmpty && 
                    state.password.length >= 6;
    safeEmit(state.copyWith(isValid: isValid));
  }

  Future<void> login() async {
    if (!state.isValid) return;

    safeEmit(state.copyWith(isLoading: true));

    // AuthManager kullanarak login
    final result = await authManager.login(
      state.email,
      state.password,
    );

    result.when(
      ok: (_) {
        // Login başarılı
        safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: null,
        ));
        // Navigate to home
      },
      err: (error) {
        // Login failed
        safeEmit(state.copyWith(
          isLoading: false,
          errorMessage: error.message,
        ));
      },
    );
  }
}
```

#### 3. View Oluştur

`lib/features/auth/login/view/login_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_base_kit/core/base_bloc/base_bloc_view.dart';
import 'package:flutter_base_kit/features/auth/login/cubit/login_cubit.dart';
import 'package:flutter_base_kit/features/auth/login/cubit/login_state.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseBlocView<LoginCubit, LoginState>(
      create: () => LoginCubit(),
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error message
                if (state.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),

                // Email field
                TextField(
                  onChanged: context.read<LoginCubit>().setEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  onChanged: context.read<LoginCubit>().setPassword,
                  obscureText: !state.isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        state.isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: context
                          .read<LoginCubit>()
                          .togglePasswordVisibility,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: state.isValid && !state.isLoading
                        ? () => context.read<LoginCubit>().login()
                        : null,
                    child: state.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Login'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

## 🎯 Önemli Noktalar

### 1. AuthManager Kullanımı

BaseCubit'te AuthManager singleton olarak hazır:

```dart
class MyCubit extends BaseCubit<MyState> {
  Future<void> doSomething() async {
    // Direkt authManager kullan
    final result = await authManager.login(email, password);
    
    result.when(
      ok: (_) => handleSuccess(),
      err: (error) => handleError(error),
    );
  }
}
```

### 2. ApiManager Kullanımı

BaseCubit'te ApiManager GetIt'ten otomatik alınır:

```dart
class UserCubit extends BaseCubit<UserState> {
  Future<void> loadUser() async {
    // apiManager hazır
    final response = await apiManager.get<UserDto>(
      path: '/users/me',
      fromJson: (json) => UserDto.fromJson(json as Map<String, dynamic>),
    );
    
    safeEmit(state.copyWith(user: response.data));
  }
}
```

### 3. Result Pattern

Proje `Result<T, ApiError>` pattern kullanıyor:

```dart
final result = await authManager.login(email, password);

// when ile handle et
result.when(
  ok: (data) {
    // Success
  },
  err: (error) {
    // Error
    print(error.message);
  },
);
```

### 4. Safe Emit

Async işlemlerde mutlaka `safeEmit` kullan:

```dart
Future<void> loadData() async {
  safeEmit(state.copyWith(isLoading: true));
  
  try {
    final data = await fetchData();
    safeEmit(state.copyWith(data: data, isLoading: false));
  } catch (e) {
    safeEmit(state.copyWith(errorMessage: '$e', isLoading: false));
  }
}
```

---

## 🧪 Test Yazma

Bloc test yazmak çok kolay:

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginCubit', () {
    late LoginCubit cubit;

    setUp(() {
      cubit = LoginCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is correct', () {
      expect(cubit.state, const LoginState());
    });

    blocTest<LoginCubit, LoginState>(
      'setEmail updates email in state',
      build: () => cubit,
      act: (cubit) => cubit.setEmail('test@example.com'),
      expect: () => [
        const LoginState(email: 'test@example.com'),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'login sets loading to true then false',
      build: () => cubit,
      seed: () => const LoginState(
        email: 'test@example.com',
        password: 'password123',
        isValid: true,
      ),
      act: (cubit) => cubit.login(),
      expect: () => [
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', true),
        isA<LoginState>().having((s) => s.isLoading, 'isLoading', false),
      ],
    );
  });
}
```

Test için ek dependency:

```yaml
dev_dependencies:
  bloc_test: ^9.1.0
  mocktail: ^1.0.0
```

---

## 📊 Feature Yapısı Önerisi

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
          widgets/
            login_form.dart
            login_button.dart
      register/
        cubit/
          register_cubit.dart
          register_state.dart
        view/
          register_screen.dart
    home/
      cubit/
        home_cubit.dart
        home_state.dart
      view/
        home_screen.dart
```

---

## ✅ Checklist

Yeni feature eklerken:

- [ ] State sınıfı oluşturuldu
- [ ] State'de copyWith metodu var
- [ ] State'de Equatable props doğru tanımlandı
- [ ] Cubit sınıfı BaseCubit'ten türetildi
- [ ] onInit ve onReady implement edildi
- [ ] safeEmit kullanılıyor
- [ ] Result pattern doğru kullanılıyor
- [ ] View BaseBlocView kullanıyor
- [ ] Error handling yapıldı
- [ ] Test yazıldı

---

## 🐛 Troubleshooting

### Problem: "type 'ApiManager' is not registered"

**Çözüm**: setupDI'ın çağrıldığından emin olun

```dart
void main() async {
  await setupDI(baseUrl: 'https://api.example.com');
  runApp(MyApp());
}
```

### Problem: "AuthManager.instance' was called on null"

**Çözüm**: AuthManager.init'in çağrıldığından emin olun

```dart
void main() async {
  await setupDI(...);
  await AuthManager.init(...);
  runApp(MyApp());
}
```

### Problem: State güncellenmiyor

**Çözüm**: Equatable props kontrolü

```dart
@override
List<Object?> get props => [
  // TÜM field'ları ekle
  email,
  password,
  ...super.props,
];
```

---

## 📚 Kaynaklar

- **Proje İçi**:
  - `lib/core/base_bloc/README.md` - Detaylı dokümantasyon
  - `lib/core/base_bloc/example_usage.dart` - Örnek kodlar
  
- **External**:
  - [Flutter Bloc Docs](https://bloclibrary.dev/)
  - [Equatable Package](https://pub.dev/packages/equatable)
  - [Bloc Testing](https://pub.dev/packages/bloc_test)

---

## 🎉 Sonuç

Artık Base Bloc yapısı projenize entegre edildi! 

**Sonraki adımlar:**
1. İlk feature'ınızı oluşturun (örn: Login)
2. Test yazın
3. Diğer feature'ları ekleyin

Başarılar! 🚀
