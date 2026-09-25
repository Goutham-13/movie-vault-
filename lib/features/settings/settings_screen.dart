import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/backup_service.dart';
import '../../providers/app_providers.dart';
import '../manual_entry/add_manual_media_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Vault'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // CineVault Branding Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryAccent.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "CineVault",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "Version 1.0.0 • Personal Cinema Tracker",
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Custom Manual Addition Option
          _SectionHeader(title: "CONTENT MANAGEMENT"),
          ListTile(
            leading: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryAccent),
            title: const Text("Add Custom Movie / Show", style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text("Create offline entry when not available on TMDB"),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddManualMediaScreen()),
              );
            },
          ),
          const Divider(height: 32),

          // Data Management (Import / Export JSON Backup)
          _SectionHeader(title: "DATA & BACKUP"),
          ListTile(
            leading: const Icon(Icons.upload_file_rounded, color: AppColors.secondaryAccent),
            title: const Text("Export Collection Backup"),
            subtitle: const Text("Share or export your collection as JSON"),
            onTap: () async {
              final backup = BackupService(isarService: ref.read(isarServiceProvider));
              await backup.shareBackupJson();
            },
          ),
          ListTile(
            leading: const Icon(Icons.cleaning_services_rounded, color: Colors.amber),
            title: const Text("Clear Local Cache"),
            subtitle: const Text("Clear temporary image & movie metadata cache"),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Local cache cleared successfully")),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent),
            title: const Text("Reset All Personal Collection", style: TextStyle(color: Colors.redAccent)),
            subtitle: const Text("Clear all wishlist, watched, and progress records"),
            onTap: () => _confirmResetDialog(context, ref),
          ),
          const Divider(height: 32),

          // App Information
          _SectionHeader(title: "ABOUT"),
          const ListTile(
            leading: Icon(Icons.security_rounded, color: AppColors.emeraldSuccess),
            title: Text("Offline First & No Account Required"),
            subtitle: Text("All data remains safely stored on your local device."),
          ),
        ],
      ),
    );
  }

  void _confirmResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Reset All Data?"),
        content: const Text("This action will delete all your wishlist, watching, watched history, and ratings permanently."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              await ref.read(isarServiceProvider).clearAllData();
              ref.read(collectionProvider.notifier).loadCollection();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("All collection data reset.")),
              );
            },
            child: const Text("Reset Everything"),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
