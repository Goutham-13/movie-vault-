import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqlite;
import 'package:path/path.dart' as p;
import '../models/media_item.dart';
import '../models/collection_entry.dart';
import '../models/watch_progress.dart';
import '../models/watch_reminder.dart';
import '../models/tv_episode.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  sqlite.Database? _db;

  Future<void> init() async {
    if (_db != null) return;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final dbPath = p.join(docsDir.path, 'cinevault_isar.db');
      
      _db = await sqlite.openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE media_items (
              localId TEXT PRIMARY KEY,
              tmdbId INTEGER,
              mediaType TEXT NOT NULL,
              title TEXT NOT NULL,
              originalTitle TEXT,
              overview TEXT,
              posterPath TEXT,
              backdropPath TEXT,
              releaseDate TEXT,
              year INTEGER,
              originalLanguage TEXT,
              genres TEXT,
              runtime INTEGER,
              voteAverage REAL,
              voteCount INTEGER,
              popularity REAL,
              adult INTEGER,
              source TEXT,
              createdAt TEXT,
              updatedAt TEXT
            )
          ''');

          await db.execute('''
            CREATE TABLE collection_entries (
              mediaId TEXT PRIMARY KEY,
              status TEXT NOT NULL,
              isFavorite INTEGER NOT NULL,
              personalRating REAL NOT NULL,
              addedAt TEXT NOT NULL,
              watchedAt TEXT,
              notes TEXT,
              lastUpdated TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE watch_progress (
              mediaId TEXT PRIMARY KEY,
              mediaType TEXT NOT NULL,
              currentPositionSeconds INTEGER NOT NULL,
              totalDurationSeconds INTEGER NOT NULL,
              progressPercentage REAL NOT NULL,
              currentSeason INTEGER,
              currentEpisode INTEGER,
              episodeDurationSeconds INTEGER,
              lastUpdated TEXT NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE watch_reminders (
              notificationId INTEGER PRIMARY KEY,
              mediaId TEXT NOT NULL,
              title TEXT NOT NULL,
              reminderDateTime TEXT NOT NULL,
              enabled INTEGER NOT NULL
            )
          ''');

          await db.execute('''
            CREATE TABLE tv_episodes (
              id TEXT PRIMARY KEY,
              mediaId TEXT NOT NULL,
              seasonNumber INTEGER NOT NULL,
              episodeNumber INTEGER NOT NULL,
              title TEXT NOT NULL,
              overview TEXT,
              stillPath TEXT,
              durationMinutes INTEGER,
              isWatched INTEGER NOT NULL,
              watchedAt TEXT
            )
          ''');
        },
      );
      debugPrint("CineVault Isar Service initialized successfully");
    } catch (e, st) {
      debugPrint("Error initializing IsarService: $e\n$st");
    }
  }

  // --- MEDIA ITEM CRUD ---

  Future<void> saveMediaItem(MediaItem item) async {
    final db = _db;
    if (db == null) return;
    final map = item.toMap();
    map.remove('id');
    map['genres'] = jsonEncode(item.genres);
    map['adult'] = item.adult ? 1 : 0;
    
    await db.insert(
      'media_items',
      map,
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<MediaItem?> getMediaItem(String localId) async {
    final db = _db;
    if (db == null) return null;
    final maps = await db.query(
      'media_items',
      where: 'localId = ?',
      whereArgs: [localId],
    );
    if (maps.isEmpty) return null;
    final map = Map<String, dynamic>.from(maps.first);
    if (map['genres'] is String) {
      try {
        map['genres'] = jsonDecode(map['genres'] as String);
      } catch (_) {
        map['genres'] = [];
      }
    }
    map['adult'] = (map['adult'] as int?) == 1;
    return MediaItem.fromMap(map);
  }

  Future<List<MediaItem>> getAllMediaItems() async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query('media_items');
    return maps.map((m) {
      final map = Map<String, dynamic>.from(m);
      if (map['genres'] is String) {
        try {
          map['genres'] = jsonDecode(map['genres'] as String);
        } catch (_) {
          map['genres'] = [];
        }
      }
      map['adult'] = (map['adult'] as int?) == 1;
      return MediaItem.fromMap(map);
    }).toList();
  }

  // --- COLLECTION ENTRY CRUD ---

  Future<void> saveCollectionEntry(CollectionEntry entry) async {
    final db = _db;
    if (db == null) return;
    await db.insert(
      'collection_entries',
      {
        'mediaId': entry.mediaId,
        'status': entry.status,
        'isFavorite': entry.isFavorite ? 1 : 0,
        'personalRating': entry.personalRating,
        'addedAt': entry.addedAt.toIso8601String(),
        'watchedAt': entry.watchedAt?.toIso8601String(),
        'notes': entry.notes,
        'lastUpdated': entry.lastUpdated.toIso8601String(),
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<CollectionEntry?> getCollectionEntry(String mediaId) async {
    final db = _db;
    if (db == null) return null;
    final maps = await db.query(
      'collection_entries',
      where: 'mediaId = ?',
      whereArgs: [mediaId],
    );
    if (maps.isEmpty) return null;
    final m = maps.first;
    return CollectionEntry(
      mediaId: m['mediaId'] as String,
      status: m['status'] as String,
      isFavorite: (m['isFavorite'] as int) == 1,
      personalRating: (m['personalRating'] as num).toDouble(),
      addedAt: DateTime.parse(m['addedAt'] as String),
      watchedAt: m['watchedAt'] != null ? DateTime.parse(m['watchedAt'] as String) : null,
      notes: m['notes'] as String?,
      lastUpdated: DateTime.parse(m['lastUpdated'] as String),
    );
  }

  Future<List<CollectionEntry>> getAllCollectionEntries() async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query('collection_entries', orderBy: 'lastUpdated DESC');
    return maps.map((m) {
      return CollectionEntry(
        mediaId: m['mediaId'] as String,
        status: m['status'] as String,
        isFavorite: (m['isFavorite'] as int) == 1,
        personalRating: (m['personalRating'] as num).toDouble(),
        addedAt: DateTime.parse(m['addedAt'] as String),
        watchedAt: m['watchedAt'] != null ? DateTime.parse(m['watchedAt'] as String) : null,
        notes: m['notes'] as String?,
        lastUpdated: DateTime.parse(m['lastUpdated'] as String),
      );
    }).toList();
  }

  Future<void> deleteCollectionEntry(String mediaId) async {
    final db = _db;
    if (db == null) return;
    await db.delete('collection_entries', where: 'mediaId = ?', whereArgs: [mediaId]);
    await db.delete('watch_progress', where: 'mediaId = ?', whereArgs: [mediaId]);
  }

  // --- WATCH PROGRESS CRUD ---

  Future<void> saveWatchProgress(WatchProgress progress) async {
    final db = _db;
    if (db == null) return;
    await db.insert(
      'watch_progress',
      {
        'mediaId': progress.mediaId,
        'mediaType': progress.mediaType,
        'currentPositionSeconds': progress.currentPositionSeconds,
        'totalDurationSeconds': progress.totalDurationSeconds,
        'progressPercentage': progress.progressPercentage,
        'currentSeason': progress.currentSeason,
        'currentEpisode': progress.currentEpisode,
        'episodeDurationSeconds': progress.episodeDurationSeconds,
        'lastUpdated': progress.lastUpdated.toIso8601String(),
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<WatchProgress?> getWatchProgress(String mediaId) async {
    final db = _db;
    if (db == null) return null;
    final maps = await db.query(
      'watch_progress',
      where: 'mediaId = ?',
      whereArgs: [mediaId],
    );
    if (maps.isEmpty) return null;
    final m = maps.first;
    return WatchProgress(
      mediaId: m['mediaId'] as String,
      mediaType: m['mediaType'] as String,
      currentPositionSeconds: m['currentPositionSeconds'] as int? ?? 0,
      totalDurationSeconds: m['totalDurationSeconds'] as int? ?? 0,
      progressPercentage: (m['progressPercentage'] as num).toDouble(),
      currentSeason: m['currentSeason'] as int?,
      currentEpisode: m['currentEpisode'] as int?,
      episodeDurationSeconds: m['episodeDurationSeconds'] as int? ?? 0,
      lastUpdated: DateTime.parse(m['lastUpdated'] as String),
    );
  }

  Future<List<WatchProgress>> getAllWatchProgress() async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query('watch_progress', orderBy: 'lastUpdated DESC');
    return maps.map((m) {
      return WatchProgress(
        mediaId: m['mediaId'] as String,
        mediaType: m['mediaType'] as String,
        currentPositionSeconds: m['currentPositionSeconds'] as int? ?? 0,
        totalDurationSeconds: m['totalDurationSeconds'] as int? ?? 0,
        progressPercentage: (m['progressPercentage'] as num).toDouble(),
        currentSeason: m['currentSeason'] as int?,
        currentEpisode: m['currentEpisode'] as int?,
        episodeDurationSeconds: m['episodeDurationSeconds'] as int? ?? 0,
        lastUpdated: DateTime.parse(m['lastUpdated'] as String),
      );
    }).toList();
  }

  // --- REMINDERS CRUD ---

  Future<void> saveReminder(WatchReminder reminder) async {
    final db = _db;
    if (db == null) return;
    await db.insert(
      'watch_reminders',
      {
        'notificationId': reminder.notificationId,
        'mediaId': reminder.mediaId,
        'title': reminder.title,
        'reminderDateTime': reminder.reminderDateTime.toIso8601String(),
        'enabled': reminder.enabled ? 1 : 0,
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<List<WatchReminder>> getAllReminders() async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query('watch_reminders', orderBy: 'reminderDateTime ASC');
    return maps.map((m) {
      return WatchReminder(
        notificationId: m['notificationId'] as int,
        mediaId: m['mediaId'] as String,
        title: m['title'] as String,
        reminderDateTime: DateTime.parse(m['reminderDateTime'] as String),
        enabled: (m['enabled'] as int) == 1,
      );
    }).toList();
  }

  Future<void> deleteReminder(int notificationId) async {
    final db = _db;
    if (db == null) return;
    await db.delete('watch_reminders', where: 'notificationId = ?', whereArgs: [notificationId]);
  }

  // --- TV EPISODES CRUD ---

  Future<void> saveTVEpisode(TVEpisodeItem episode) async {
    final db = _db;
    if (db == null) return;
    final epId = '${episode.mediaId}_S${episode.seasonNumber}_E${episode.episodeNumber}';
    await db.insert(
      'tv_episodes',
      {
        'id': epId,
        'mediaId': episode.mediaId,
        'seasonNumber': episode.seasonNumber,
        'episodeNumber': episode.episodeNumber,
        'title': episode.title,
        'overview': episode.overview,
        'stillPath': episode.stillPath,
        'durationMinutes': episode.durationMinutes,
        'isWatched': episode.isWatched ? 1 : 0,
        'watchedAt': episode.watchedAt?.toIso8601String(),
      },
      conflictAlgorithm: sqlite.ConflictAlgorithm.replace,
    );
  }

  Future<List<TVEpisodeItem>> getTVEpisodesForMedia(String mediaId) async {
    final db = _db;
    if (db == null) return [];
    final maps = await db.query(
      'tv_episodes',
      where: 'mediaId = ?',
      whereArgs: [mediaId],
      orderBy: 'seasonNumber ASC, episodeNumber ASC',
    );
    return maps.map((m) {
      return TVEpisodeItem(
        mediaId: m['mediaId'] as String,
        seasonNumber: m['seasonNumber'] as int,
        episodeNumber: m['episodeNumber'] as int,
        title: m['title'] as String,
        overview: m['overview'] as String?,
        stillPath: m['stillPath'] as String?,
        durationMinutes: m['durationMinutes'] as int? ?? 45,
        isWatched: (m['isWatched'] as int) == 1,
        watchedAt: m['watchedAt'] != null ? DateTime.parse(m['watchedAt'] as String) : null,
      );
    }).toList();
  }

  // --- CLEAR / RESET DATA ---

  Future<void> clearAllData() async {
    final db = _db;
    if (db == null) return;
    await db.delete('media_items');
    await db.delete('collection_entries');
    await db.delete('watch_progress');
    await db.delete('watch_reminders');
    await db.delete('tv_episodes');
  }
}
