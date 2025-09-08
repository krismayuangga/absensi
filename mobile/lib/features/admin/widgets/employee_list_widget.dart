import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/admin_provider.dart';
import 'employee_form_dialog.dart';

class EmployeeListWidget extends StatefulWidget {
  const EmployeeListWidget({Key? key}) : super(key: key);

  @override
  State<EmployeeListWidget> createState() => _EmployeeListWidgetState();
}

class _EmployeeListWidgetState extends State<EmployeeListWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminProvider>(context, listen: false)
          .loadEmployees(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        return RefreshIndicator(
          onRefresh: () async {
            await adminProvider.loadEmployees(
                refresh: true, search: _searchQuery);
          },
          child: Column(
            children: [
              // Search section
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search employees...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          adminProvider.loadEmployees(
                              refresh: true, search: value);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FloatingActionButton(
                      mini: true,
                      onPressed: () => _showAddEmployeeDialog(),
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
              ),

              // Employee list
              Expanded(
                child: adminProvider.isLoadingEmployees
                    ? const Center(child: CircularProgressIndicator())
                    : adminProvider.employees.isEmpty
                        ? const Center(
                            child: Text(
                              'No employees found',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: adminProvider.employees.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final employee = adminProvider.employees[index];

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      spreadRadius: 1,
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          child: Text(
                                            employee['name']
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                'U',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                employee['nama'] ??
                                                    employee['name'] ??
                                                    '',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                employee['kode_karyawan'] ??
                                                    employee['employee_code'] ??
                                                    '',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'edit':
                                                _showEditEmployeeDialog(
                                                    employee);
                                                break;
                                              case 'delete':
                                                _showDeleteConfirmation(
                                                    employee);
                                                break;
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(
                                              value: 'edit',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit, size: 18),
                                                  SizedBox(width: 8),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ),
                                            const PopupMenuItem(
                                              value: 'delete',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      size: 18,
                                                      color: Colors.red),
                                                  SizedBox(width: 8),
                                                  Text('Delete',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),

                                    // Employee details
                                    Row(
                                      children: [
                                        Icon(Icons.email,
                                            size: 16,
                                            color: Colors.grey.shade600),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            employee['email'] ?? '',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    if (employee['telepon'] != null ||
                                        employee['phone'] != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone,
                                              size: 16,
                                              color: Colors.grey.shade600),
                                          const SizedBox(width: 6),
                                          Text(
                                            employee['telepon'] ??
                                                employee['phone'] ??
                                                '',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],

                                    const SizedBox(height: 8),

                                    // Company, Department, Position
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        if (employee['perusahaan'] != null)
                                          _buildChip(
                                            employee['perusahaan']['nama']
                                                    ?.toString() ??
                                                'Unknown Company',
                                            Colors.blue,
                                          ),
                                        if (employee['departemen'] != null)
                                          _buildChip(
                                            employee['departemen']['nama']
                                                    ?.toString() ??
                                                'Unknown Department',
                                            Colors.green,
                                          ),
                                        if (employee['posisi'] != null)
                                          _buildChip(
                                            employee['posisi']['nama']
                                                    ?.toString() ??
                                                'Unknown Position',
                                            Colors.orange,
                                          ),
                                      ],
                                    ),

                                    const SizedBox(height: 8),

                                    // Status and Join Date
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(
                                                employee['status']),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            employee['status']
                                                    ?.toString()
                                                    .toUpperCase() ??
                                                'UNKNOWN',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child:
                                              (employee['tanggal_bergabung'] !=
                                                          null ||
                                                      employee['hire_date'] !=
                                                          null)
                                                  ? Text(
                                                      'Bergabung: ${_formatDate(employee['tanggal_bergabung'] ?? employee['hire_date'])}',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontSize: 10,
                                                      ),
                                                      textAlign: TextAlign.end,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    )
                                                  : const SizedBox.shrink(),
                                        ),
                                      ],
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

  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _showAddEmployeeDialog() {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(
        adminProvider: adminProvider,
      ),
    );
  }

  void _showEditEmployeeDialog(Map<String, dynamic> employee) {
    final adminProvider = Provider.of<AdminProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => EmployeeFormDialog(
        employee: employee,
        adminProvider: adminProvider,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text(
            'Are you sure you want to delete ${employee['nama'] ?? employee['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final adminProvider =
                  Provider.of<AdminProvider>(context, listen: false);
              final success =
                  await adminProvider.deleteEmployee(employee['id']);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Employee deleted successfully'
                        : adminProvider.errorMessage ??
                            'Failed to delete employee'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
