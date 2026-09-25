import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/api_constants.dart';
import '../../../data/models/media_item.dart';

class FolderCardWidget extends StatefulWidget {
  final String folderTitle;
  final String folderSubtitle;
  final Color folderColor;
  final IconData folderIcon;
  final List<Map<String, dynamic>> items;
  final VoidCallback onTap;

  const FolderCardWidget({
    super.key,
    required this.folderTitle,
    required this.folderSubtitle,
    required this.folderColor,
    required this.folderIcon,
    required this.items,
    required this.onTap,
  });

  @override
  State<FolderCardWidget> createState() => _FolderCardWidgetState();
}

class _FolderCardWidgetState extends State<FolderCardWidget> with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _pressController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    _pressController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = widget.items.map((e) => e['media'] as MediaItem).toList();

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          height: 175,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. 3D Folder Back Flap
              Positioned(
                top: 14,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.folderColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: widget.folderColor.withOpacity(0.5), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Folder Top Tab Ear
              Positioned(
                top: 2,
                left: 14,
                child: Container(
                  width: 75,
                  height: 20,
                  decoration: BoxDecoration(
                    color: widget.folderColor.withOpacity(0.45),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    border: Border.all(color: widget.folderColor.withOpacity(0.6), width: 1.2),
                  ),
                ),
              ),

              // 3. Document File Sheets Peeking out 3D from inside the folder (ONLY IF NOT EMPTY)
              if (widget.items.isNotEmpty) ...[
                // Sheet 1: Left Paper File (tilted left)
                Positioned(
                  top: 14,
                  left: 20,
                  child: Transform.rotate(
                    angle: -0.16,
                    child: _buildFilePaperCard(
                      media: mediaList.isNotEmpty ? mediaList[0] : null,
                      width: 44,
                      height: 60,
                    ),
                  ),
                ),
                // Sheet 2: Right Paper File (tilted right)
                Positioned(
                  top: 14,
                  right: 20,
                  child: Transform.rotate(
                    angle: 0.16,
                    child: _buildFilePaperCard(
                      media: mediaList.length > 1 ? mediaList[1] : (mediaList.isNotEmpty ? mediaList[0] : null),
                      width: 44,
                      height: 60,
                    ),
                  ),
                ),
                // Sheet 3: Center Paper File (upright, highest)
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Transform.rotate(
                      angle: -0.02,
                      child: _buildFilePaperCard(
                        media: mediaList.length > 2 ? mediaList[2] : (mediaList.isNotEmpty ? mediaList[0] : null),
                        width: 48,
                        height: 66,
                        isPrimary: true,
                      ),
                    ),
                  ),
                ),
              ],

              // 4. Front Folder Pocket Sleeve with Title Label & Item Count Badge
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.folderColor.withOpacity(0.9),
                        AppColors.cardElevated.withOpacity(0.98),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: widget.folderColor.withOpacity(0.6), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: widget.folderColor.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(widget.folderIcon, color: Colors.white, size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.12)),
                            ),
                            child: Text(
                              '${widget.items.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.folderTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.folderSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build document file paper card (matching reference image UI with white paper file style)
  Widget _buildFilePaperCard({
    MediaItem? media,
    required double width,
    required double height,
    bool isPrimary = false,
  }) {
    final posterUrl = media != null
        ? ApiConstants.getPosterUrl(media.posterPath, quality: 'w185')
        : '';

    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC), // White paper document sheet
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paper Top Header (Mini Poster Image or Title Bar)
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: posterUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => Container(color: const Color(0xFFCBD5E1)),
                      errorWidget: (context, url, error) => Container(
                        color: widget.folderColor.withOpacity(0.3),
                        child: Icon(widget.folderIcon, size: 14, color: widget.folderColor),
                      ),
                    )
                  : Container(
                      color: widget.folderColor.withOpacity(0.3),
                      child: Center(
                        child: Icon(widget.folderIcon, size: 14, color: widget.folderColor),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 3),
          // Document Lines (matching white presentation file document lines in reference image)
          Container(
            height: 3,
            width: width * 0.8,
            decoration: BoxDecoration(
              color: const Color(0xFF94A3B8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            height: 3,
            width: width * 0.5,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
