/// Lifecycle methodlarına sahip bloc/cubit'ler için interface
/// BaseCubit ve BaseBloc bu interface'i implement eder
abstract class LifecycleBloc {
  /// Bloc/Cubit oluşturulduğunda çağrılır (opsiyonel)
  void onInit();

  /// Widget render edildikten sonra çağrılır (opsiyonel)
  void onReady();

  /// Bloc/Cubit kapalı mı?
  bool get isClosed;

  /// Close the bloc/cubit
  Future<void> close();
}
