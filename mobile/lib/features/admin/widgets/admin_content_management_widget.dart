import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/providers/admin_content_provider.dart';
import '../../../core/theme/app_theme.dart';

class AdminContentManagementWidget extends StatefulWidget {
  const AdminContentManagementWidget({Key? key}) : super(key: key);

  @override
  State<AdminContentManagementWidget> createState() =>
      _AdminContentManagementWidgetState();
}

class _AdminContentManagementWidgetState
    extends State<AdminContentManagementWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load content data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider =
          Provider.of<AdminContentProvider>(context, listen: false);
      provider.loadAnnouncements();
      provider.loadMedia();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppTheme.primaryColor,
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'Kelola Pengumuman', icon: Icon(Icons.campaign)),
              Tab(text: 'Kelola Media', icon: Icon(Icons.photo_library)),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              AnnouncementManagementTab(),
              MediaManagementTab(),
            ],
          ),
        ),
      ],
    );
  }
}

// Tab untuk mengelola pengumuman
class AnnouncementManagementTab extends StatefulWidget {
  const AnnouncementManagementTab({Key? key}) : super(key: key);

  @override
  State<AnnouncementManagementTab> createState() =>
      _AnnouncementManagementTabState();
}

class _AnnouncementManagementTabState extends State<AnnouncementManagementTab> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedCategory = 'general';
  String _selectedPriority = 'medium';

  final List<String> _categories = ['general', 'urgent', 'info', 'event'];
  final List<String> _priorities = ['low', 'medium', 'high', 'urgent'];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminContentProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form untuk membuat pengumuman baru
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Buat Pengumuman Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Pengumuman',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _contentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Isi Pengumuman',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedCategory,
                              decoration: const InputDecoration(
                                labelText: 'Kategori',
                                border: OutlineInputBorder(),
                              ),
                              items: _categories.map((category) {
                                return DropdownMenuItem(
                                  value: category,
                                  child: Text(category.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategory = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedPriority,
                              decoration: const InputDecoration(
                                labelText: 'Prioritas',
                                border: OutlineInputBorder(),
                              ),
                              items: _priorities.map((priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Text(priority.toUpperCase()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPriority = value!;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              provider.isLoading ? null : _createAnnouncement,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Publikasikan Pengumuman',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Daftar pengumuman yang sudah ada
              const Text(
                'Pengumuman Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: provider.announcements.isEmpty
                    ? const Center(
                        child: Text('Belum ada pengumuman'),
                      )
                    : ListView.builder(
                        itemCount: provider.announcements.length,
                        itemBuilder: (context, index) {
                          final announcement = provider.announcements[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                announcement['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(announcement['content'] ?? ''),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(
                                          announcement['category']
                                                  ?.toString()
                                                  .toUpperCase() ??
                                              '',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: AppTheme.primaryColor
                                            .withOpacity(0.1),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(
                                          announcement['priority']
                                                  ?.toString()
                                                  .toUpperCase() ??
                                              '',
                                          style: const TextStyle(fontSize: 10),
                                        ),
                                        backgroundColor: _getPriorityColor(
                                            announcement['priority']),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    _deleteAnnouncement(announcement['id']),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'urgent':
        return Colors.red.withOpacity(0.2);
      case 'high':
        return Colors.orange.withOpacity(0.2);
      case 'medium':
        return Colors.blue.withOpacity(0.2);
      case 'low':
        return Colors.green.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  void _createAnnouncement() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    final provider = Provider.of<AdminContentProvider>(context, listen: false);

    try {
      await provider.createAnnouncement(
        title: _titleController.text,
        content: _contentController.text,
        category: _selectedCategory,
        priority: _selectedPriority,
      );

      // Clear form
      _titleController.clear();
      _contentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil dipublikasikan!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deleteAnnouncement(int? id) async {
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman'),
        content:
            const Text('Apakah Anda yakin ingin menghapus pengumuman ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider =
          Provider.of<AdminContentProvider>(context, listen: false);
      try {
        await provider.deleteAnnouncement(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengumuman berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// Tab untuk mengelola media/galeri
class MediaManagementTab extends StatefulWidget {
  const MediaManagementTab({Key? key}) : super(key: key);

  @override
  State<MediaManagementTab> createState() => _MediaManagementTabState();
}

class _MediaManagementTabState extends State<MediaManagementTab> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminContentProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form untuk upload media baru
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Upload Media Baru',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Image selection
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Tap untuk pilih gambar',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Judul Media',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi (Opsional)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: provider.isLoading ? null : _uploadMedia,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: provider.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text(
                                  'Upload Media',
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Galeri media yang sudah ada
              const Text(
                'Galeri Media',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: provider.media.isEmpty
                    ? const Center(
                        child: Text('Belum ada media'),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: provider.media.length,
                        itemBuilder: (context, index) {
                          final media = provider.media[index];
                          return Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(4),
                                      ),
                                      image: media['file_path'] != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  media['file_path']),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: media['file_path'] == null
                                        ? const Icon(Icons.image,
                                            size: 48, color: Colors.grey)
                                        : null,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        media['title'] ?? 'Untitled',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 16),
                                            onPressed: () =>
                                                _deleteMedia(media['id']),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  void _uploadMedia() async {
    if (_selectedImage == null || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap pilih gambar dan isi judul')),
      );
      return;
    }

    final provider = Provider.of<AdminContentProvider>(context, listen: false);

    try {
      await provider.uploadMedia(
        filePath: _selectedImage!.path,
        title: _titleController.text,
        description: _descriptionController.text,
        category: 'general',
      );

      // Clear form
      setState(() {
        _selectedImage = null;
      });
      _titleController.clear();
      _descriptionController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Media berhasil diupload!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _deleteMedia(int? id) async {
    if (id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Media'),
        content: const Text('Apakah Anda yakin ingin menghapus media ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final provider =
          Provider.of<AdminContentProvider>(context, listen: false);
      try {
        await provider.deleteMedia(id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media berhasil dihapus')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
