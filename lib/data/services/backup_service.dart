import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import '../models/media_item.dart';
import '../services/isar_service.dart';

class BackupService {
  final IsarService _isarService;

  BackupService({IsarService? isarService})
      : _isarService = isarService ?? IsarService();

  Future<String> exportCollectionJson() async {
    final mediaItems = await _isarService.getAllMediaItems();
    final collectionEntries = await _isarService.getAllCollectionEntries();
    final watchProgress = await _isarService.getAllWatchProgress();
    final reminders = await _isarService.getAllReminders();

    final exportData = {
      'app': 'CineVault',
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
      'mediaItems': mediaItems.map((m) => m.toMap()).toList(),
      'collectionEntries': collectionEntries.map((c) => c.toMap()).toList(),
      'watchProgress': watchProgress.map((w) => w.toMap()).toList(),
      'reminders': reminders.map((r) => r.toMap()).toList(),
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  Future<void> shareBackupJson() async {
    final jsonStr = await exportCollectionJson();
    await Share.share(jsonStr, subject: 'CineVault Backup Data');
  }

  Future<bool> importCollectionJson(String jsonStr) async {
    try {
      final data = jsonDecode(jsonStr) as Map<String, dynamic>;
      if (data['app'] != 'CineVault') {
        throw Exception("Invalid backup file structure");
      }

      if (data['mediaItems'] != null) {
        for (final m in data['mediaItems']) {
          final map = Map<String, dynamic>.from(m as Map);
          if (map['genres'] is String) {
            try {
              map['genres'] = jsonDecode(map['genres'] as String);
            } catch (_) {
              map['genres'] = [];
            }
          }
          await _isarService.saveMediaItem(MediaItem.fromMap(map));
        }
      }

      return true;
    } catch (e) {
      debugPrint("Error importing backup: $e");
      return false;
    }
  }
}
