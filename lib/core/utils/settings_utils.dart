import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/settings_provider.dart';

class SettingsUtils {
  static void showSettingsDialog(BuildContext context, WidgetRef ref) {
    final currentIp = ref.read(settingsProvider).backendIp;
    final controller = TextEditingController(text: currentIp);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings, color: Color(0xFF1B5E20)),
            SizedBox(width: 10),
            Text('Connection Settings'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your PC\'s IPv4 address to connect to the AI server.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Backend IP Address',
                hintText: 'e.g. 192.168.1.5',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            const Text(
              'Note: Make sure your phone and PC are on the same Wi-Fi.',
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newIp = controller.text.trim();
              if (newIp.isNotEmpty) {
                ref.read(settingsProvider.notifier).updateIp(newIp);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Backend IP updated to $newIp'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1B5E20),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
