import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/info_media_provider.dart';

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<InfoMediaProvider>();
      if (!provider.isLoadingMore && provider.hasMoreMedia) {
        provider.loadMediaGallery();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<InfoMediaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.mediaItems.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          if (provider.mediaItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64.w,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Belum ada media',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Media gallery akan muncul di sini',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await provider.loadMediaGallery(refresh: true);
            },
            color: Colors.blue,
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount:
                  provider.mediaItems.length + (provider.isLoadingMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= provider.mediaItems.length) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                      strokeWidth: 2.w,
                    ),
                  );
                }

                final media = provider.mediaItems[index];
                return _buildMediaCard(media);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> media) {
    final theme = Theme.of(context);
    final type = media['type'] as String? ?? 'image';
    final title = media['title'] as String? ?? 'Untitled';
    final description = media['description'] as String? ?? '';
    final createdAt = media['created_at'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Media Preview
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Stack(
              children: [
                if (type == 'image')
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12.r)),
                      image: media['file_url'] != null
                          ? DecorationImage(
                              image: NetworkImage(media['file_url']),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: media['file_url'] == null
                        ? Icon(
                            Icons.image,
                            size: 40.w,
                            color: Colors.grey.shade400,
                          )
                        : null,
                  )
                else
                  Center(
                    child: Icon(
                      _getFileIcon(type),
                      size: 40.w,
                      color: Colors.blue,
                    ),
                  ),
                // Type Badge
                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: _getTypeColor(type),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12.w,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          createdAt,
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            color: Colors.grey.shade500,
                          ),
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  IconData _getFileIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'video':
        return Icons.play_circle_fill;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'image':
        return Colors.green;
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'video':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
