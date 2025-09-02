import 'package:flutter/material.dart';
import '../services/info_media_service.dart';

class InfoMediaProvider extends ChangeNotifier {
  final InfoMediaService _service = InfoMediaService();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Announcements data
  List<Map<String, dynamic>> _announcements = [];
  Map<String, dynamic>? _currentAnnouncement;
  List<Map<String, dynamic>> _categories = [];
  int _currentPage = 1;
  bool _hasMoreAnnouncements = true;

  // Media gallery data
  List<Map<String, dynamic>> _mediaItems = [];
  Map<String, dynamic>? _currentMedia;
  List<Map<String, dynamic>> _mediaCategories = [];
  int _currentMediaPage = 1;
  bool _hasMoreMedia = true;
  String _selectedMediaType = 'all'; // all, image, document

  // Filters
  String? _selectedCategory;
  String? _selectedPriority;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  List<Map<String, dynamic>> get announcements => _announcements;
  Map<String, dynamic>? get currentAnnouncement => _currentAnnouncement;
  List<Map<String, dynamic>> get categories => _categories;
  bool get hasMoreAnnouncements => _hasMoreAnnouncements;

  List<Map<String, dynamic>> get mediaItems => _mediaItems;
  Map<String, dynamic>? get currentMedia => _currentMedia;
  List<Map<String, dynamic>> get mediaCategories => _mediaCategories;
  bool get hasMoreMedia => _hasMoreMedia;
  String get selectedMediaType => _selectedMediaType;

  String? get selectedCategory => _selectedCategory;
  String? get selectedPriority => _selectedPriority;

  // ANNOUNCEMENTS METHODS

