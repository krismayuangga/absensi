import 'package:flutter/material.dart';
import '../../../core/providers/admin_provider.dart';

class EmployeeFormDialog extends StatefulWidget {
  final Map<String, dynamic>? employee;
  final AdminProvider adminProvider;

  const EmployeeFormDialog({
    Key? key,
    this.employee,
    required this.adminProvider,
  }) : super(key: key);

  @override
  State<EmployeeFormDialog> createState() => _EmployeeFormDialogState();
}

class _EmployeeFormDialogState extends State<EmployeeFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _selectedCompany;
  String? _selectedDepartment;
  String? _selectedPosition;
  String _selectedStatus = 'active';
  String _selectedGender = 'male';
  DateTime? _selectedBirthDate;
  DateTime? _selectedHireDate;

  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.employee != null;

    if (_isEditMode) {
      _loadEmployeeData();
    } else {
      // Set default hire date to today for new employees
      _selectedHireDate = DateTime.now();
    }
  }

  /// Load complete employee data for edit mode
  Future<void> _loadEmployeeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employeeId = widget.employee!['id'];
      print(
          '🔍 Loading employee data for ID: $employeeId (type: ${employeeId.runtimeType})');

      // Use API call now that backend is stable
      try {
        // Ensure employeeId is int
        final int id;
        if (employeeId is int) {
          id = employeeId;
        } else if (employeeId is String) {
          id = int.parse(employeeId);
        } else {
          throw Exception(
              'Invalid employee ID type: ${employeeId.runtimeType}');
        }

        final employeeData = await widget.adminProvider.getEmployee(id);

        if (employeeData != null) {
          print('📊 Received employee data: $employeeData');
          _populateFieldsWithData(employeeData);
        } else {
          // Fallback to basic data from widget if API fails
          print('⚠️ API failed, using basic data from widget');
          _populateFields();
        }
      } catch (e) {
        print('❌ API error, using basic data from widget: $e');
        _populateFields();
      }
    } catch (e) {
      print('❌ Error loading employee data: $e');
      // Fallback to basic data from widget
      _populateFields();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Populate form fields with complete employee data from API
  void _populateFieldsWithData(Map<String, dynamic> employee) {
    try {
      _nameController.text = employee['name']?.toString() ?? '';
      _emailController.text = employee['email']?.toString() ?? '';
      _phoneController.text = employee['phone']?.toString() ?? '';
      _employeeIdController.text = employee['employee_code']?.toString() ??
          employee['employee_id']?.toString() ??
          '';
      _addressController.text = employee['address']?.toString() ?? '';

      // Debug print to see the actual employee data structure
      print('🔍 Employee data structure: $employee');

      // Set company, department, position using IDs from API with safe null checks
      final companyId = employee['company_id']?.toString();
      if (companyId != null &&
          companyId.isNotEmpty &&
          widget.adminProvider.companies.isNotEmpty &&
          widget.adminProvider.companies
              .any((c) => c['id']?.toString() == companyId)) {
        _selectedCompany = companyId;
      } else {
        _selectedCompany = null;
      }

      final departmentId = employee['department_id']?.toString();
      if (departmentId != null &&
          departmentId.isNotEmpty &&
          widget.adminProvider.departments.isNotEmpty &&
          widget.adminProvider.departments
              .any((d) => d['id']?.toString() == departmentId)) {
        _selectedDepartment = departmentId;
      } else {
        _selectedDepartment = null;
      }

      final positionId = employee['position_id']?.toString();
      if (positionId != null &&
          positionId.isNotEmpty &&
          widget.adminProvider.positions.isNotEmpty &&
          widget.adminProvider.positions
              .any((p) => p['id']?.toString() == positionId)) {
        _selectedPosition = positionId;
      } else {
        _selectedPosition = null;
      }

      // Set status with safe conversion
      try {
        final status = employee['status']?.toString() ?? 'active';
        _selectedStatus = status;
      } catch (e) {
        print('Error setting status: $e');
        _selectedStatus = 'active';
      }

      // Set gender with safe conversion
      try {
        final gender = employee['gender']?.toString() ?? 'male';
        _selectedGender = gender;
      } catch (e) {
        print('Error setting gender: $e');
        _selectedGender = 'male';
      }

      // Parse dates with robust error handling
      if (employee['birth_date'] != null) {
        try {
          final birthDateStr = employee['birth_date']?.toString();
          if (birthDateStr != null && birthDateStr.isNotEmpty) {
            _selectedBirthDate = DateTime.parse(birthDateStr);
          }
        } catch (e) {
          print('Error parsing birth_date: $e');
          _selectedBirthDate = null;
        }
      }

      if (employee['hire_date'] != null || employee['join_date'] != null) {
        try {
          final hireDateStr = employee['hire_date']?.toString() ??
              employee['join_date']?.toString();
          if (hireDateStr != null && hireDateStr.isNotEmpty) {
            _selectedHireDate = DateTime.parse(hireDateStr);
          } else {
            _selectedHireDate = DateTime.now();
          }
        } catch (e) {
          print('Error parsing hire_date: $e');
          _selectedHireDate = DateTime.now();
        }
      }
    } catch (e) {
      print('❌ Error in _populateFieldsWithData: $e');
      // Fallback to basic population method
      _populateFields();
    }
  }

  void _populateFields() {
    final employee = widget.employee!;

    // Handle both Indonesian and English field names for flexibility
    _nameController.text = employee['nama'] ?? employee['name'] ?? '';
    _emailController.text = employee['email'] ?? '';
    _phoneController.text = employee['telepon'] ?? employee['phone'] ?? '';
    _employeeIdController.text = employee['kode_karyawan'] ??
        employee['employee_id'] ??
        employee['employee_code'] ??
        '';
    _addressController.text = employee['alamat'] ?? employee['address'] ?? '';

    // Debug print to see the actual employee data structure
    print('🔍 Employee data structure: $employee');

    // Handle company - check both formats
    String? companyId;
    if (employee['perusahaan'] != null && employee['perusahaan'] is Map) {
      companyId = employee['perusahaan']['id']?.toString();
    } else {
      companyId = employee['company_id']?.toString();
    }

    if (companyId != null &&
        widget.adminProvider.companies
            .any((c) => c['id'].toString() == companyId)) {
      _selectedCompany = companyId;
    } else {
      _selectedCompany = null;
    }

    // Handle department - check both formats
    String? departmentId;
    if (employee['departemen'] != null && employee['departemen'] is Map) {
      departmentId = employee['departemen']['id']?.toString();
    } else {
      departmentId = employee['department_id']?.toString();
    }

    if (departmentId != null &&
        widget.adminProvider.departments
            .any((d) => d['id'].toString() == departmentId)) {
      _selectedDepartment = departmentId;
    } else {
      _selectedDepartment = null;
    }

    // Handle position - check both formats
    String? positionId;
    if (employee['posisi'] != null && employee['posisi'] is Map) {
      positionId = employee['posisi']['id']?.toString();
    } else {
      positionId = employee['position_id']?.toString();
    }

    if (positionId != null &&
        widget.adminProvider.positions
            .any((p) => p['id'].toString() == positionId)) {
      _selectedPosition = positionId;
    } else {
      _selectedPosition = null;
    }

    // Map database status to dropdown values - handle both formats
    final dbStatus = employee['status'] ?? employee['is_active'] ?? 'active';
    String statusValue = 'active';

    if (dbStatus is bool) {
      // Handle boolean is_active format
      statusValue = dbStatus ? 'active' : 'inactive';
    } else {
      // Handle string status format
      switch (dbStatus.toString().toLowerCase()) {
        case 'active':
        case 'aktif':
        case 'true':
          statusValue = 'active';
          break;
        case 'inactive':
        case 'tidak aktif':
        case 'false':
          statusValue = 'inactive';
          break;
        case 'resigned':
        case 'resign':
          statusValue = 'resigned';
          break;
        default:
          statusValue = 'active';
      }
    }
    _selectedStatus = statusValue;

    // Map database gender to dropdown values
    final dbGender = employee['jenis_kelamin'] ?? employee['gender'] ?? 'male';
    _selectedGender = (dbGender.toString().toLowerCase() == 'female' ||
            dbGender.toString().toLowerCase() == 'perempuan')
        ? 'female'
        : 'male';

    // Parse dates - handle both formats
    if (employee['tanggal_lahir'] != null || employee['birth_date'] != null) {
      try {
        final birthDateStr =
            employee['tanggal_lahir'] ?? employee['birth_date'];
        _selectedBirthDate = DateTime.parse(birthDateStr);
      } catch (e) {
        print('Error parsing birth_date: $e');
        _selectedBirthDate = null;
      }
    }

    if (employee['tanggal_bergabung'] != null ||
        employee['hire_date'] != null ||
        employee['join_date'] != null) {
      try {
        final hireDateStr = employee['tanggal_bergabung'] ??
            employee['hire_date'] ??
            employee['join_date'];
        _selectedHireDate = DateTime.parse(hireDateStr);
      } catch (e) {
        print('Error parsing hire_date: $e');
        _selectedHireDate = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Text(
                  _isEditMode ? 'Edit Karyawan' : 'Tambah Karyawan',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),

            const Divider(),

            // Form
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Memuat data karyawan...'),
                        ],
                      ),
                    )
                  : Form(
                      key: _formKey,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Basic Information
                            const Text(
                              'Informasi Dasar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Nama Lengkap *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama lengkap harus diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _employeeIdController,
                              decoration: const InputDecoration(
                                labelText: 'ID Karyawan *',
                                border: OutlineInputBorder(),
                                hintText: 'Contoh: EMP001',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ID karyawan harus diisi';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                labelText: 'Email *',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email harus diisi';
                                }
                                if (!value.contains('@')) {
                                  return 'Format email tidak valid';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _phoneController,
                              decoration: const InputDecoration(
                                labelText: 'Nomor Telepon',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 16),

                            // Gender
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Jenis Kelamin',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'male', child: Text('Laki-laki')),
                                DropdownMenuItem(
                                    value: 'female', child: Text('Perempuan')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedGender = value!;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Birth Date
                            InkWell(
                              onTap: () => _selectBirthDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal Lahir',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedBirthDate != null
                                      ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                                      : 'Pilih tanggal lahir',
                                  style: TextStyle(
                                    color: _selectedBirthDate != null
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            TextFormField(
                              controller: _addressController,
                              decoration: const InputDecoration(
                                labelText: 'Alamat',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),

                            const SizedBox(height: 24),

                            // Work Information
                            const Text(
                              'Informasi Pekerjaan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Company Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedCompany,
                              decoration: const InputDecoration(
                                labelText: 'Perusahaan *',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Pilih Perusahaan'),
                                ),
                                ...widget.adminProvider.companies
                                    .map((company) => DropdownMenuItem(
                                          value: company['id'].toString(),
                                          child: Text(
                                              company['name'] ?? 'Unknown'),
                                        ))
                                    .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCompany = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Department Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedDepartment,
                              decoration: const InputDecoration(
                                labelText: 'Departemen *',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Pilih Departemen'),
                                ),
                                // Temporary static data while API is loading
                                if (widget
                                    .adminProvider.departments.isEmpty) ...[
                                  const DropdownMenuItem(
                                    value: '1',
                                    child: Text('Teknologi Informasi'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '2',
                                    child: Text('Human Resources'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '3',
                                    child: Text('Marketing'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '4',
                                    child: Text('Finance'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '5',
                                    child: Text('Operations'),
                                  ),
                                ] else
                                  ...widget.adminProvider.departments
                                      .map((dept) => DropdownMenuItem(
                                            value: dept['id'].toString(),
                                            child:
                                                Text(dept['name'] ?? 'Unknown'),
                                          ))
                                      .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedDepartment = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Position Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedPosition,
                              decoration: const InputDecoration(
                                labelText: 'Jabatan *',
                                border: OutlineInputBorder(),
                              ),
                              items: [
                                const DropdownMenuItem(
                                  value: null,
                                  child: Text('Pilih Jabatan'),
                                ),
                                // Temporary static data while API is loading
                                if (widget.adminProvider.positions.isEmpty) ...[
                                  const DropdownMenuItem(
                                    value: '1',
                                    child: Text('Manager'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '2',
                                    child: Text('Developer'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '3',
                                    child: Text('Designer'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '4',
                                    child: Text('Marketing'),
                                  ),
                                  const DropdownMenuItem(
                                    value: '5',
                                    child: Text('HR'),
                                  ),
                                ] else
                                  ...widget.adminProvider.positions
                                      .map((pos) => DropdownMenuItem(
                                            value: pos['id'].toString(),
                                            child:
                                                Text(pos['name'] ?? 'Unknown'),
                                          ))
                                      .toList(),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedPosition = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            // Hire Date
                            InkWell(
                              onTap: () => _selectHireDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Tanggal Bergabung *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedHireDate != null
                                      ? '${_selectedHireDate!.day}/${_selectedHireDate!.month}/${_selectedHireDate!.year}'
                                      : 'Pilih tanggal bergabung',
                                  style: TextStyle(
                                    color: _selectedHireDate != null
                                        ? Colors.black
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Status
                            DropdownButtonFormField<String>(
                              value: _selectedStatus,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'active', child: Text('Aktif')),
                                DropdownMenuItem(
                                    value: 'inactive',
                                    child: Text('Tidak Aktif')),
                                DropdownMenuItem(
                                    value: 'resigned', child: Text('Resign')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedStatus = value!;
                                });
                              },
                            ),

                            // Password field for new employees
                            if (!_isEditMode) ...[
                              const SizedBox(height: 24),
                              const Text(
                                'Keamanan',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password *',
                                  border: OutlineInputBorder(),
                                  hintText: 'Minimal 6 karakter',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password harus diisi';
                                  }
                                  if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),

            // Buttons
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveEmployee,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_isEditMode ? 'Update' : 'Simpan'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(1990),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _selectHireDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedHireDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedHireDate = picked;
      });
    }
  }

  Future<void> _saveEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedHireDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tanggal bergabung harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate required fields for backend
    if (_selectedCompany == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perusahaan harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDepartment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Departemen harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jabatan harus dipilih'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final employeeData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'employee_code': _employeeIdController.text
          .trim(), // Changed from employee_id to employee_code
      'address': _addressController.text.trim(),
      'gender': _selectedGender,
      'birth_date': _selectedBirthDate?.toIso8601String().split('T')[0],
      'hire_date': _selectedHireDate!.toIso8601String().split('T')[0],
      'company_id': int.parse(_selectedCompany!), // Now guaranteed not null
      'department_id':
          int.parse(_selectedDepartment!), // Now guaranteed not null
      'position_id': int.parse(_selectedPosition!), // Now guaranteed not null
      'status': _selectedStatus,
    };

    // Add password for new employees (required for creation)
    if (!_isEditMode) {
      if (_passwordController.text.trim().isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password wajib diisi untuk karyawan baru'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      employeeData['password'] = _passwordController.text.trim();
    }

    bool success;
    if (_isEditMode) {
      success = await widget.adminProvider.updateEmployee(
        widget.employee!['id'],
        employeeData,
      );
    } else {
      success = await widget.adminProvider.createEmployee(employeeData);
    }

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Karyawan berhasil diupdate'
                : 'Karyawan berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.adminProvider.errorMessage ??
                (_isEditMode
                    ? 'Gagal mengupdate karyawan'
                    : 'Gagal menambah karyawan'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
