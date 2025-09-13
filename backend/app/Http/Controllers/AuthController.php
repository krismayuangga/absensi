<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Tymon\JWTAuth\Facades\JWTAuth;
use Tymon\JWTAuth\Exceptions\JWTException;

class AuthController extends Controller
{
    /**
     * Get a JWT via given credentials.
     */
    public function login(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string|min:6',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $credentials = $request->only('email', 'password');

        try {
            if (!$token = JWTAuth::attempt($credentials)) {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid credentials'
                ], 401);
            }
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Could not create token'
            ], 500);
        }

        $user = Auth::user();
        
        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth('api')->factory()->getTTL() * 60,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'employee_id' => $user->employee_id,
                'role' => $user->role,
                'position' => $user->position,
                'department' => $user->department,
                'company_id' => $user->company_id,
                'is_active' => $user->is_active,
                'avatar' => $user->avatar,
            ]
        ]);
    }

    /**
     * Register a new user.
     */
    public function register(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6|confirmed',
            'employee_id' => 'required|string|unique:users',
            'phone' => 'nullable|string|max:20',
            'role' => 'in:admin,manager,employee',
            'position' => 'nullable|string|max:100',
            'department' => 'nullable|string|max:100',
            'company_id' => 'nullable|exists:companies,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'employee_id' => $request->employee_id,
            'phone' => $request->phone,
            'role' => $request->role ?? 'employee',
            'position' => $request->position,
            'department' => $request->department,
            'company_id' => $request->company_id,
            'is_active' => true,
        ]);

        $token = JWTAuth::fromUser($user);

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'employee_id' => $user->employee_id,
                'role' => $user->role,
                'position' => $user->position,
                'department' => $user->department,
                'company_id' => $user->company_id,
                'is_active' => $user->is_active,
            ]
        ], 201);
    }

    /**
     * Get the authenticated User.
     */
    public function profile(): JsonResponse
    {
        try {
            $user = Auth::user();
            
            if (!$user) {
                return response()->json([
                    'success' => false,
                    'message' => 'User not authenticated'
                ], 401);
            }
            
            return response()->json([
                'success' => true,
                'data' => [
                    'id' => $user->id,
                    'employee_id' => $user->employee_id ?? 'EMP' . str_pad($user->id, 3, '0', STR_PAD_LEFT),
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'birth_date' => $user->birth_date,
                    'gender' => $user->gender,
                    'address' => $user->address,
                    'avatar' => $user->avatar ? asset('storage/' . $user->avatar) : null,
                    'role' => $user->role ?? 'employee',
                    'status' => $user->is_active ? 'active' : 'inactive',
                    'is_active' => $user->is_active ?? true,
                    'position' => $user->position ?? 'Employee',
                    'department' => $user->department ?? 'General',
                    'company_id' => $user->company_id,
                    'created_at' => $user->created_at,
                    'updated_at' => $user->updated_at,
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error getting user profile: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update user profile.
     */
    public function updateProfile(Request $request): JsonResponse
    {
        try {
            $user = Auth::user();
            
            // Debug logging
            Log::info('Update Profile Request', [
                'files' => $request->allFiles(),
                'all_data' => $request->all(),
                'has_avatar_file' => $request->hasFile('avatar')
            ]);
            
            $validator = Validator::make($request->all(), [
                'name' => 'sometimes|string|max:255',
                'phone' => 'sometimes|nullable|string|max:20',
                'birth_date' => 'sometimes|nullable|date',
                'address' => 'sometimes|nullable|string|max:500',
                'gender' => 'sometimes|nullable|in:male,female',
                'position' => 'sometimes|nullable|string|max:100',
                'department' => 'sometimes|nullable|string|max:100',
                'avatar' => 'sometimes|image|mimes:jpeg,png,jpg,gif|max:2048',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors()
                ], 422);
            }

            // Handle avatar upload
            if ($request->hasFile('avatar')) {
                // Delete old avatar if exists
                if ($user->avatar) {
                    Storage::disk('public')->delete($user->avatar);
                }

                $avatarFile = $request->file('avatar');
                $filename = 'avatar_' . $user->id . '_' . time() . '.' . $avatarFile->getClientOriginalExtension();
                $path = $avatarFile->storeAs('avatars', $filename, 'public');
                $user->avatar = $path;
            }

            // Update other profile fields (exclude avatar as it's handled separately)
            $fillableFields = ['name', 'phone', 'birth_date', 'address', 'gender', 'position', 'department'];
            foreach ($fillableFields as $field) {
                if ($request->has($field) && $field !== 'avatar') {
                    $user->$field = $request->$field;
                }
            }

            $user->save();

            return response()->json([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => [
                    'id' => $user->id,
                    'employee_id' => $user->employee_id ?? 'EMP' . str_pad($user->id, 3, '0', STR_PAD_LEFT),
                    'name' => $user->name,
                    'email' => $user->email,
                    'phone' => $user->phone,
                    'birth_date' => $user->birth_date,
                    'gender' => $user->gender,
                    'address' => $user->address,
                    'profile_picture' => $user->profile_picture,
                    'avatar' => $user->avatar ? asset('storage/' . $user->avatar) : null,
                    'role' => $user->role ?? 'employee',
                    'status' => $user->is_active ? 'active' : 'inactive',
                    'is_active' => $user->is_active ?? true,
                    'position' => $user->position ?? 'Employee',
                    'department' => $user->department ?? 'General',
                    'company_id' => $user->company_id,
                    'updated_at' => $user->updated_at,
                ]
            ]);
            
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating profile: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Change user password.
     */
    public function changePassword(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:6|confirmed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = Auth::user();

        if (!Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Current password is incorrect'
            ], 400);
        }

        $user->update([
            'password' => Hash::make($request->new_password)
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Password changed successfully'
        ]);
    }

    /**
     * Log the user out (Invalidate the token).
     */
    public function logout(): JsonResponse
    {
        try {
            JWTAuth::invalidate(JWTAuth::getToken());
            
            return response()->json([
                'success' => true,
                'message' => 'Successfully logged out'
            ]);
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to logout, please try again'
            ], 500);
        }
    }

    /**
     * Refresh a token.
     */
    public function refresh(): JsonResponse
    {
        try {
            $token = JWTAuth::refresh(JWTAuth::getToken());
            
            return response()->json([
                'success' => true,
                'token' => $token,
                'token_type' => 'bearer',
                'expires_in' => auth('api')->factory()->getTTL() * 60
            ]);
        } catch (JWTException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Token cannot be refreshed'
            ], 500);
        }
    }
}
