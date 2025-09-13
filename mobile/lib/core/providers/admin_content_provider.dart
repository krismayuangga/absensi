import 'package:flutter/material.dart';
import 'dart:io';
import '../services/admin_content_service.dart';

class AdminContentProvider with ChangeNotifier {
  final AdminContentService _adminContentService = AdminContentService();

  // Loading states
  bool _isLoading = false;
  bool _isLoadingAnnouncements = false;
  bool _isLoadingMedia = false;

  // Data
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _media = [];
  Map<String, dynamic>? _contentStats;

  // Pagination
  Map<String, dynamic>? _announcementPagination;
  Map<String, dynamic>? _mediaPagination;

  // Filters
  String? _selectedCategory;
  String? _selectedPriority;
  String? _selectedMediaType;
  String? _searchQuery;

  // Error handling
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoadingAnnouncements => _isLoadingAnnouncements;
  bool get isLoadingMedia => _isLoadingMedia;

  List<Map<String, dynamic>> get announcements => _announcements;
  List<Map<String, dynamic>> get media => _media;
  Map<String, dynamic>? get contentStats => _contentStats;

  Map<String, dynamic>? get announcementPagination => _announcementPagination;
  Map<String, dynamic>? get mediaPagination => _mediaPagination;

  String? get selectedCategory => _selectedCategory;
  String? get selectedPriority => _selectedPriority;
  String? get selectedMediaType => _selectedMediaType;
  String? get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;

  // ANNOUNCEMENTS MANAGEMENT

  /// Load announcements for admin management
  Future<void> loadAnnouncements({
    int page = 1,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _announcements.clear();
        _announcementPagination = null;
      }

      _isLoadingAnnouncements = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.getAnnouncements(
        page: page,
        category: _selectedCategory,
        priority: _selectedPriority,
        search: _searchQuery,
      );

      if (response['success']) {
        if (page == 1 || refresh) {
          _announcements = List<Map<String, dynamic>>.from(response['data']);
        } else {
          _announcements
              .addAll(List<Map<String, dynamic>>.from(response['data']));
        }
        _announcementPagination = response['pagination'];
      } else {
        _errorMessage = response['message'];
      }
    } catch (e) {
      _errorMessage = 'Error loading announcements: $e';
      print('❌ Error in loadAnnouncements: $e');
    } finally {
      _isLoadingAnnouncements = false;
      notifyListeners();
    }
  }

  /// Create new announcement
  Future<bool> createAnnouncement({
    required String title,
    required String content,
    required String priority,
    required String category,
    String targetType = 'all',
    bool sendNotification = false,
    bool publishNow = true,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.createAnnouncement(
        title: title,
        content: content,
        priority: priority,
        category: category,
        targetType: targetType,
        sendNotification: sendNotification,
        publishNow: publishNow,
      );

      if (response['success']) {
        // Refresh announcements list
        await loadAnnouncements(refresh: true);
        // Also refresh content stats
        await loadContentStats();
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error creating announcement: $e';
      print('❌ Error in createAnnouncement: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update announcement
  Future<bool> updateAnnouncement({
    required int id,
    required String title,
    required String content,
    required String priority,
    required String category,
    String targetType = 'all',
    bool sendNotification = false,
    bool publishNow = true,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.updateAnnouncement(
        id: id,
        title: title,
        content: content,
        priority: priority,
        category: category,
        targetType: targetType,
        sendNotification: sendNotification,
        publishNow: publishNow,
      );

      if (response['success']) {
        // Refresh announcements list
        await loadAnnouncements(refresh: true);
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating announcement: $e';
      print('❌ Error in updateAnnouncement: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete announcement
  Future<bool> deleteAnnouncement(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.deleteAnnouncement(id);

      if (response['success']) {
        // Remove from local list
        _announcements.removeWhere((announcement) => announcement['id'] == id);
        // Refresh content stats
        await loadContentStats();
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting announcement: $e';
      print('❌ Error in deleteAnnouncement: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // MEDIA MANAGEMENT

  /// Load media for admin management
  Future<void> loadMedia({
    int page = 1,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        _media.clear();
        _mediaPagination = null;
      }

      _isLoadingMedia = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.getMedia(
        page: page,
        type: _selectedMediaType,
        category: _selectedCategory,
        search: _searchQuery,
      );

      if (response['success']) {
        if (page == 1 || refresh) {
          _media = List<Map<String, dynamic>>.from(response['data']);
        } else {
          _media.addAll(List<Map<String, dynamic>>.from(response['data']));
        }
        _mediaPagination = response['pagination'];
      } else {
        _errorMessage = response['message'];
      }
    } catch (e) {
      _errorMessage = 'Error loading media: $e';
      print('❌ Error in loadMedia: $e');
    } finally {
      _isLoadingMedia = false;
      notifyListeners();
    }
  }

  /// Upload new media from file path
  Future<bool> uploadMedia({
    required String filePath,
    required String title,
    String? description,
    required String category,
    String? mediaType,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.uploadMedia(
        filePath: filePath,
        title: title,
        description: description,
        category: category,
        mediaType: mediaType,
      );

      if (response['success']) {
        // Refresh media list
        await loadMedia(refresh: true);
        // Also refresh content stats
        await loadContentStats();
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error uploading media: $e';
      print('❌ Error in uploadMedia: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Upload new media from File object
  Future<bool> uploadMediaFromFile({
    required File file,
    required String title,
    String? description,
    required String mediaType,
    required String category,
  }) async {
    return uploadMedia(
      filePath: file.path,
      title: title,
      description: description,
      category: category,
      mediaType: mediaType,
    );
  }

  /// Delete media
  Future<bool> deleteMedia(int id) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _adminContentService.deleteMedia(id);

      if (response['success']) {
        // Remove from local list
        _media.removeWhere((media) => media['id'] == id);
        // Refresh content stats
        await loadContentStats();
        return true;
      } else {
        _errorMessage = response['message'];
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting media: $e';
      print('❌ Error in deleteMedia: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // CONTENT STATISTICS

  /// Load content statistics
  Future<void> loadContentStats() async {
    try {
      final response = await _adminContentService.getContentStats();

      if (response['success']) {
        _contentStats = response['data'];
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error in loadContentStats: $e');
    }
  }

  // FILTERS AND SEARCH

  /// Set category filter
  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
    // Reload data with new filter
    loadAnnouncements(refresh: true);
    loadMedia(refresh: true);
  }

  /// Set priority filter
  void setSelectedPriority(String? priority) {
    _selectedPriority = priority;
    notifyListeners();
    // Reload announcements with new filter
    loadAnnouncements(refresh: true);
  }

  /// Set media type filter
  void setSelectedMediaType(String? mediaType) {
    _selectedMediaType = mediaType;
    notifyListeners();
    // Reload media with new filter
    loadMedia(refresh: true);
  }

  /// Set search query
  void setSearchQuery(String? query) {
    _searchQuery = query;
    notifyListeners();
    // Reload data with new search
    loadAnnouncements(refresh: true);
    loadMedia(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    _selectedCategory = null;
    _selectedPriority = null;
    _selectedMediaType = null;
    _searchQuery = null;
    notifyListeners();
    // Reload data without filters
    loadAnnouncements(refresh: true);
    loadMedia(refresh: true);
  }

  // UTILITY METHODS

  /// Clear error message
  void clearError() {
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
        return Colors.green;
      default:
        return Colors.grey;
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
        return 'Tidak Diketahui';
    }
  }

  /// Get file type icon
  IconData getFileTypeIcon(String fileType) {
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

  /// Get file type label
  String getFileTypeLabel(String fileType) {
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
}
