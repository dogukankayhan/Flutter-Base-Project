/// Tüm repository interface'leri için marker kontrat.
///
/// Kullanım:
/// ```dart
/// abstract class ArmyRepository implements BaseRepository {
///   Future<Result<List<Unit>, ApiError>> getUnits();
/// }
/// ```
abstract interface class BaseRepository {}
