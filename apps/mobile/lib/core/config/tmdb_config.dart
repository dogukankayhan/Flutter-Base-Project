abstract final class TmdbConfig {
  static const baseUrl = 'https://api.themoviedb.org/3';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  static const apiKey = String.fromEnvironment('TMDB_API_KEY');
}
