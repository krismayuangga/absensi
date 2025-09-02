<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MediaGallery;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MediaController extends Controller
{
    /**
     * Get media gallery items.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user(); // Can be null for public access
        
        $query = MediaGallery::where('is_public', true)
            ->with(['uploader:id,name'])
            ->orderBy('created_at', 'desc');

        // Filter by category if provided
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Filter by file type if provided
        if ($request->filled('type')) {
            $query->where('file_type', $request->type);
        }

        $media = $query->paginate($request->get('per_page', 12));

        $data = $media->getCollection()->map(function ($item) {
            return [
                'id' => $item->id,
                'title' => $item->title,
                'description' => $item->description,
                'file_type' => $item->file_type,
                'file_url' => asset('storage/' . $item->file_path),
                'mime_type' => $item->mime_type,
                'formatted_size' => $this->formatFileSize($item->file_size),
                'category' => $item->category,
                'tags' => $item->tags,
                'is_featured' => $item->is_featured,
                'download_count' => $item->download_count,
                'view_count' => $item->view_count,
                'uploader' => $item->uploader,
                'created_at' => $item->created_at->format('d M Y H:i'),
                'updated_at' => $item->updated_at->format('d M Y H:i'),
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $data,
            'meta' => [
                'current_page' => $media->currentPage(),
                'per_page' => $media->perPage(),
                'total' => $media->total(),
                'last_page' => $media->lastPage(),
            ]
        ]);
    }

    /**
     * Get specific media item.
     */
    public function show(MediaGallery $media): JsonResponse
    {
        // Increment view count
        $media->increment('view_count');

        return response()->json([
            'status' => 'success',
            'data' => [
                'id' => $media->id,
                'title' => $media->title,
                'description' => $media->description,
                'file_type' => $media->file_type,
                'file_url' => asset('storage/' . $media->file_path),
                'mime_type' => $media->mime_type,
                'formatted_size' => $this->formatFileSize($media->file_size),
                'category' => $media->category,
                'tags' => $media->tags,
                'is_featured' => $media->is_featured,
                'download_count' => $media->download_count,
                'view_count' => $media->view_count,
                'uploader' => $media->uploader,
                'created_at' => $media->created_at->format('d M Y H:i'),
                'updated_at' => $media->updated_at->format('d M Y H:i'),
            ]
        ]);
    }

    /**
     * Get media categories.
     */
    public function getCategories(): JsonResponse
    {
        $categories = MediaGallery::select('category')
            ->distinct()
            ->whereNotNull('category')
            ->pluck('category');

        return response()->json([
            'status' => 'success',
            'data' => $categories
        ]);
    }

    /**
     * Download media file.
     */
    public function download(MediaGallery $media)
    {
        $media->increment('download_count');
        
        $filePath = storage_path('app/public/' . $media->file_path);
        
        if (!file_exists($filePath)) {
            return response()->json([
                'status' => 'error',
                'message' => 'File not found'
            ], 404);
        }

        return response()->download($filePath, $media->file_name);
    }

    /**
     * Format file size to human readable format.
     */
    private function formatFileSize($bytes): string
    {
        if ($bytes == 0) return '0 B';
        
        $units = ['B', 'KB', 'MB', 'GB'];
        $i = floor(log($bytes) / log(1024));
        
        return round($bytes / pow(1024, $i), 2) . ' ' . $units[$i];
    }
}
