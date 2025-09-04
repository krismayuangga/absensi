<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Attendance;
use App\Models\Leave;
use App\Models\Company;
use App\Models\Department;
use App\Models\Position;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class AdminController extends Controller
{
    /**
     * Get dashboard statistics
     */
    public function getDashboardStats()
    {
        try {
            // Simple test data first
            $stats = [
                'total_employees' => 10,
                'today_attendance' => 8,
                'attendance_percentage' => 80.0,
                'pending_leaves' => 2,
                'monthly_average' => 7.5,
            ];
            
            $activities = [
                [
                    'id' => 1,
                    'employee_name' => 'Test Employee',
                    'employee_code' => 'EMP001',
                    'action' => 'clock_in',
                    'time' => '2025-09-04T09:00:00Z',
                    'date' => '2025-09-04',
                    'status' => 'present',
                ]
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'stats' => $stats,
                    'recent_activities' => $activities,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving dashboard stats: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get all employees with pagination
     */
    public function getEmployees(Request $request)
    {
        try {
            // Simple test data first
            $employees = [
                'data' => [
                    [
                        'id' => 1,
                        'name' => 'Test Employee 1',
                        'email' => 'employee1@test.com',
                        'employee_code' => 'EMP001',
                        'phone' => '081234567890',
                        'hire_date' => '2024-01-15',
                        'status' => 'active',
                        'salary' => 5000000,
                        'company' => ['id' => 1, 'name' => 'Main Company'],
                        'department' => ['id' => 1, 'name' => 'IT Department'],
                        'position' => ['id' => 1, 'name' => 'Developer'],
                    ],
                    [
                        'id' => 2,
                        'name' => 'Test Employee 2',
                        'email' => 'employee2@test.com',
                        'employee_code' => 'EMP002',
                        'phone' => '081234567891',
                        'hire_date' => '2024-02-10',
                        'status' => 'active',
                        'salary' => 4500000,
                        'company' => ['id' => 1, 'name' => 'Main Company'],
                        'department' => ['id' => 2, 'name' => 'HR Department'],
                        'position' => ['id' => 2, 'name' => 'Manager'],
                    ],
                ],
                'current_page' => 1,
                'last_page' => 1,
                'per_page' => 15,
                'total' => 2,
            ];
            
            return response()->json([
                'success' => true,
                'data' => $employees,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving employees: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Create new employee
     */
    public function createEmployee(Request $request)
    {
        try {
            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'phone' => 'nullable|string|max:20',
                'employee_code' => 'required|string|unique:users,employee_code',
                'company_id' => 'required|exists:companies,id',
                'department_id' => 'required|exists:departments,id',
                'position_id' => 'required|exists:positions,id',
                'hire_date' => 'required|date',
                'salary' => 'nullable|numeric|min:0',
                'password' => 'required|string|min:6',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $employee = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'phone' => $request->phone,
                'employee_code' => $request->employee_code,
                'company_id' => $request->company_id,
                'department_id' => $request->department_id,
                'position_id' => $request->position_id,
                'hire_date' => $request->hire_date,
                'salary' => $request->salary,
                'role' => 'employee',
                'status' => 'active',
                'password' => Hash::make($request->password),
            ]);

            $employee->load(['company:id,name', 'department:id,name', 'position:id,name']);

            return response()->json([
                'success' => true,
                'message' => 'Employee created successfully',
                'data' => $employee,
            ], 201);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error creating employee: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update employee
     */
    public function updateEmployee(Request $request, $id)
    {
        try {
            $employee = User::where('role', 'employee')->findOrFail($id);

            $validator = Validator::make($request->all(), [
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email,' . $id,
                'phone' => 'nullable|string|max:20',
                'employee_code' => 'required|string|unique:users,employee_code,' . $id,
                'company_id' => 'required|exists:companies,id',
                'department_id' => 'required|exists:departments,id',
                'position_id' => 'required|exists:positions,id',
                'hire_date' => 'required|date',
                'salary' => 'nullable|numeric|min:0',
                'status' => 'required|in:active,inactive',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $employee->update($request->only([
                'name', 'email', 'phone', 'employee_code', 'company_id',
                'department_id', 'position_id', 'hire_date', 'salary', 'status'
            ]));

            $employee->load(['company:id,name', 'department:id,name', 'position:id,name']);

            return response()->json([
                'success' => true,
                'message' => 'Employee updated successfully',
                'data' => $employee,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating employee: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Delete employee
     */
    public function deleteEmployee($id)
    {
        try {
            $employee = User::where('role', 'employee')->findOrFail($id);
            $employee->delete();

            return response()->json([
                'success' => true,
                'message' => 'Employee deleted successfully',
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error deleting employee: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get attendance records with filtering
     */
    public function getAttendanceRecords(Request $request)
    {
        try {
            $perPage = $request->get('per_page', 15);
            $date = $request->get('date');
            $employeeId = $request->get('employee_id');
            $status = $request->get('status');
            
            $query = Attendance::with(['user:id,name,employee_code']);
            
            if ($date) {
                $query->whereDate('date', $date);
            }
            
            if ($employeeId) {
                $query->where('user_id', $employeeId);
            }
            
            if ($status) {
                $query->where('status', $status);
            }
            
            $attendances = $query->latest('date')->paginate($perPage);
            
            return response()->json([
                'success' => true,
                'data' => $attendances,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving attendance records: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get leave requests with filtering
     */
    public function getLeaveRequests(Request $request)
    {
        try {
            $perPage = $request->get('per_page', 15);
            $status = $request->get('status');
            $employeeId = $request->get('employee_id');
            
            $query = Leave::with(['user:id,name,employee_code']);
            
            if ($status) {
                $query->where('status', $status);
            }
            
            if ($employeeId) {
                $query->where('user_id', $employeeId);
            }
            
            $leaves = $query->latest('created_at')->paginate($perPage);
            
            return response()->json([
                'success' => true,
                'data' => $leaves,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving leave requests: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Approve/Reject leave request
     */
    public function updateLeaveStatus(Request $request, $id)
    {
        try {
            $validator = Validator::make($request->all(), [
                'status' => 'required|in:approved,rejected',
                'admin_notes' => 'nullable|string|max:1000',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation error',
                    'errors' => $validator->errors(),
                ], 422);
            }

            $leave = Leave::findOrFail($id);
            
            $leave->update([
                'status' => $request->status,
                'admin_notes' => $request->admin_notes,
                'approved_by' => auth()->id(),
                'approved_at' => now(),
            ]);

            $leave->load(['user:id,name,employee_code']);

            return response()->json([
                'success' => true,
                'message' => 'Leave request updated successfully',
                'data' => $leave,
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating leave request: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get companies, departments, and positions for dropdowns
     */
    public function getMasterData()
    {
        try {
            // Simple test data first
            $companies = [
                ['id' => 1, 'name' => 'Main Company'],
                ['id' => 2, 'name' => 'Branch Office'],
            ];
            
            $departments = [
                ['id' => 1, 'name' => 'IT Department'],
                ['id' => 2, 'name' => 'HR Department'],
                ['id' => 3, 'name' => 'Finance Department'],
            ];
            
            $positions = [
                ['id' => 1, 'name' => 'Manager'],
                ['id' => 2, 'name' => 'Developer'],
                ['id' => 3, 'name' => 'Staff'],
            ];

            return response()->json([
                'success' => true,
                'data' => [
                    'companies' => $companies,
                    'departments' => $departments,
                    'positions' => $positions,
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving master data: ' . $e->getMessage(),
            ], 500);
        }
    }
}
