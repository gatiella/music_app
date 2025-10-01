class AppConstants {
  static const String ytMusicPlaylistsTable = 'ytmusic_playlists';
  static const String ytMusicPlaylistItemsTable = 'ytmusic_playlist_items';
  // App Information
  static const String appName = 'Music Player';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'A beautiful and feature-rich music player built with Flutter';

  // Database
  static const String databaseName = 'music_player.db';
  static const int databaseVersion = 1;

  // Table Names
  static const String songsTable = 'songs';
  static const String playlistsTable = 'playlists';
  static const String playlistSongsTable = 'playlist_songs';
  static const String favoritesTable = 'favorites';
  static const String ytMusicFavoritesTable = 'ytmusic_favorites';
  static const String downloadedSongsTable = 'downloaded_songs';

  // Audio Service
  static const String audioChannelId =
      'com.example.music_player_app.channel.audio';
  static const String audioChannelName = 'Music Player';
  static const String audioChannelDescription = 'Music playback controls';

  // Supported Audio Formats
  static const List<String> supportedAudioFormats = [
    'mp3',
    'flac',
    'wav',
    'aac',
    'ogg',
    'm4a',
    'wma',
  ];

  // File Extensions
  static const List<String> audioExtensions = [
    '.mp3',
    '.flac',
    '.wav',
    '.aac',
    '.ogg',
    '.m4a',
    '.wma',
  ];

  // Default Values
  static const double defaultVolume = 1.0;
  static const double defaultSpeed = 1.0;
  static const int defaultCrossfadeDuration = 3; // seconds
  static const int defaultSleepTimerDuration = 30; // minutes

  // Limits
  static const int maxPlaylistNameLength = 50;
  static const int maxRecentSongs = 100;
  static const int maxSearchResults = 50;
  static const int maxQueueSize = 1000;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // SharedPreferences Keys
  static const String themeKey = 'theme_mode';
  static const String primaryColorKey = 'primary_color';
  static const String volumeKey = 'volume';
  static const String speedKey = 'speed';
  static const String shuffleKey = 'shuffle_mode';
  static const String repeatKey = 'repeat_mode';
  static const String equalizerKey = 'equalizer_settings';
  static const String crossfadeKey = 'crossfade_enabled';
  static const String sleepTimerKey = 'sleep_timer_enabled';
  static const String lastPlayedSongKey = 'last_played_song';
  static const String lastPlayedPositionKey = 'last_played_position';
  static const String libraryLastScanKey = 'library_last_scan';

  // Sort Options
  static const Map<String, String> sortOptions = {
    'title': 'Title',
    'artist': 'Artist',
    'album': 'Album',
    'duration': 'Duration',
    'dateAdded': 'Date Added',
    'dateModified': 'Date Modified',
    'playCount': 'Play Count',
  };

  // Equalizer Presets
  static const Map<String, List<double>> equalizerPresets = {
    'Flat': [0, 0, 0, 0, 0, 0, 0],
    'Classical': [-1, -1, -1, -1, -1, -1, -7],
    'Club': [-1, -1, 8, 5, 5, 5, 3],
    'Dance': [9, 7, 2, 0, 0, -5, -7],
    'Full Bass': [-8, 9, 9, 5, 1, -4, -8],
    'Full Bass & Treble': [7, 5, 0, -7, -4, 1, 8],
    'Full Treble': [-9, -9, -9, -4, 2, 11, 16],
    'Laptop Speakers': [4, 11, 5, -3, -2, 1, 4],
    'Large Hall': [10, 10, 5, 5, 0, -4, -4],
    'Live': [-4, 0, 4, 5, 5, 5, 4],
    'Party': [7, 7, 0, 0, 0, 0, 7],
    'Pop': [-1, 4, 7, 8, 5, 0, -2],
    'Reggae': [0, 0, 0, -5, 0, 6, 6],
    'Rock': [8, 4, -5, -8, -3, 4, 8],
    'Ska': [-2, -4, -4, 0, 4, 5, 8],
    'Soft': [4, 1, 0, -2, 0, 4, 8],
    'Soft Rock': [4, 4, 2, 0, -4, -5, -3],
    'Techno': [8, 5, 0, -5, -4, 0, 8],
  };

  // Default Playlists
  static const List<String> defaultPlaylistNames = [
    'Favorites',
    'Recently Added',
    'Most Played',
    'Recently Played',
  ];

  // Error Messages
  static const String permissionDeniedError =
      'Storage permission is required to access your music files';
  static const String noMusicFoundError = 'No music files found on your device';
  static const String playbackError = 'Unable to play this track';
  static const String networkError = 'Network connection required';
  static const String unknownError = 'An unknown error occurred';

  // Success Messages
  static const String playlistCreatedSuccess = 'Playlist created successfully';
  static const String playlistDeletedSuccess = 'Playlist deleted successfully';
  static const String songAddedToPlaylistSuccess = 'Song added to playlist';
  static const String songRemovedFromPlaylistSuccess =
      'Song removed from playlist';
  static const String libraryRefreshedSuccess = 'Music library refreshed';

  // File Paths
  static const String defaultAlbumArt = 'assets/images/default_album_art.png';
  static const String appLogo = 'assets/images/app_logo.png';

  // Notification Actions
  static const String playAction = 'PLAY';
  static const String pauseAction = 'PAUSE';
  static const String nextAction = 'NEXT';
  static const String previousAction = 'PREVIOUS';
  static const String stopAction = 'STOP';

  // Deep Link Schemes
  static const String appScheme = 'musicplayer';
  static const String playlistScheme = 'playlist';
  static const String artistScheme = 'artist';
  static const String albumScheme = 'album';

  // Regular Expressions
  static final RegExp audioFilePattern = RegExp(
    r'\.(mp3|flac|wav|aac|ogg|m4a|wma)$',
    caseSensitive: false,
  );

  // Time Formats
  static const String timeFormat = 'mm:ss';
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy HH:mm';
}
