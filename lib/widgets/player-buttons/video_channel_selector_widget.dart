import 'dart:async';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import 'package:another_iptv_player/services/event_bus.dart';
import 'package:another_iptv_player/services/player_state.dart';
import 'package:flutter/material.dart';
import '../../models/content_type.dart';

class VideoChannelSelectorWidget extends StatefulWidget {
  final List<ContentItem>? queue;
  final int? currentIndex;

  const VideoChannelSelectorWidget({
    super.key,
    this.queue,
    this.currentIndex,
  });

  @override
  State<VideoChannelSelectorWidget> createState() =>
      _VideoChannelSelectorWidgetState();
}

class _VideoChannelSelectorWidgetState
    extends State<VideoChannelSelectorWidget> {
  static OverlayEntry? _globalOverlayEntry;
  static StreamSubscription? _globalIndexSubscription;
  static StreamSubscription? _globalToggleSubscription;
  static BuildContext? _globalContext;
  
  @override
  void initState() {
    super.initState();

    // Context'i güncelle
    _globalContext = context;

    // Event listener'ı sadece bir kez oluştur
    if (_globalToggleSubscription == null) {
      _globalToggleSubscription =
          EventBus().on<bool>('toggle_channel_list').listen((bool show) {
            if (show) {
              if (_globalContext != null) {
                _showChannelSelector(_globalContext!);
              }
            } else {
              _hideChannelSelector();
            }
          });
    }
  }

  @override
  void dispose() {
    // Overlay'i kapatma - başka bir instance hala açık olabilir
    // Overlay sadece kullanıcı kapatırsa veya tüm widget'lar dispose olduğunda kapanmalı
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Queue yoksa veya tek öğe varsa butonu gösterme
    if (widget.queue == null || widget.queue!.length <= 1) {
      return const SizedBox.shrink();
    }

    // Context'i her build'de güncelle
    _globalContext = context;

    return IconButton(
      tooltip: 'Kanal Seç',
      icon: const Icon(Icons.list, color: Colors.white),
      onPressed: () {
        if (_globalOverlayEntry == null) {
          _showChannelSelector(context);
        } else {
          _hideChannelSelector();
        }
      },
    );
  }

  void _showChannelSelector(BuildContext context) {
    if (_globalOverlayEntry != null) return;

    final items = widget.queue ?? [];
    if (items.isEmpty) return;

    final currentContent = PlayerState.currentContent;
    int selectedIndex = widget.currentIndex ?? 0;
    if (currentContent != null) {
      final foundIndex = items.indexWhere((item) =>
      item.id == currentContent.id);
      if (foundIndex != -1) {
        selectedIndex = foundIndex;
      }
    }

    // Overlay'i oluşturmadan önce context'i kontrol et
    final overlayContext = _globalContext ?? context;
    
    // Overlay'i güvenli bir şekilde al
    OverlayState? overlay;
    try {
      overlay = Overlay.of(overlayContext, rootOverlay: true);
    } catch (e) {
      // Overlay bulunamazsa bir sonraki frame'de tekrar dene
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_globalOverlayEntry == null) {
          _showChannelSelector(overlayContext);
        }
      });
      return;
    }

    final screenWidth = MediaQuery.of(overlayContext).size.width;
    final panelWidth = (screenWidth / 3).clamp(200.0, 400.0);

    _globalOverlayEntry = OverlayEntry(
      builder: (context) =>
          _buildOverlay(context, items, selectedIndex, panelWidth),
    );

    overlay.insert(_globalOverlayEntry!);
    PlayerState.showChannelList = true;

    // Kanal değiştiğinde overlay'i güncelle
    _globalIndexSubscription?.cancel();
    _globalIndexSubscription =
        EventBus().on<int>('player_content_item_index').listen((int index) {
          if (_globalOverlayEntry != null) {
            _globalOverlayEntry!.markNeedsBuild();
          }
        });
  }

  void _hideChannelSelector() {
    _globalOverlayEntry?.remove();
    _globalOverlayEntry = null;
    _globalIndexSubscription?.cancel();
    _globalIndexSubscription = null;
    PlayerState.showChannelList = false;
    // Context'i null yapma - başka bir widget instance'ı hala kullanıyor olabilir
  }

  Widget _buildOverlay(BuildContext context, List<ContentItem> items,
      int selectedIndex, double panelWidth) {
    final currentContent = PlayerState.currentContent;
    int currentSelectedIndex = selectedIndex;
    if (currentContent != null) {
      final foundIndex = items.indexWhere((item) =>
      item.id == currentContent.id);
      if (foundIndex != -1) {
        currentSelectedIndex = foundIndex;
      }
    }

    return Positioned.fill(
      child: GestureDetector(
        onTap: _hideChannelSelector,
        child: Container(
          color: Colors.black.withOpacity(0.3),
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {}, // Panel içine tıklanınca kapanmasın
              child: Material(
                color: Colors.black.withOpacity(0.95),
                child: Container(
                  width: panelWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          border: Border(
                            bottom: BorderSide(
                                color: Colors.grey[800]!, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Kanal Seç',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              '${currentSelectedIndex + 1} / ${items.length}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[400],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                  Icons.close, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: _hideChannelSelector,
                            ),
                          ],
                        ),
                      ),
                      // Channel list
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final isSelected = index == currentSelectedIndex;

                            return _buildChannelListItem(
                              context,
                              item,
                              index,
                              isSelected,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChannelListItem(
    BuildContext context,
    ContentItem item,
    int index,
    bool isSelected,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          EventBus().emit('player_content_item_index_changed', index);
          // Panel kapanmasın
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  )
                : Border.all(
                    color: Colors.grey[800]!,
                    width: 1,
                  ),
          ),
          child: Row(
            children: [
              // Thumbnail
              if (item.imagePath.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    item.imagePath,
                    width: 50,
                    height: 35,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 50,
                        height: 35,
                        color: Colors.grey[800],
                        child: const Icon(
                            Icons.image, color: Colors.grey, size: 20),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 50,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                      Icons.video_library, color: Colors.grey, size: 20),
                ),
              const SizedBox(width: 10),
              // Title and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          _getContentTypeIcon(item.contentType),
                          size: 11,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            _getContentTypeDisplayName(item.contentType),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getContentTypeIcon(ContentType contentType) {
    switch (contentType) {
      case ContentType.liveStream:
        return Icons.live_tv;
      case ContentType.vod:
        return Icons.movie;
      case ContentType.series:
        return Icons.tv;
    }
  }

  String _getContentTypeDisplayName(ContentType contentType) {
    switch (contentType) {
      case ContentType.liveStream:
        return 'Canlı Yayın';
      case ContentType.vod:
        return 'Film';
      case ContentType.series:
        return 'Dizi';
    }
  }
}

