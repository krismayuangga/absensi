<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Models\AnnouncementComment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Validator;

class AnnouncementController extends Controller
{
    /**
     * Get announcements for current user.
     */
    public function index(Request $request): JsonResponse
    {
        $user = Auth::user(); // Can be null for public access
        
        $query = Announcement::active()
            ->published();
            
        // Only apply user filtering if authenticated
        if ($user) {
            $query->forUser($user);
        }
            
        $query->with(['creator:id,name'])
            ->orderByRaw("
                CASE priority 
                    WHEN 'urgent' THEN 1
                    WHEN 'high' THEN 2  
                    WHEN 'medium' THEN 3
                    WHEN 'low' THEN 4
                    ELSE 3
                END
            ")
            ->orderBy('created_at', 'desc');

        // Filter by category if provided
        if ($request->filled('category')) {
            $query->where('category', $request->category);
        }

        // Filter by priority if provided
        if ($request->filled('priority')) {
            $query->where('priority', $request->priority);
        }

        $announcements = $query->paginate($request->get('per_page', 10));

        $data = $announcements->getCollection()->map(function ($announcement) use ($user) {
            // Mark as read when fetched (only if user is authenticated)
            if ($user && !$announcement->is_read_by) {
                $announcement->markAsRead($user->id);
            }

            return [
                'id' => $announcement->id,
                'title' => $announcement->title,
                'content' => $announcement->content,
                'excerpt' => $announcement->excerpt,
                'priority' => $announcement->priority,
                'priority_label' => $announcement->priority_label,
                'priority_color' => $announcement->priority_color,
                'category' => $announcement->category,
                'created_at' => $announcement->created_at->format('d M Y, H:i'),
                'creator' => [
                    'name' => $announcement->creator->name ?? 'System',
                ],
                'stats' => [
                    'read_count' => $announcement->read_count,
                    'like_count' => $announcement->like_count,
                    'comment_count' => $announcement->comment_count,
                ],
                'user_interactions' => [
                    'is_liked' => $announcement->is_liked_by,
                    'is_read' => true, // Always true since we mark as read above
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
    }

    /**
     * Get single announcement details.
     */
    public function show(Announcement $announcement): JsonResponse
    {
        try {
            $user = Auth::user();

            // Mark as read if user is authenticated
            if ($user) {
                $announcement->markAsRead($user->id);
            }

            // Load comments with their user and replies
            $announcement->load([
                'comments' => function($query) {
                    $query->approved()
                          ->whereNull('parent_id') // Only parent comments
                          ->with(['user:id,name,avatar', 'replies.user:id,name,avatar'])
                          ->latest();
                },
                'creator:id,name'
            ]);

            return response()->json([
                'status' => 'success',
                'data' => [
                    'id' => $announcement->id,
                    'title' => $announcement->title,
                    'content' => $announcement->content,
                    'priority' => $announcement->priority,
                    'priority_label' => $announcement->priority_label,
                    'priority_color' => $announcement->priority_color, 
                    'category' => $announcement->category,
                    'created_at' => $announcement->created_at->format('d M Y, H:i'),
                    'creator' => [
                        'name' => $announcement->creator->name ?? 'Admin',
                    ],
                    'stats' => [
                        'read_count' => $announcement->read_count,
                        'like_count' => $announcement->like_count,
                        'comment_count' => $announcement->comment_count,
                    ],
                    'user_interactions' => [
                        'is_liked' => $user ? $announcement->is_liked_by : false,
                        'is_read' => true,
                    ],
                    'comments' => $announcement->comments->map(function($comment) use ($user) {
                        return [
                            'id' => $comment->id,
                            'comment' => $comment->comment,
                            'like_count' => $comment->like_count,
                            'is_liked' => $user ? $comment->is_liked_by : false,
                            'created_at' => $comment->created_at->diffForHumans(),
                            'user' => [
                                'name' => $comment->user->name ?? 'Unknown User',
                                'avatar' => $comment->user->avatar ?? null,
                            ],
                            'replies' => $comment->replies->map(function($reply) use ($user) {
                                return [
                                    'id' => $reply->id,
                                    'comment' => $reply->comment,
                                    'like_count' => $reply->like_count,
                                    'is_liked' => $user ? $reply->is_liked_by : false,
                                    'created_at' => $reply->created_at->diffForHumans(),
                                    'user' => [
                                        'name' => $reply->user->name ?? 'Unknown User',
                                        'avatar' => $reply->user->avatar ?? null,
                                    ],
                                ];
                            }),
                        ];
                    }),
                ],
            ]);
        } catch (\Exception $e) {
            \Log::error('Announcement show error: ' . $e->getMessage());
            return response()->json([
                'status' => 'error',
                'message' => 'Internal server error: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle like on announcement.
     */
    public function toggleLike(Announcement $announcement): JsonResponse
    {
        try {
            $user = Auth::user();
            \Log::info('Toggle like attempt', [
                'user_id' => $user->id,
                'announcement_id' => $announcement->id,
            ]);

            // Simplified access check for debugging
            // Remove complex checks temporarily
            // if (!Announcement::active()->published()->forUser($user)->where('id', $announcement->id)->exists()) {
            //     return response()->json([
            //         'status' => 'error',
            //         'message' => 'Pengumuman tidak ditemukan',
            //     ], 404);
            // }

            // Simple manual toggle logic for debugging
            $existingLike = \App\Models\AnnouncementInteraction::where([
                'announcement_id' => $announcement->id,
                'user_id' => $user->id,
                'interaction_type' => 'like',
            ])->first();

            \Log::info('Existing like check', ['existing_like' => $existingLike ? 'found' : 'not found']);

            if ($existingLike) {
                // Unlike
                $existingLike->delete();
                $announcement->decrement('like_count');
                $isLiked = false;
                \Log::info('Unliked announcement');
            } else {
                // Like
                \App\Models\AnnouncementInteraction::create([
                    'announcement_id' => $announcement->id,
                    'user_id' => $user->id,
                    'interaction_type' => 'like',
                ]);
                $announcement->increment('like_count');
                $isLiked = true;
                \Log::info('Liked announcement');
            }

            return response()->json([
                'status' => 'success',
                'data' => [
                    'is_liked' => $isLiked,
                    'like_count' => $announcement->fresh()->like_count,
                ],
                'message' => $isLiked ? 'Pengumuman disukai' : 'Batal menyukai pengumuman',
            ]);

        } catch (\Exception $e) {
            \Log::error('Toggle like error: ' . $e->getMessage(), [
                'exception' => $e,
                'trace' => $e->getTraceAsString(),
                'announcement_id' => $announcement->id ?? 'unknown',
                'user_id' => $user->id ?? 'unknown'
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengubah status like: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Add comment to announcement.
     */
    public function addComment(Request $request, Announcement $announcement): JsonResponse
    {
        try {
            $user = Auth::user();
            \Log::info('Add comment attempt', [
                'user_id' => $user->id,
                'announcement_id' => $announcement->id,
                'request_data' => $request->all()
            ]);

            $validator = Validator::make($request->all(), [
                'comment' => 'required|string|max:1000',
                'parent_id' => 'nullable|exists:announcement_comments,id',
            ]);

            if ($validator->fails()) {
                \Log::error('Validation failed for comment', [
                    'errors' => $validator->errors(),
                    'request' => $request->all()
                ]);
                return response()->json([
                    'status' => 'error',
                    'message' => 'Data tidak valid',
                    'errors' => $validator->errors(),
                ], 422);
            }

            \Log::info('Creating comment in database');
            $comment = AnnouncementComment::create([
                'announcement_id' => $announcement->id,
                'user_id' => $user->id,
                'comment' => $request->comment,
                'parent_id' => $request->parent_id,
                'is_approved' => true, // Auto approve for now
            ]);
            \Log::info('Comment created successfully', ['comment_id' => $comment->id]);

            // Update comment count
            $announcement->increment('comment_count');

            // Load user relationship
            $comment->load('user:id,name,avatar');

            return response()->json([
                'status' => 'success',
                'comment' => [
                    'id' => $comment->id,
                    'comment' => $comment->comment,
                    'like_count' => 0,
                    'is_liked' => false,
                    'created_at' => $comment->created_at->diffForHumans(),
                    'user' => [
                        'name' => $comment->user->name ?? 'Unknown User',
                        'avatar' => $comment->user->avatar ?? null,
                    ],
                    'replies' => [],
                ],
                'message' => 'Komentar berhasil ditambahkan',
            ], 201);

        } catch (\Exception $e) {
            \Log::error('Add comment error: ' . $e->getMessage(), [
                'exception' => $e,
                'trace' => $e->getTraceAsString(),
                'announcement_id' => $announcement->id ?? 'unknown',
                'user_id' => $user->id ?? 'unknown'
            ]);
            
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal menambahkan komentar: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Toggle like on comment.
     */
    public function toggleCommentLike(AnnouncementComment $comment): JsonResponse
    {
        $user = Auth::user();

        // Verify comment belongs to accessible announcement
        $announcement = $comment->announcement;
        if (!Announcement::active()->published()->forUser($user)->where('id', $announcement->id)->exists()) {
            return response()->json([
                'status' => 'error',
                'message' => 'Komentar tidak ditemukan',
            ], 404);
        }

        $isLiked = $comment->toggleLike($user->id);

        return response()->json([
            'status' => 'success',
            'data' => [
                'is_liked' => $isLiked,
                'like_count' => $comment->fresh()->like_count,
            ],
            'message' => $isLiked ? 'Komentar disukai' : 'Batal menyukai komentar',
        ]);
    }

    /**
     * Get announcement categories.
     */
    public function getCategories(): JsonResponse
    {
        $user = Auth::user();
        
        $categories = Announcement::active()
            ->published()
            ->forUser($user)
            ->distinct()
            ->pluck('category')
            ->filter()
            ->map(function ($category) {
                return [
                    'value' => $category,
                    'label' => ucfirst($category),
                ];
            })
            ->values();

        return response()->json([
            'status' => 'success',
            'data' => $categories,
        ]);
    }
}
