<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\MediaGallery;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class AdminContentController extends Controller
{
    /**
     * Get all announcements for admin management
     */
    public function getAnnouncements(Request $request): JsonResponse
    {
        try {
            $query = Announcement::with(['creator:id,name'])
                ->orderBy('created_at', 'desc');

            // Filter by category if provided
            if ($request->filled('category')) {
                $query->where('category', $request->category);
            }

            // Filter by priority if provided
            if ($request->filled('priority')) {
                $query->where('priority', $request->priority);
            }

            // Search by title if provided
            if ($request->filled('search')) {
                $query->where('title', 'like', '%' . $request->search . '%');
            }

            $announcements = $query->paginate($request->get('per_page', 10));

            $data = $announcements->getCollection()->map(function ($announcement) {
                return [
                    'id' => $announcement->id,
                    'title' => $announcement->title,
                    'content' => $announcement->content,
                    'excerpt' => $announcement->excerpt,
                    'priority' => $announcement->priority,
                    'priority_label' => $announcement->priority_label,
                    'priority_color' => $announcement->priority_color,
                    'category' => $announcement->category,
                    'status' => $announcement->status,
                    'is_published' => $announcement->is_published,
                    'target_type' => $announcement->target_type,
                    'send_notification' => $announcement->send_notification,
                    'created_at' => $announcement->created_at->format('d M Y, H:i'),
                    'updated_at' => $announcement->updated_at->format('d M Y, H:i'),
                    'creator' => [
                        'id' => $announcement->creator->id ?? null,
                        'name' => $announcement->creator->name ?? 'Unknown',
                    ],
                    'stats' => [
                        'read_count' => $announcement->read_count,
                        'like_count' => $announcement->like_count,
                        'comment_count' => $announcement->comment_count,
                    ],
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $data,
                'pagination' => [
                    'current_page' => $announcements->currentPage(),
                    'last_page' => $announcements->lastPage(),
                    'per_page' => $announcements->perPage(),
                    'total' => $announcements->total(),
                ],
            ]);

        } catch (\Exception $e) {
            \Log::error('Get announcements error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengambil data pengumuman: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create new announcement
     */
    public function createAnnouncement(Request $request): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:255',
                'content' => 'required|string',
                'priority' => 'required|in:urgent,high,medium,low',
                'category' => 'required|string|max:100',
                'target_type' => 'in:all,department,position,specific',
                'send_notification' => 'boolean',
                'publish_now' => 'boolean',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $user = Auth::user();

            // Generate excerpt from content
            $excerpt = Str::limit(strip_tags($request->content), 150);

            $announcement = Announcement::create([
                'title' => $request->title,
                'content' => $request->content,
                'excerpt' => $excerpt,
                'priority' => $request->priority,
                'category' => $request->category,
                'target_type' => $request->get('target_type', 'all'),
                'send_notification' => $request->get('send_notification', false),
                'status' => $request->get('publish_now', true) ? 'published' : 'draft',
                'is_published' => $request->get('publish_now', true),
                'published_at' => $request->get('publish_now', true) ? now() : null,
                'created_by' => $user->id,
            ]);

            // TODO: Send notification if requested
            if ($announcement->send_notification && $announcement->is_published) {
                // Implement notification sending logic here
                \Log::info('Should send notification for announcement: ' . $announcement->id);
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $announcement->id,
                    'title' => $announcement->title,
                    'content' => $announcement->content,
                    'priority' => $announcement->priority,
                    'category' => $announcement->category,
                    'status' => $announcement->status,
                    'created_at' => $announcement->created_at->format('d M Y, H:i'),
                ],
                'message' => 'Pengumuman berhasil dibuat',
            ], 201);

        } catch (\Exception $e) {
            \Log::error('Create announcement error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal membuat pengumuman: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update announcement
     */
    public function updateAnnouncement(Request $request, Announcement $announcement): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'title' => 'required|string|max:255',
                'content' => 'required|string',
                'priority' => 'required|in:urgent,high,medium,low',
                'category' => 'required|string|max:100',
                'target_type' => 'in:all,department,position,specific',
                'send_notification' => 'boolean',
                'publish_now' => 'boolean',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            // Generate excerpt from content
            $excerpt = Str::limit(strip_tags($request->content), 150);

            $announcement->update([
                'title' => $request->title,
                'content' => $request->content,
                'excerpt' => $excerpt,
                'priority' => $request->priority,
                'category' => $request->category,
                'target_type' => $request->get('target_type', 'all'),
                'send_notification' => $request->get('send_notification', false),
                'status' => $request->get('publish_now', true) ? 'published' : 'draft',
                'is_published' => $request->get('publish_now', true),
                'published_at' => $request->get('publish_now', true) && !$announcement->published_at 
                    ? now() : $announcement->published_at,
            ]);

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $announcement->id,
                    'title' => $announcement->title,
                    'content' => $announcement->content,
                    'priority' => $announcement->priority,
                    'category' => $announcement->category,
                    'status' => $announcement->status,
                    'updated_at' => $announcement->updated_at->format('d M Y, H:i'),
                ],
                'message' => 'Pengumuman berhasil diupdate',
            ]);

        } catch (\Exception $e) {
            \Log::error('Update announcement error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengupdate pengumuman: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete announcement
     */
    public function deleteAnnouncement(Announcement $announcement): JsonResponse
    {
        try {
            $announcement->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Pengumuman berhasil dihapus',
            ]);

        } catch (\Exception $e) {
            \Log::error('Delete announcement error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghapus pengumuman: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all media for admin management
     */
    public function getMedia(Request $request): JsonResponse
    {
        try {
            $query = MediaGallery::with(['uploader:id,name'])
                ->orderBy('created_at', 'desc');

            // Filter by type if provided
            if ($request->filled('type')) {
                $query->where('file_type', $request->type);
            }

            // Filter by category if provided
            if ($request->filled('category')) {
                $query->where('category', $request->category);
            }

            // Search by title if provided
            if ($request->filled('search')) {
                $query->where('title', 'like', '%' . $request->search . '%');
            }

            $media = $query->paginate($request->get('per_page', 20));

            $data = $media->getCollection()->map(function ($item) {
                return [
                    'id' => $item->id,
                    'title' => $item->title,
                    'description' => $item->description,
                    'file_name' => $item->file_name,
                    'file_type' => $item->file_type,
                    'file_size' => $item->file_size,
                    'formatted_size' => $this->formatFileSize($item->file_size),
                    'file_url' => $item->file_url,
                    'category' => $item->category,
                    'status' => $item->status,
                    'created_at' => $item->created_at->format('d M Y, H:i'),
                    'uploader' => [
                        'id' => $item->uploader->id ?? null,
                        'name' => $item->uploader->name ?? 'Unknown',
                    ],
                ];
            });

            return response()->json([
                'status' => 'success',
                'data' => $data,
                'pagination' => [
                    'current_page' => $media->currentPage(),
                    'last_page' => $media->lastPage(),
                    'per_page' => $media->perPage(),
                    'total' => $media->total(),
                ],
            ]);

        } catch (\Exception $e) {
            \Log::error('Get media error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengambil data media: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Upload new media
     */
    public function uploadMedia(Request $request): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'file' => 'required|file|max:5120', // 5MB max
                'title' => 'required|string|max:255',
                'description' => 'nullable|string',
                'category' => 'required|string|max:100',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $file = $request->file('file');
            $user = Auth::user();

            // Generate unique filename
            $fileName = time() . '_' . Str::random(10) . '.' . $file->getClientOriginalExtension();
            
            // Determine file type
            $mimeType = $file->getMimeType();
            $fileType = $this->determineFileType($mimeType);

            // Store file
            $filePath = $file->storeAs('media', $fileName, 'public');
            $fileUrl = Storage::url($filePath);

            $media = MediaGallery::create([
                'title' => $request->title,
                'description' => $request->description,
                'file_name' => $fileName,
                'original_name' => $file->getClientOriginalName(),
                'file_path' => $filePath,
                'file_url' => $fileUrl,
                'file_type' => $fileType,
                'file_size' => $file->getSize(),
                'mime_type' => $mimeType,
                'category' => $request->category,
                'status' => 'active',
                'uploaded_by' => $user->id,
            ]);

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $media->id,
                    'title' => $media->title,
                    'file_name' => $media->file_name,
                    'file_type' => $media->file_type,
                    'file_url' => $media->file_url,
                    'formatted_size' => $this->formatFileSize($media->file_size),
                    'created_at' => $media->created_at->format('d M Y, H:i'),
                ],
                'message' => 'Media berhasil diupload',
            ], 201);

        } catch (\Exception $e) {
            \Log::error('Upload media error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengupload media: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete media
     */
    public function deleteMedia(MediaGallery $media): JsonResponse
    {
        try {
            // Delete file from storage
            if (Storage::disk('public')->exists($media->file_path)) {
                Storage::disk('public')->delete($media->file_path);
            }

            $media->delete();

            return response()->json([
                'status' => 'success',
                'message' => 'Media berhasil dihapus',
            ]);

        } catch (\Exception $e) {
            \Log::error('Delete media error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menghapus media: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get content statistics
     */
    public function getContentStats(): JsonResponse
    {
        try {
            $stats = [
                'announcements' => [
                    'total' => Announcement::count(),
                    'published' => Announcement::where('status', 'published')->count(),
                    'draft' => Announcement::where('status', 'draft')->count(),
                    'this_month' => Announcement::whereMonth('created_at', now()->month)->count(),
                ],
                'media' => [
                    'total' => MediaGallery::count(),
                    'images' => MediaGallery::where('file_type', 'image')->count(),
                    'documents' => MediaGallery::where('file_type', 'document')->count(),
                    'videos' => MediaGallery::where('file_type', 'video')->count(),
                    'total_size' => MediaGallery::sum('file_size'),
                    'formatted_total_size' => $this->formatFileSize(MediaGallery::sum('file_size')),
                ],
            ];

            return response()->json([
                'status' => 'success',
                'data' => $stats,
            ]);

        } catch (\Exception $e) {
            \Log::error('Get content stats error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengambil statistik konten: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Determine file type based on MIME type
     */
    private function determineFileType(string $mimeType): string
    {
        if (str_starts_with($mimeType, 'image/')) {
            return 'image';
        } elseif (str_starts_with($mimeType, 'video/')) {
            return 'video';
        } elseif (in_array($mimeType, [
            'application/pdf',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            'application/vnd.ms-excel',
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            'text/plain',
        ])) {
            return 'document';
        }

        return 'other';
    }

    /**
     * Format file size to human readable format
     */
    private function formatFileSize(int $bytes): string
    {
        if ($bytes >= 1073741824) {
            return number_format($bytes / 1073741824, 2) . ' GB';
        } elseif ($bytes >= 1048576) {
            return number_format($bytes / 1048576, 2) . ' MB';
        } elseif ($bytes >= 1024) {
            return number_format($bytes / 1024, 2) . ' KB';
        }

        return $bytes . ' bytes';
    }
}
