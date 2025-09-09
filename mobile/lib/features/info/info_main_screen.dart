import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/providers/info_media_provider.dart';
import '../info_media/screens/announcement_list_screen.dart';
import '../info_media/screens/media_gallery_screen.dart';

class InfoMainScreen extends StatefulWidget {
  const InfoMainScreen({super.key});

  @override
  State<InfoMainScreen> createState() => _InfoMainScreenState();
}

class _InfoMainScreenState extends State<InfoMainScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load initial data using InfoMediaProvider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🎯 INFO MAIN: Initializing InfoMediaProvider...');
      final provider = Provider.of<InfoMediaProvider>(context, listen: false);
      provider.loadAnnouncements(refresh: true);
      provider.loadMediaGallery(refresh: true);
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        title: Text(
          'Info & Media',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.inter(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(
              icon: Icon(Icons.announcement),
              text: 'Pengumuman',
            ),
            Tab(
              icon: Icon(Icons.photo_library),
              text: 'Galeri',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const AnnouncementListScreen(),
          const MediaGalleryScreen(),
        ],
      ),
    );
  }
}
