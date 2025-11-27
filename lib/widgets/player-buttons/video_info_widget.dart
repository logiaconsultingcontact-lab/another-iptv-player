import 'dart:async';
import 'package:another_iptv_player/models/playlist_content_model.dart';
import 'package:another_iptv_player/services/app_state.dart';
import 'package:another_iptv_player/services/player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/content_type.dart';

class VideoInfoWidget extends StatelessWidget {
  const VideoInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Video Bilgileri',
      icon: const Icon(Icons.info_outline, color: Colors.white),
      onPressed: () => _showVideoInfo(context),
    );
  }

  void _showVideoInfo(BuildContext context) {
    final currentContent = PlayerState.currentContent;
    
    if (currentContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Video bilgisi bulunamadı'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Video Bilgileri',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        context,
                        'İsim',
                        currentContent.name,
                        Icons.title,
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'İçerik Tipi',
                        _getContentTypeDisplayName(currentContent.contentType),
                        Icons.category,
                      ),
                      if (currentContent.description != null &&
                          currentContent.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'Açıklama',
                          currentContent.description!,
                          Icons.description,
                          isMultiline: true,
                        ),
                      ],
                      if (currentContent.duration != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'Süre',
                          _formatDuration(currentContent.duration),
                          Icons.access_time,
                        ),
                      ],
                      if (currentContent.vodStream != null) ...[
                        if (currentContent.vodStream!.rating.isNotEmpty &&
                            currentContent.vodStream!.rating != '0') ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Değerlendirme',
                            currentContent.vodStream!.rating,
                            Icons.star,
                          ),
                        ],
                        if (currentContent.vodStream!.genre != null &&
                            currentContent.vodStream!.genre!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Tür',
                            currentContent.vodStream!.genre!,
                            Icons.movie,
                          ),
                        ],
                      ],
                      if (currentContent.seriesStream != null) ...[
                        if (currentContent.seriesStream!.plot != null &&
                            currentContent.seriesStream!.plot!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Konu',
                            currentContent.seriesStream!.plot!,
                            Icons.article,
                            isMultiline: true,
                          ),
                        ],
                        if (currentContent.seriesStream!.cast != null &&
                            currentContent.seriesStream!.cast!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Oyuncular',
                            currentContent.seriesStream!.cast!,
                            Icons.people,
                          ),
                        ],
                        if (currentContent.seriesStream!.director != null &&
                            currentContent.seriesStream!.director!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Yönetmen',
                            currentContent.seriesStream!.director!,
                            Icons.person,
                          ),
                        ],
                        if (currentContent.seriesStream!.genre != null &&
                            currentContent.seriesStream!.genre!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Tür',
                            currentContent.seriesStream!.genre!,
                            Icons.movie,
                          ),
                        ],
                        if (currentContent.seriesStream!.releaseDate != null &&
                            currentContent.seriesStream!.releaseDate!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Yayın Tarihi',
                            currentContent.seriesStream!.releaseDate!,
                            Icons.calendar_today,
                          ),
                        ],
                        if (currentContent.seriesStream!.rating != null &&
                            currentContent.seriesStream!.rating!.isNotEmpty &&
                            currentContent.seriesStream!.rating != '0') ...[
                          const SizedBox(height: 12),
                          _buildInfoRow(
                            context,
                            'Değerlendirme',
                            currentContent.seriesStream!.rating!,
                            Icons.star,
                          ),
                        ],
                      ],
                      if (currentContent.liveStream != null &&
                          currentContent.liveStream!.epgChannelId.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildInfoRow(
                          context,
                          'EPG Kanal ID',
                          currentContent.liveStream!.epgChannelId,
                          Icons.live_tv,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildInfoRow(
                        context,
                        'URL',
                        currentContent.url,
                        Icons.link,
                        isCopyable: true,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Bilinmiyor';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}s ${minutes}dk ${seconds}sn';
    } else if (minutes > 0) {
      return '${minutes}dk ${seconds}sn';
    } else {
      return '${seconds}sn';
    }
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isMultiline = false,
    bool isCopyable = false,
  }) {
    return InkWell(
      onTap: isCopyable
          ? () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL panoya kopyalandı'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    maxLines: isMultiline ? null : 2,
                    overflow: isMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isCopyable)
              Icon(
                Icons.copy,
                size: 18,
                color: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
}

