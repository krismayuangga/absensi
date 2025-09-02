import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/info_media_provider.dart';
import 'announcement_detail_screen.dart';

class AnnouncementListScreen extends StatefulWidget {
  const AnnouncementListScreen({super.key});

  @override
  State<AnnouncementListScreen> createState() => _AnnouncementListScreenState();
}

class _AnnouncementListScreenState extends State<AnnouncementListScreen>
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
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      // Load more when near bottom
      Provider.of<InfoMediaProvider>(context, listen: false)
          .loadMoreAnnouncements();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<InfoMediaProvider>(
      builder: (context, provider, child) {
        return RefreshIndicator(
          onRefresh: () => provider.loadAnnouncements(refresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Filters
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pengumuman Terbaru',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Filter chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip(
                              'Semua',
                              provider.selectedPriority == null,
                              () => provider.setSelectedPriority(null),
                              Colors.blue,
                            ),
                            SizedBox(width: 8.w),
                            _buildFilterChip(
                              'Mendesak',
                              provider.selectedPriority == 'urgent',
                              () => provider.setSelectedPriority('urgent'),
                              Colors.red,
                            ),
                            SizedBox(width: 8.w),
                            _buildFilterChip(
                              'Penting',
                              provider.selectedPriority == 'high',
                              () => provider.setSelectedPriority('high'),
                              Colors.orange,
                            ),
                            SizedBox(width: 8.w),
                            _buildFilterChip(
                              'Sedang',
                              provider.selectedPriority == 'medium',
                              () => provider.setSelectedPriority('medium'),
                              Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Announcements list
              if (provider.isLoading && provider.announcements.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  ),
                )
              else if (provider.announcements.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.announcement_outlined,
                          size: 64.r,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'Belum ada pengumuman',
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
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index >= provider.announcements.length) {
                          return provider.isLoadingMore
                              ? Container(
                                  padding: EdgeInsets.all(16.r),
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                      color: Colors.blue),
                                )
                              : const SizedBox.shrink();
                        }

                        final announcement = provider.announcements[index];
                        return _buildAnnouncementCard(announcement);
                      },
                      childCount: provider.announcements.length +
                          (provider.hasMoreAnnouncements ? 1 : 0),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
      String label, bool isSelected, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
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
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    final priority = announcement['priority'] as String;
    final priorityColor = Provider.of<InfoMediaProvider>(context, listen: false)
        .getPriorityColor(priority);
    final priorityLabel = Provider.of<InfoMediaProvider>(context, listen: false)
        .getPriorityLabel(priority);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
          onTap: () => _navigateToDetail(announcement),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with priority and date
                Row(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                        border:
                            Border.all(color: priorityColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        priorityLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      announcement['created_at'] ?? '',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Title
                Text(
                  announcement['title'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),

                // Content preview
                if (announcement['excerpt'] != null &&
                    announcement['excerpt'].isNotEmpty)
                  Text(
                    announcement['excerpt'],
                    style: GoogleFonts.poppins(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                SizedBox(height: 12.h),

                // Stats and interactions
                Row(
                  children: [
                    // Author
                    Icon(
                      Icons.person_outline,
                      size: 16.r,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      announcement['creator']?['name'] ?? 'Admin',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Read count
                    Icon(
                      Icons.visibility_outlined,
                      size: 16.r,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${announcement['stats']?['read_count'] ?? 0}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Like count
                    Icon(
                      Icons.favorite_outline,
                      size: 16.r,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${announcement['stats']?['like_count'] ?? 0}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(width: 16.w),

                    // Comment count
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 16.r,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${announcement['stats']?['comment_count'] ?? 0}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> announcement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnnouncementDetailScreen(
          announcementId: announcement['id'],
        ),
      ),
    );
  }
}
