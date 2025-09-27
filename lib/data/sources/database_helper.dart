import 'package:music_app/data/models/playlist.dart';
import 'package:music_app/data/models/song.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(
      await getDatabasesPath(),
      AppConstants.databaseName,
    );

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Songs table
    await db.execute('''
      CREATE TABLE ${AppConstants.songsTable} (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        album TEXT NOT NULL,
        albumArt TEXT,
        path TEXT NOT NULL UNIQUE,
        duration INTEGER NOT NULL,
        genre TEXT,
        year INTEGER,
        track INTEGER,
        size INTEGER NOT NULL,
        dateAdded INTEGER,
        dateModified INTEGER,
        isFavorite INTEGER DEFAULT 0,
        playCount INTEGER DEFAULT 0,
        lastPlayed INTEGER
      )
    ''');

    // Playlists table
    await db.execute('''
      CREATE TABLE ${AppConstants.playlistsTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        createdAt INTEGER NOT NULL,
        updatedAt INTEGER NOT NULL,
        coverArt TEXT
      )
    ''');

    // Playlist songs junction table
    await db.execute('''
      CREATE TABLE ${AppConstants.playlistSongsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlistId TEXT NOT NULL,
        songId INTEGER NOT NULL,
        position INTEGER NOT NULL,
        FOREIGN KEY (playlistId) REFERENCES ${AppConstants.playlistsTable} (id) ON DELETE CASCADE,
        FOREIGN KEY (songId) REFERENCES ${AppConstants.songsTable} (id) ON DELETE CASCADE,
        UNIQUE(playlistId, songId)
      )
    ''');

    // Indexes for better performance
    await db.execute(
      'CREATE INDEX idx_songs_artist ON ${AppConstants.songsTable} (artist)',
    );
    await db.execute(
      'CREATE INDEX idx_songs_album ON ${AppConstants.songsTable} (album)',
    );
    await db.execute(
      'CREATE INDEX idx_songs_genre ON ${AppConstants.songsTable} (genre)',
    );
    await db.execute(
      'CREATE INDEX idx_songs_favorite ON ${AppConstants.songsTable} (isFavorite)',
    );
    await db.execute(
      'CREATE INDEX idx_playlist_songs_playlist ON ${AppConstants.playlistSongsTable} (playlistId)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Example: Add new column in version 2
      // await db.execute('ALTER TABLE ${AppConstants.songsTable} ADD COLUMN newColumn TEXT');
    }
  }

  // Song operations
  Future<int> insertSong(Song song) async {
    final db = await database;
    return await db.insert(
      AppConstants.songsTable,
      song.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Song>> getAllSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<Song?> getSongById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return maps.isNotEmpty ? Song.fromMap(maps.first) : null;
  }

  Future<List<Song>> getSongsByArtist(String artist) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'artist = ?',
      whereArgs: [artist],
      orderBy: 'album ASC, track ASC, title ASC',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getSongsByAlbum(String album) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'album = ?',
      whereArgs: [album],
      orderBy: 'track ASC, title ASC',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getFavoriteSongs() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'isFavorite = 1',
      orderBy: 'title ASC',
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getRecentlyAddedSongs([int limit = 20]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'dateAdded IS NOT NULL',
      orderBy: 'dateAdded DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getMostPlayedSongs([int limit = 20]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'playCount > 0',
      orderBy: 'playCount DESC, lastPlayed DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> getRecentlyPlayedSongs([int limit = 20]) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'lastPlayed IS NOT NULL',
      orderBy: 'lastPlayed DESC',
      limit: limit,
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<List<Song>> searchSongs(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      where: 'title LIKE ? OR artist LIKE ? OR album LIKE ? OR genre LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
      orderBy: 'title ASC',
      limit: AppConstants.maxSearchResults,
    );
    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<int> updateSong(Song song) async {
    final db = await database;
    return await db.update(
      AppConstants.songsTable,
      song.toMap(),
      where: 'id = ?',
      whereArgs: [song.id],
    );
  }

  Future<int> deleteSong(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.songsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(int songId) async {
    final db = await database;
    final song = await getSongById(songId);
    if (song != null) {
      return await db.update(
        AppConstants.songsTable,
        {'isFavorite': song.isFavorite ? 0 : 1},
        where: 'id = ?',
        whereArgs: [songId],
      );
    }
    return 0;
  }

  Future<int> incrementPlayCount(int songId) async {
    final db = await database;
    final song = await getSongById(songId);
    if (song != null) {
      return await db.update(
        AppConstants.songsTable,
        {
          'playCount': song.playCount + 1,
          'lastPlayed': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [songId],
      );
    }
    return 0;
  }

  // Playlist operations
  Future<String> insertPlaylist(Playlist playlist) async {
    final db = await database;
    await db.insert(
      AppConstants.playlistsTable,
      playlist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return playlist.id;
  }

  Future<List<Playlist>> getAllPlaylists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.playlistsTable,
      orderBy: 'name ASC',
    );

    List<Playlist> playlists = [];
    for (var map in maps) {
      final songIds = await getPlaylistSongIds(map['id']);
      playlists.add(Playlist.fromMap({...map, 'songIds': songIds}));
    }

    return playlists;
  }

  Future<Playlist?> getPlaylistById(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.playlistsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      final songIds = await getPlaylistSongIds(id);
      return Playlist.fromMap({...maps.first, 'songIds': songIds});
    }

    return null;
  }

  Future<List<String>> getPlaylistSongIds(String playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.playlistSongsTable,
      where: 'playlistId = ?',
      whereArgs: [playlistId],
      orderBy: 'position ASC',
    );
    return maps.map((map) => map['songId'].toString()).toList();
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT s.* FROM ${AppConstants.songsTable} s
      INNER JOIN ${AppConstants.playlistSongsTable} ps ON s.id = ps.songId
      WHERE ps.playlistId = ?
      ORDER BY ps.position ASC
    ''',
      [playlistId],
    );

    return List.generate(maps.length, (i) => Song.fromMap(maps[i]));
  }

  Future<int> updatePlaylist(Playlist playlist) async {
    final db = await database;
    return await db.update(
      AppConstants.playlistsTable,
      {
        'name': playlist.name,
        'description': playlist.description,
        'updatedAt': playlist.updatedAt.millisecondsSinceEpoch,
        'coverArt': playlist.coverArt,
      },
      where: 'id = ?',
      whereArgs: [playlist.id],
    );
  }

  Future<int> deletePlaylist(String id) async {
    final db = await database;
    // Delete playlist songs first (cascade should handle this, but being explicit)
    await db.delete(
      AppConstants.playlistSongsTable,
      where: 'playlistId = ?',
      whereArgs: [id],
    );
    // Delete playlist
    return await db.delete(
      AppConstants.playlistsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addSongToPlaylist(String playlistId, int songId) async {
    final db = await database;

    // Get current max position
    final List<Map<String, dynamic>> positionMaps = await db.query(
      AppConstants.playlistSongsTable,
      columns: ['MAX(position) as maxPosition'],
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );

    final int position = (positionMaps.first['maxPosition'] ?? -1) + 1;

    return await db.insert(AppConstants.playlistSongsTable, {
      'playlistId': playlistId,
      'songId': songId,
      'position': position,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> removeSongFromPlaylist(String playlistId, int songId) async {
    final db = await database;
    return await db.delete(
      AppConstants.playlistSongsTable,
      where: 'playlistId = ? AND songId = ?',
      whereArgs: [playlistId, songId],
    );
  }

  Future<int> reorderPlaylistSongs(String playlistId, List<int> songIds) async {
    final db = await database;
    final batch = db.batch();

    // Delete existing playlist songs
    batch.delete(
      AppConstants.playlistSongsTable,
      where: 'playlistId = ?',
      whereArgs: [playlistId],
    );

    // Insert songs in new order
    for (int i = 0; i < songIds.length; i++) {
      batch.insert(AppConstants.playlistSongsTable, {
        'playlistId': playlistId,
        'songId': songIds[i],
        'position': i,
      });
    }

    final results = await batch.commit();
    return results.length;
  }

  // Utility methods
  Future<List<String>> getUniqueArtists() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      columns: ['DISTINCT artist'],
      where: 'artist IS NOT NULL AND artist != ""',
      orderBy: 'artist ASC',
    );
    return maps.map((map) => map['artist'] as String).toList();
  }

  Future<List<String>> getUniqueAlbums() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      columns: ['DISTINCT album'],
      where: 'album IS NOT NULL AND album != ""',
      orderBy: 'album ASC',
    );
    return maps.map((map) => map['album'] as String).toList();
  }

  Future<List<String>> getUniqueGenres() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.songsTable,
      columns: ['DISTINCT genre'],
      where: 'genre IS NOT NULL AND genre != ""',
      orderBy: 'genre ASC',
    );
    return maps.map((map) => map['genre'] as String).toList();
  }

  Future<Map<String, int>> getLibraryStats() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalSongs,
        COUNT(DISTINCT artist) as totalArtists,
        COUNT(DISTINCT album) as totalAlbums,
        COUNT(DISTINCT genre) as totalGenres,
        SUM(duration) as totalDuration,
        COUNT(CASE WHEN isFavorite = 1 THEN 1 END) as totalFavorites
      FROM ${AppConstants.songsTable}
    ''');

    if (maps.isNotEmpty) {
      return {
        'totalSongs': maps.first['totalSongs'] ?? 0,
        'totalArtists': maps.first['totalArtists'] ?? 0,
        'totalAlbums': maps.first['totalAlbums'] ?? 0,
        'totalGenres': maps.first['totalGenres'] ?? 0,
        'totalDuration': maps.first['totalDuration'] ?? 0,
        'totalFavorites': maps.first['totalFavorites'] ?? 0,
      };
    }

    return {};
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete(AppConstants.playlistSongsTable);
    await db.delete(AppConstants.playlistsTable);
    await db.delete(AppConstants.songsTable);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
