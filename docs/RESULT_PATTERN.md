# Result\<T, E\> Pattern — Quick-Start

## Nedir, Neden Var?

`Result<T, E>` (`flutter_kit_network`'ten) başarı veya hata olabilen her async operasyonu temsil eder.

**Flutter'da standart try/catch yaklaşımının sorunu:**
```dart
// try/catch: derleyici her iki durumu da ele alıp almadığını kontrol EDEMEZ
try {
  final data = await repo.fetch();
  // ...
} catch (e) {
  // hata yönetimi — unutmak kolay
}
```

**Result ile:**
```dart
// when() exhausive — her iki branch zorunlu, derleyici kontrol eder
final result = await repo.fetch();
result.when(
  ok: (data) => /* başarı yolu */,
  err: (error) => /* hata yolu */,
);
```

---

## Üç Temel Metot

### `.when(ok:, err:)`
Her iki durumu ele alır. En yaygın kullanım:
```dart
result.when(
  ok: (value) => doSomethingWith(value),
  err: (error) => handleError(error),
);
```

### `.isOk` ve `.isErr`
Boolean kontrol:
```dart
if (result.isOk) {
  // güvenle devam
}
```

### Değere direkt erişim (dikkatli kullan)
```dart
// Sadece isOk kontrolünden sonra:
final value = (result as Ok<T, E>).value;
```

---

## BLoC'ta Doğru Kullanım

```dart
Future<void> _onLoad(
  DashboardLoadRequested event,
  Emitter<DashboardState> emit,
) async {
  emit(state.copyWith(isLoading: true, errorMessage: null));

  final result = await _getDashboard();

  result.when(
    ok: (summary) => emit(
      state.copyWith(summary: summary, isLoading: false),
    ),
    err: (error) => emit(
      state.copyWith(errorMessage: error.message, isLoading: false),
    ),
  );
}
```

**Kritik:** Her iki branch'te `isLoading: false` set edilmeli. Unutulursa ekran yükleniyor animasyonunda takılı kalır.

---

## Yaygın Hatalar

### Hata 1: err branch'te emit unutmak
```dart
// YANLIŞ — isLoading asla false olmaz
result.when(
  ok: (data) => emit(state.copyWith(data: data, isLoading: false)),
  err: (_) {},  // ← BUG
);

// DOĞRU
result.when(
  ok: (data) => emit(state.copyWith(data: data, isLoading: false)),
  err: (e) => emit(state.copyWith(errorMessage: e.message, isLoading: false)),
);
```

### Hata 2: UseCase içinde try/catch sarmak
```dart
// YANLIŞ — Result zaten hataları sarıyor, çift sarma
@override
Future<Result<DashboardSummary, ApiError>> call() async {
  try {
    return await _repository.getDashboard();
  } catch (e) {
    return Err(ApiError(message: e.toString())); // ← YANLIŞ
  }
}

// DOĞRU — doğrudan propagate et
@override
Future<Result<DashboardSummary, ApiError>> call() =>
    _repository.getDashboard();
```

### Hata 3: Null kontrolü yapmak
```dart
// YANLIŞ
if (result.value != null) { ... }

// DOĞRU
result.when(ok: (v) { ... }, err: (e) { ... });
```

---

## ApiError Alanları

```dart
class ApiError {
  final int? statusCode;  // HTTP status (401, 404, 500...) — null olabilir (network hatası)
  final String message;   // Kullanıcıya gösterilebilir mesaj
}
```

`statusCode` null olduğunda genellikle timeout, DNS veya SSL hatası demektir.

---

## Repository'den UseCase'e Propagasyon

```
ApiManager.get()            → Result<DashboardDto, ApiError>
DataSource.getDashboard()   → Result<DashboardSummary, ApiError>  (DTO→Entity mapping sonrası)
RepositoryImpl.getDashboard() → Result<DashboardSummary, ApiError>  (datasource'u doğrudan döndür)
UseCase.call()              → Result<DashboardSummary, ApiError>  (repo'yu doğrudan döndür)
Bloc._onLoad()              → state'i günceller, dışarı döndürmez
```

Her katman Result'ı **sarmadan** geçirir — sadece BLoC katmanı state'e dönüştürür.

---

## Ok ve Err Oluşturma

```dart
// Başarı
return const Ok(dashboardSummary);

// Hata
return const Err(ApiError(statusCode: 404, message: 'Not found'));

// Test'te dummy değer (Mockito için)
provideDummy<Result<DashboardSummary, ApiError>>(
  const Ok(DashboardSummary(...)),
);
```
