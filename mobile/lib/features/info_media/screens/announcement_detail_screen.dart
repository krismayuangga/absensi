import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/info_media_provider.dart';

class AnnouncementDetailScreen extends StatefulWidget {
  final int announcementId;

  const AnnouncementDetailScreen({
    super.key,
    required this.announcementId,
  });

  @override
  State<AnnouncementDetailScreen> createState() =>
      _AnnouncementDetailScreenState();
}

class _AnnouncementDetailScreenState extends State<AnnouncementDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int? _replyToCommentId;
  String? _replyToUserName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InfoMediaProvider>(context, listen: false)
          .loadAnnouncementDetails(widget.announcementId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A9B8E), // Ganti dari Colors.blue
        elevation: 0,
        title: Text(
          'Detail Pengumuman',
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
      ),
      body: Consumer<InfoMediaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            );
          }

          final announcement = provider.currentAnnouncement;
          if (announcement == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.r,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Pengumuman tidak ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Announcement content
                      _buildAnnouncementContent(announcement, provider),

                      // Comments section
                      _buildCommentsSection(announcement),
                    ],
                  ),
                ),
              ),

              // Comment input
              _buildCommentInput(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementContent(
      Map<String, dynamic> announcement, InfoMediaProvider provider) {
    final priority = announcement['priority'] as String;
    final priorityColor = provider.getPriorityColor(priority);
    final priorityLabel = provider.getPriorityLabel(priority);

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: priorityColor.withOpacity(0.3)),
                ),
                child: Text(
                  priorityLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: priorityColor,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                announcement['created_at'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Title
          Text(
            announcement['title'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
              height: 1.3,
            ),
          ),
          SizedBox(height: 16.h),

          // Content
          Text(
            announcement['content'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
          SizedBox(height: 20.h),

          // Author and stats
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 18.r,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                announcement['creator']?['name'] ?? 'Admin',
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
              const Spacer(),
              _buildStatChip(
                Icons.visibility_outlined,
                '${announcement['stats']?['read_count'] ?? 0}',
                Colors.blue,
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: announcement['user_interactions']?['is_liked'] == true
                      ? Icons.favorite
                      : Icons.favorite_outline,
                  label: '${announcement['stats']?['like_count'] ?? 0} Suka',
                  color: announcement['user_interactions']?['is_liked'] == true
                      ? Colors.red
                      : Colors.grey.shade600,
                  onTap: () =>
                      provider.toggleAnnouncementLike(announcement['id']),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.chat_bubble_outline,
                  label:
                      '${announcement['stats']?['comment_count'] ?? 0} Komentar',
                  color: Colors.grey.shade600,
                  onTap: () => _scrollToComments(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(Map<String, dynamic> announcement) {
    final comments = announcement['comments'] as List<dynamic>? ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Komentar (${comments.length})',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 16.h),
          if (comments.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48.r,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Belum ada komentar',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder: (context, index) {
                final comment = comments[index] as Map<String, dynamic>;
                return _buildCommentItem(comment);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final replies = comment['replies'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main comment
        _buildSingleComment(comment, isReply: false),

        // Replies
        if (replies.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.only(left: 40.w),
            child: Column(
              children: replies.map((reply) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildSingleComment(reply as Map<String, dynamic>,
                      isReply: true),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSingleComment(Map<String, dynamic> comment,
      {required bool isReply}) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isReply ? Colors.grey.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info and timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Icon(
                  Icons.person,
                  size: 14.r,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                comment['user']?['name'] ?? 'User',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                comment['created_at'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Comment text
          Text(
            comment['comment'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          SizedBox(height: 8.h),

          // Actions
          Row(
            children: [
              GestureDetector(
                onTap: () => _toggleCommentLike(comment['id']),
                child: Row(
                  children: [
                    Icon(
                      comment['is_liked'] == true
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      size: 16.r,
                      color: comment['is_liked'] == true
                          ? Colors.red
                          : Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${comment['like_count'] ?? 0}',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isReply) ...[
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () => _startReply(
                      comment['id'], comment['user']?['name'] ?? 'User'),
                  child: Text(
                    'Balas',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(InfoMediaProvider provider) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyToCommentId != null) ...[
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16.r, color: Colors.blue),
                  SizedBox(width: 8.w),
                  Text(
                    'Membalas $_replyToUserName',
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.blue,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _cancelReply,
                    child: Icon(Icons.close, size: 16.r, color: Colors.blue),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: _replyToCommentId != null
                        ? 'Tulis balasan...'
                        : 'Tulis komentar...',
                    hintStyle: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submitComment(provider),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _submitComment(provider),
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20.r,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.r, color: color),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _scrollToComments() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _toggleCommentLike(int commentId) {
    Provider.of<InfoMediaProvider>(context, listen: false)
        .toggleCommentLike(commentId);
  }

  void _startReply(int commentId, String userName) {
    setState(() {
      _replyToCommentId = commentId;
      _replyToUserName = userName;
    });
    _commentController.text = '@$userName ';
  }

  void _cancelReply() {
    setState(() {
      _replyToCommentId = null;
      _replyToUserName = null;
    });
    _commentController.clear();
  }

  void _submitComment(InfoMediaProvider provider) {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    provider
        .addComment(
      widget.announcementId,
      comment,
      parentId: _replyToCommentId,
    )
        .then((success) {
      if (success) {
        _commentController.clear();
        _cancelReply();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Komentar berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(provider.errorMessage ?? 'Gagal menambahkan komentar'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }
}