  /// Load announcements (first page)
  Future<void> loadAnnouncements({bool refresh = false}) async {
    print('🚀 INFO MEDIA: Starting loadAnnouncements (refresh: $refresh)');

    if (refresh) {
      _currentPage = 1;
      _hasMoreAnnouncements = true;
      _announcements.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      print('🔄 INFO MEDIA: Calling service.getAnnouncements...');
      final result = await _service.getAnnouncements(
        page: _currentPage,
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      print('📊 INFO MEDIA: Service response: $result');

      if (result['success'] == true) {
        final newAnnouncements =
            (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        if (refresh || _currentPage == 1) {
          _announcements = newAnnouncements;
        } else {
          _announcements.addAll(newAnnouncements);
        }

        // Update pagination info
        final pagination = result['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _hasMoreAnnouncements =
              pagination['current_page'] < pagination['last_page'];
        }

        print(
            '✅ SUCCESS: Loaded ${newAnnouncements.length} announcements (page $_currentPage)');
      } else {
        _errorMessage =
            result['message'] as String? ?? 'Gagal memuat pengumuman';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat pengumuman: $e';
      print('❌ Error loading announcements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more announcements (pagination)
  Future<void> loadMoreAnnouncements() async {
    if (_isLoadingMore || !_hasMoreAnnouncements) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;

    try {
      final result = await _service.getAnnouncements(
        page: _currentPage,
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      if (result['success'] == true) {
        final newAnnouncements =
            (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _announcements.addAll(newAnnouncements);

        final pagination = result['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _hasMoreAnnouncements =
              pagination['current_page'] < pagination['last_page'];
        }

        print(
            '✅ SUCCESS: Loaded ${newAnnouncements.length} more announcements (page $_currentPage)');
      }
    } catch (e) {
      _currentPage--; // Rollback page increment on error
      print('❌ Error loading more announcements: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Get announcement details
  Future<bool> loadAnnouncementDetails(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getAnnouncementDetails(id);

      if (result['success'] == true) {
        _currentAnnouncement = result['data'] as Map<String, dynamic>?;
        print('✅ SUCCESS: Loaded announcement details for ID: $id');
        return true;
      } else {
        _errorMessage =
            result['message'] as String? ?? 'Pengumuman tidak ditemukan';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat detail pengumuman: $e';
      print('❌ Error loading announcement details: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Toggle like on announcement
  Future<bool> toggleAnnouncementLike(int id) async {
    try {
      final result = await _service.toggleAnnouncementLike(id);

      if (result['success'] == true) {
        final data = result['data'] as Map<String, dynamic>;
        final isLiked = data['is_liked'] as bool;
        final likeCount = data['like_count'] as int;

        // Update announcement in list
        final index = _announcements.indexWhere((a) => a['id'] == id);
        if (index != -1) {
          _announcements[index]['user_interactions']['is_liked'] = isLiked;
          _announcements[index]['stats']['like_count'] = likeCount;
        }

        // Update current announcement if viewing details
        if (_currentAnnouncement?['id'] == id) {
          _currentAnnouncement!['user_interactions']['is_liked'] = isLiked;
          _currentAnnouncement!['stats']['like_count'] = likeCount;
        }

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error toggling like: $e');
      return false;
    }
  }

  /// Add comment to announcement
  Future<bool> addAnnouncementComment(int id, String comment,
      {int? parentId}) async {
    try {
      final result = await _service.addAnnouncementComment(id, comment,
          parentId: parentId);

      if (result['success'] == true) {
        // Refresh announcement details to get updated comments
        await loadAnnouncementDetails(id);
        return true;
      } else {
        _errorMessage =
            result['message'] as String? ?? 'Gagal menambahkan komentar';
        notifyListeners();
        return false;
      }
    } catch (e) {
      print('❌ Error adding comment: $e');
      _errorMessage = 'Gagal menambahkan komentar: $e';
      notifyListeners();
      return false;
    }
  }

  /// Toggle like on comment
  Future<bool> toggleCommentLike(int commentId) async {
    try {
      final result = await _service.toggleCommentLike(commentId);

      if (result['success'] == true) {
        // Refresh current announcement to update comment likes
        if (_currentAnnouncement != null) {
          await loadAnnouncementDetails(_currentAnnouncement!['id']);
        }
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error toggling comment like: $e');
      return false;
    }
  }

  /// Load announcement categories
  Future<void> loadAnnouncementCategories() async {
    try {
      final result = await _service.getAnnouncementCategories();

      if (result['success'] == true) {
        _categories =
            (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      }
    } catch (e) {
      print('❌ Error loading categories: $e');
    }
  }

  /// Set category filter
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    loadAnnouncements(refresh: true);
  }

  /// Set priority filter
  void setSelectedPriority(String? priority) {
    _selectedPriority = priority;
    loadAnnouncements(refresh: true);
  }

  // MEDIA GALLERY METHODS

  /// Load media gallery (first page)
  Future<void> loadMediaGallery({bool refresh = false}) async {
    if (refresh) {
      _currentMediaPage = 1;
      _hasMoreMedia = true;
      _mediaItems.clear();
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getMediaGallery(
        page: _currentMediaPage,
        type: _selectedMediaType == 'all' ? null : _selectedMediaType,
      );

      if (result['success'] == true) {
        final newMediaItems =
            (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        if (refresh || _currentMediaPage == 1) {
          _mediaItems = newMediaItems;
        } else {
          _mediaItems.addAll(newMediaItems);
        }

        final pagination = result['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _hasMoreMedia = pagination['current_page'] < pagination['last_page'];
        }

        print(
            '✅ SUCCESS: Loaded ${newMediaItems.length} media items (page $_currentMediaPage)');
      } else {
        _errorMessage =
            result['message'] as String? ?? 'Gagal memuat galeri media';
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat galeri media: $e';
      print('❌ Error loading media gallery: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more media items
  Future<void> loadMoreMedia() async {
    if (_isLoadingMore || !_hasMoreMedia) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentMediaPage++;

    try {
      final result = await _service.getMediaGallery(
        page: _currentMediaPage,
        type: _selectedMediaType == 'all' ? null : _selectedMediaType,
      );

      if (result['success'] == true) {
        final newMediaItems =
            (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        _mediaItems.addAll(newMediaItems);

        final pagination = result['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          _hasMoreMedia = pagination['current_page'] < pagination['last_page'];
        }
      }
    } catch (e) {
      _currentMediaPage--; // Rollback on error
      print('❌ Error loading more media: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Set media type filter
  void setSelectedMediaType(String type) {
    _selectedMediaType = type;
    loadMediaGallery(refresh: true);
  }

  /// Load media details
  Future<bool> loadMediaDetails(int id) async {
    try {
      final result = await _service.getMediaDetails(id);

      if (result['success'] == true) {
        _currentMedia = result['data'] as Map<String, dynamic>?;
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error loading media details: $e');
      return false;
    }
  }

  /// Download media
  Future<bool> downloadMedia(int id) async {
    try {
      final result = await _service.downloadMedia(id);
      return result['success'] == true;
    } catch (e) {
      print('❌ Error downloading media: $e');
      return false;
    }
  }

  // UTILITY METHODS

  /// Clear all data
  void clearData() {
    _announcements.clear();
    _mediaItems.clear();
    _currentAnnouncement = null;
    _currentMedia = null;
    _categories.clear();
    _mediaCategories.clear();
    _selectedCategory = null;
    _selectedPriority = null;
    _selectedMediaType = 'all';
    _currentPage = 1;
    _currentMediaPage = 1;
    _hasMoreAnnouncements = true;
    _hasMoreMedia = true;
    _errorMessage = null;
    notifyListeners();
  }

  /// Get priority color
  Color getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  /// Get priority label
  String getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return 'Mendesak';
      case 'high':
        return 'Tinggi';
      case 'medium':
        return 'Sedang';
      case 'low':
        return 'Rendah';
      default:
        return 'Sedang';
    }
  }
}
