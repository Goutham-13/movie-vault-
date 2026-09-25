class ApiConstants {
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrlOriginal = 'https://image.tmdb.org/t/p/original';
  static const String imageBaseUrlW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlW342 = 'https://image.tmdb.org/t/p/w342';
  static const String imageBaseUrlW185 = 'https://image.tmdb.org/t/p/w185';
  
  // Default TMDB API Key (User provided active key)
  static const String defaultApiKey = 'a867b5d1784ba6d27de777c21201cf8e'; 
  
  static String getPosterUrl(String? path, {String quality = 'w500'}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('assets/')) {
      return path;
    }
    return 'https://image.tmdb.org/t/p/$quality$path';
  }

  static String getBackdropUrl(String? path, {String quality = 'original'}) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://') || path.startsWith('assets/')) {
      return path;
    }
    return 'https://image.tmdb.org/t/p/$quality$path';
  }
}
