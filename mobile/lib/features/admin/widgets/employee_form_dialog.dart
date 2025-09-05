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
      _populateFields();
    } else {
      // Set default hire date to today for new employees
      _selectedHireDate = DateTime.now();
    }
  }

  void _populateFields() {
    final employee = widget.employee!;
    _nameController.text = employee['name'] ?? '';
    _emailController.text = employee['email'] ?? '';
    _phoneController.text = employee['phone'] ?? '';
    _employeeIdController.text = employee['employee_id'] ?? '';
    _addressController.text = employee['address'] ?? '';
    _selectedCompany = employee['company_id']?.toString();
    _selectedDepartment = employee['department_id']?.toString();
    _selectedPosition = employee['position_id']?.toString();
    _selectedStatus = employee['status'] ?? 'active';
    _selectedGender = employee['gender'] ?? 'male';

    if (employee['birth_date'] != null) {
      try {
        _selectedBirthDate = DateTime.parse(employee['birth_date']);
      } catch (e) {
        _selectedBirthDate = null;
      }
    }

    if (employee['hire_date'] != null) {
      try {
        _selectedHireDate = DateTime.parse(employee['hire_date']);
      } catch (e) {
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
              child: Form(
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
                          labelText: 'Perusahaan',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.adminProvider.companies
                            .map((company) => DropdownMenuItem(
                                  value: company['id'].toString(),
                                  child: Text(company['name']),
                                ))
                            .toList(),
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
                          labelText: 'Departemen',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.adminProvider.departments
                            .map((dept) => DropdownMenuItem(
                                  value: dept['id'].toString(),
                                  child: Text(dept['name']),
                                ))
                            .toList(),
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
                          labelText: 'Jabatan',
                          border: OutlineInputBorder(),
                        ),
                        items: widget.adminProvider.positions
                            .map((pos) => DropdownMenuItem(
                                  value: pos['id'].toString(),
                                  child: Text(pos['name']),
                                ))
                            .toList(),
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
                              value: 'inactive', child: Text('Tidak Aktif')),
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

    setState(() {
      _isLoading = true;
    });

    final employeeData = {
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'employee_id': _employeeIdController.text.trim(),
      'address': _addressController.text.trim(),
      'gender': _selectedGender,
      'birth_date': _selectedBirthDate?.toIso8601String().split('T')[0],
      'hire_date': _selectedHireDate!.toIso8601String().split('T')[0],
      'company_id':
          _selectedCompany != null ? int.tryParse(_selectedCompany!) : null,
      'department_id': _selectedDepartment != null
          ? int.tryParse(_selectedDepartment!)
          : null,
      'position_id':
          _selectedPosition != null ? int.tryParse(_selectedPosition!) : null,
      'status': _selectedStatus,
    };

    // Add password for new employees
    if (!_isEditMode && _passwordController.text.isNotEmpty) {
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
