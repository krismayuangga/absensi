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
      ),/../../core/providers/info_media_provider.dart';

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

    // Load media gallery when first time opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InfoMediaProvider>(context, listen: false)
          .loadMediaGallery(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<InfoMediaProvider>(context, listen: false).loadMoreMedia();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<InfoMediaProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.loadMediaGallery(refresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Header and filters
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Galeri Media',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Type filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildTypeFilterChip('Semua', 'all'),
                            SizedBox(width: 8.w),
                            _buildTypeFilterChip('Foto', 'image'),
                            SizedBox(width: 8.w),
                            _buildTypeFilterChip('Dokumen', 'document'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Media grid
              if (provider.isLoading && provider.mediaItems.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
              else if (provider.mediaItems.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          size: 64.r,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Belum ada media',
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.8,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.mediaItems.length) {
                          return provider.isLoadingMore
                              ? Container(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                      color: Colors.blue),
                                )
                              : const SizedBox.shrink();
                        }

                        final media = provider.mediaItems[index];
                        return _buildMediaCard(media);
                      },
                      childCount: provider.mediaItems.length +
                          (provider.hasMoreMedia ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeFilterChip(String label, String type) {
    return Consumer<InfoMediaProvider>(
      builder: (context, provider, child) {
        final isSelected = provider.selectedMediaType == type;
        return GestureDetector(
          onTap: () => provider.setSelectedMediaType(type),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaCard(Map<String, dynamic> media) {
    final fileType = media['file_type'] as String? ?? 'document';
    final title = media['title'] as String? ?? 'Untitled';
    final description = media['description'] as String? ?? '';
    final createdAt = media['created_at'] as String? ?? '';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _openMediaDetail(media),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media preview
              Expanded(
                flex: 3,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.r),
                    ),
                  ),
                  child: fileType == 'image'
                      ? _buildImagePreview(media)
                      : _buildDocumentPreview(media),
                ),
              ),

              // Media info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),

                      // Description
                      if (description.isNotEmpty) ...[
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                      ],

                      // Date and file info
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  _getFileTypeIcon(fileType),
                                  size: 14.r,
                                  color: Colors.grey.shade500,
                                ),
                                SizedBox(width: 4.w),
                                Expanded(
                                  child: Text(
                                    _getFileTypeLabel(fileType),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10.sp,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              createdAt,
                              style: GoogleFonts.poppins(
                                fontSize: 9.sp,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
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

  Widget _buildImagePreview(Map<String, dynamic> media) {
    final fileUrl = media['file_url'] as String? ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      child: fileUrl.isNotEmpty
          ? Image.network(
              fileUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderPreview(Icons.image, Colors.blue);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    color: Colors.blue,
                  ),
                );
              },
            )
          : _buildPlaceholderPreview(Icons.image, Colors.blue),
    );
  }

  Widget _buildDocumentPreview(Map<String, dynamic> media) {
    return _buildPlaceholderPreview(Icons.description, Colors.orange);
  }

  Widget _buildPlaceholderPreview(IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
      ),
      child: Center(
        child: Icon(
          icon,
          size: 48.r,
          color: color.withOpacity(0.6),
        ),
      ),
    );
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return Icons.image;
      case 'document':
        return Icons.description;
      case 'video':
        return Icons.videocam;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _getFileTypeLabel(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return 'Gambar';
      case 'document':
        return 'Dokumen';
      case 'video':
        return 'Video';
      default:
        return 'File';
    }
  }

  void _openMediaDetail(Map<String, dynamic> media) {
    showDialog(
      context: context,
      builder: (context) => _MediaDetailDialog(media: media),
    );
  }
}

class _MediaDetailDialog extends StatelessWidget {
  final Map<String, dynamic> media;

  const _MediaDetailDialog({required this.media});

  @override
  Widget build(BuildContext context) {
    final fileType = media['file_type'] as String? ?? 'document';
    final title = media['title'] as String? ?? 'Untitled';
    final description = media['description'] as String? ?? '';
    final fileSize = media['formatted_size'] as String? ?? '';
    final createdAt = media['created_at'] as String? ?? '';
    final uploader = media['uploader']?['name'] as String? ?? 'Admin';

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Media preview
                    Container(
                      width: double.infinity,
                      height: 200.h,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: fileType == 'image'
                          ? _buildFullImagePreview()
                          : _buildFullDocumentPreview(),
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    if (description.isNotEmpty) ...[
                      Text(
                        'Deskripsi',
                        style: GoogleFonts.poppins(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          color: Colors.grey.shade700,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // File info
                    _buildInfoRow('Jenis File', _getFileTypeLabel(fileType)),
                    if (fileSize.isNotEmpty)
                      _buildInfoRow('Ukuran File', fileSize),
                    _buildInfoRow('Diunggah oleh', uploader),
                    _buildInfoRow('Tanggal Upload', createdAt),
                  ],
                ),
              ),
            ),

            // Actions
            Container(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _downloadMedia(context),
                      icon: Icon(Icons.download),
                      label: Text('Download'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullImagePreview() {
    final fileUrl = media['file_url'] as String? ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.r),
      child: fileUrl.isNotEmpty
          ? Image.network(
              fileUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildFullPlaceholder(Icons.image, Colors.blue);
              },
            )
          : _buildFullPlaceholder(Icons.image, Colors.blue),
    );
  }

  Widget _buildFullDocumentPreview() {
    return _buildFullPlaceholder(Icons.description, Colors.orange);
  }

  Widget _buildFullPlaceholder(IconData icon, Color color) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64.r,
              color: color.withOpacity(0.6),
            ),
            SizedBox(height: 8.h),
            Text(
              _getFileTypeLabel(media['file_type'] as String? ?? 'document'),
              style: GoogleFonts.poppins(
                fontSize: 14.sp,
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getFileTypeLabel(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'image':
        return 'Gambar';
      case 'document':
        return 'Dokumen';
      case 'video':
        return 'Video';
      default:
        return 'File';
    }
  }

  void _downloadMedia(BuildContext context) {
    // TODO: Implement download functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Fitur download akan segera tersedia'),
        backgroundColor: Colors.blue,
      ),
    );
    Navigator.pop(context);
  }
}
