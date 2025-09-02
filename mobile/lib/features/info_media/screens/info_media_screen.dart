import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/info_media_provider.dart';
import 'announcement_list_screen.dart';
import 'media_gallery_screen.dart';

class InfoMediaScreen extends StatefulWidget {
  const InfoMediaScreen({super.key});

  @override
  State<InfoMediaScreen> createState() => _InfoMediaScreenState();
}

class _InfoMediaScreenState extends State<InfoMediaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<InfoMediaProvider>(context, listen: false);
      provider.loadAnnouncements(refresh: true);
      provider.loadAnnouncementCategories();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Info & Media',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(
              icon: Icon(Icons.announcement, size: 20.r),
              text: 'Pengumuman',
            ),
            Tab(
              icon: Icon(Icons.photo_library, size: 20.r),
              text: 'Galeri',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Important announcement banner
          Consumer<InfoMediaProvider>(
            builder: (context, provider, child) {
              final urgentAnnouncements = provider.announcements
                  .where((a) => a['priority'] == 'urgent')
                  .toList();

              if (urgentAnnouncements.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: EdgeInsets.all(16.r),
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.campaign,
                        color: Colors.white,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengumuman Penting!',
                            style: GoogleFonts.poppins(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Ada ${urgentAnnouncements.length} pengumuman mendesak',
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ],
                ),
              );
            },
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                AnnouncementListScreen(),
                MediaGalleryScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
