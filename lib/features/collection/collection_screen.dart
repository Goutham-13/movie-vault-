import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/media_item.dart';
import '../../data/models/collection_entry.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state_view.dart';
import '../details/media_details_screen.dart';
import 'widgets/folder_card_widget.dart';
import 'widgets/media_file_card_widget.dart';

class CollectionScreen extends ConsumerStatefulWidget {
  const CollectionScreen({super.key});

  @override
  ConsumerState<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends ConsumerState<CollectionScreen>
    with SingleTickerProviderStateMixin {
  String? _openedFolderKey; // null = 2-column folder grid, 'wishlist', 'watching', 'watched', 'favorites'

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _openFolder(String key) {
    setState(() {
      _openedFolderKey = key;
    });
    _animationController.forward(from: 0.0);
  }

  void _closeFolder() {
    _animationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _openedFolderKey = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final wishlistItems = ref.watch(wishlistProvider);
    final watchingItems = ref.watch(continueWatchingProvider);
    final watchedItems = ref.watch(watchedProvider);
    final favoriteItems = ref.watch(favoritesProvider);
    final filterState = ref.watch(collectionFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _openedFolderKey == null
              ? 'Collection Folders'
              : '📁 ${_getFolderTitle(_openedFolderKey!)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _openedFolderKey != null
            ? IconButton(
                icon: const Icon(CupertinoIcons.chevron_back, color: AppColors.textPrimary, size: 24),
                onPressed: _closeFolder,
              )
            : null,
        actions: [
          if (_openedFolderKey != null)
            IconButton(
              icon: const Icon(CupertinoIcons.slider_horizontal_3, color: AppColors.textPrimary),
              onPressed: () => _showFilterBottomSheet(context),
            ),
        ],
      ),
      body: PopScope(
        canPop: _openedFolderKey == null,
        onPopInvoked: (didPop) {
          if (!didPop && _openedFolderKey != null) {
            _closeFolder();
          }
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _openedFolderKey == null
              ? _buildFoldersGrid(
                  wishlist: wishlistItems,
                  watching: watchingItems,
                  watched: watchedItems,
                  favorites: favoriteItems,
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: _buildOpenedFolderContent(
                      folderKey: _openedFolderKey!,
                      items: _getFolderItems(_openedFolderKey!, wishlistItems, watchingItems, watchedItems, favoriteItems),
                      filterState: filterState,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // 2-Column Grid Layout for 3D Collection Folders (No extra text headers)
  Widget _buildFoldersGrid({
    required List<Map<String, dynamic>> wishlist,
    required List<Map<String, dynamic>> watching,
    required List<Map<String, dynamic>> watched,
    required List<Map<String, dynamic>> favorites,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.88,
        children: [
          // 1. Wishlist Folder (Cyan / Blue Accent)
          FolderCardWidget(
            folderTitle: "WISHLIST",
            folderSubtitle: "Saved Movies",
            folderColor: AppColors.wishlistChip,
            folderIcon: CupertinoIcons.bookmark_fill,
            items: wishlist,
            onTap: () => _openFolder('wishlist'),
          ),

          // 2. Watching Folder (Amber / Gold Accent)
          FolderCardWidget(
            folderTitle: "IN PROGRESS",
            folderSubtitle: "Watching",
            folderColor: AppColors.watchingChip,
            folderIcon: CupertinoIcons.play_circle_fill,
            items: watching,
            onTap: () => _openFolder('watching'),
          ),

          // 3. Watched Folder (Emerald / Green Accent)
          FolderCardWidget(
            folderTitle: "WATCHED",
            folderSubtitle: "Completed",
            folderColor: AppColors.watchedChip,
            folderIcon: CupertinoIcons.check_mark_circled_solid,
            items: watched,
            onTap: () => _openFolder('watched'),
          ),

          // 4. Favorites Folder (Crimson / Pink Accent)
          FolderCardWidget(
            folderTitle: "FAVORITES",
            folderSubtitle: "Favorites",
            folderColor: AppColors.favoritePink,
            folderIcon: CupertinoIcons.heart_fill,
            items: favorites,
            onTap: () => _openFolder('favorites'),
          ),
        ],
      ),
    );
  }

  // Opened Folder Content View with Media File Cards
  Widget _buildOpenedFolderContent({
    required String folderKey,
    required List<Map<String, dynamic>> items,
    required FilterState filterState,
  }) {
    if (items.isEmpty) {
      return EmptyStateView(
        icon: _getFolderIcon(folderKey),
        title: "${_getFolderTitle(folderKey)} is Empty",
        description: "No media files stored in this folder yet.",
        buttonText: "Back to Folders",
        onButtonPressed: _closeFolder,
      );
    }

    return Column(
      children: [
        // Back to Folders Banner with iOS Chevron Icon
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.cardElevated,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Icon(_getFolderIcon(folderKey), color: _getFolderColor(folderKey), size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "${items.length} Files in Folder",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              TextButton.icon(
                onPressed: _closeFolder,
                icon: const Icon(CupertinoIcons.folder_fill, size: 16),
                label: const Text("Folders", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // Filter Chips if active
        if (filterState.genre != null || filterState.year != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                if (filterState.genre != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Chip(
                      label: Text(filterState.genre!),
                      onDeleted: () {
                        ref.read(collectionFilterProvider.notifier).state =
                            filterState.copyWith(genre: null);
                      },
                    ),
                  ),
                if (filterState.year != null)
                  Chip(
                    label: Text('${filterState.year}'),
                    onDeleted: () {
                      ref.read(collectionFilterProvider.notifier).state =
                          filterState.copyWith(year: null);
                    },
                  ),
              ],
            ),
          ),

        // File List Layout
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final media = item['media'] as MediaItem;
              final entry = item['entry'] as CollectionEntry;

              return MediaFileCardWidget(
                media: media,
                entry: entry,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MediaDetailsScreen(mediaItem: media)),
                  );
                },
                onDelete: () {
                  ref.read(collectionProvider.notifier).remove(media.localId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _getFolderTitle(String key) {
    switch (key) {
      case 'wishlist':
        return 'Wishlist';
      case 'watching':
        return 'In Progress';
      case 'watched':
        return 'Watched History';
      case 'favorites':
        return 'Favorites';
      default:
        return 'Folder';
    }
  }

  Color _getFolderColor(String key) {
    switch (key) {
      case 'wishlist':
        return AppColors.wishlistChip;
      case 'watching':
        return AppColors.watchingChip;
      case 'watched':
        return AppColors.watchedChip;
      case 'favorites':
        return AppColors.favoritePink;
      default:
        return AppColors.primaryAccent;
    }
  }

  IconData _getFolderIcon(String key) {
    switch (key) {
      case 'wishlist':
        return CupertinoIcons.bookmark_fill;
      case 'watching':
        return CupertinoIcons.play_circle_fill;
      case 'watched':
        return CupertinoIcons.check_mark_circled_solid;
      case 'favorites':
        return CupertinoIcons.heart_fill;
      default:
        return CupertinoIcons.folder_fill;
    }
  }

  List<Map<String, dynamic>> _getFolderItems(
    String key,
    List<Map<String, dynamic>> wishlist,
    List<Map<String, dynamic>> watching,
    List<Map<String, dynamic>> watched,
    List<Map<String, dynamic>> favorites,
  ) {
    switch (key) {
      case 'wishlist':
        return wishlist;
      case 'watching':
        return watching;
      case 'watched':
        return watched;
      case 'favorites':
        return favorites;
      default:
        return [];
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Filter & Sort Collection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Apply Filters"),
              ),
            ],
          ),
        );
      },
    );
  }
}
