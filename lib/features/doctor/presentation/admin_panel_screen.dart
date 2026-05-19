import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AdminPanelScreen extends ConsumerWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(context, 'Clinic Management'),
            const SizedBox(height: 16),
            _AdminActionTile(
              title: 'Doctor Profiles',
              subtitle: 'Manage doctor details and specializations',
              icon: Icons.person_add,
              onTap: () {},
            ),
            _AdminActionTile(
              title: 'Working Hours',
              subtitle: 'Set clinic timings and availability',
              icon: Icons.access_time,
              onTap: () {},
            ),
            _AdminActionTile(
              title: 'Clinic Holidays',
              subtitle: 'Manage holidays and planned leaves',
              icon: Icons.event_busy,
              onTap: () {},
            ),
            _AdminActionTile(
              title: 'Staff Accounts',
              subtitle: 'Manage receptionist and assistant accounts',
              icon: Icons.people_outline,
              onTap: () {},
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(context, 'Analytics & Reports'),
            const SizedBox(height: 16),
            _buildRevenueChart(context),
            const SizedBox(height: 24),
            _buildAppointmentStats(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
    );
  }

  Widget _buildRevenueChart(BuildContext context) {
    final List<_RevenueData> chartData = [
      _RevenueData('Jan', 45000),
      _RevenueData('Feb', 60000),
      _RevenueData('Mar', 80000),
      _RevenueData('Apr', 70000),
      _RevenueData('May', 90000),
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Revenue',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries<_RevenueData, String>>[
                  ColumnSeries<_RevenueData, String>(
                    dataSource: chartData,
                    xValueMapper: (_RevenueData data, _) => data.month,
                    yValueMapper: (_RevenueData data, _) => data.revenue,
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  )
                ],
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentStats(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: 'Completed', value: '124', color: Colors.green),
                _StatItem(label: 'Cancelled', value: '12', color: Colors.red),
                _StatItem(label: 'No Show', value: '5', color: Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueData {
  _RevenueData(this.month, this.revenue);
  final String month;
  final double revenue;
}

class _AdminActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
