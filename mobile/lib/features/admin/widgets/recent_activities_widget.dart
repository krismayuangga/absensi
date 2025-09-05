import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/admin_provider.dart';

class RecentActivitiesWidget extends StatelessWidget {
  const RecentActivitiesWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, adminProvider, child) {
        final activities = adminProvider.recentActivities;

        return Container(
          margin: const EdgeInsets.only(top: 16),
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
                  const Text(
                    "Aktivitas Terkini",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${activities.length} aktivitas',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (activities.isEmpty) ...[
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada aktivitas hari ini',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ...activities
                    .take(5)
                    .map((activity) => _buildActivityItem(activity)),
                if (activities.length > 5) ...[
                  const SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () => _showAllActivities(context, activities),
                      child: Text(
                        'Lihat ${activities.length - 5} aktivitas lainnya',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final name = activity['nama_karyawan'] ?? 'Unknown';
    final action = activity['aksi'] ?? 'Unknown';
    final time = activity['waktu'] ?? '';
    final status = activity['status'] ?? '';
    final employeeCode = activity['kode_karyawan'] ?? '';

    IconData actionIcon;
    Color actionColor;

    switch (action.toLowerCase()) {
      case 'masuk':
        actionIcon = Icons.login;
        actionColor = Colors.green;
        break;
      case 'keluar':
        actionIcon = Icons.logout;
        actionColor = Colors.blue;
        break;
      default:
        actionIcon = Icons.access_time;
        actionColor = Colors.grey;
    }

    Color statusColor = _getStatusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 4,
            color: actionColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: actionColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              actionIcon,
              size: 16,
              color: actionColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '$action • $time',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    if (employeeCode.isNotEmpty) ...[
                      Text(
                        ' • $employeeCode',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'tepat waktu':
      case 'normal':
        return Colors.green;
      case 'terlambat':
        return Colors.orange;
      case 'pulang cepat':
        return Colors.blue;
      case 'lembur':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showAllActivities(
      BuildContext context, List<Map<String, dynamic>> activities) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  const Text(
                    'Semua Aktivitas Hari Ini',
                    style: TextStyle(
                      fontSize: 18,
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
              Expanded(
                child: ListView.builder(
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    return _buildActivityItem(activities[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
