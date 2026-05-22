import 'package:flutter/material.dart';

class RemedyDatabaseScreen extends StatefulWidget {
  const RemedyDatabaseScreen({super.key});

  @override
  State<RemedyDatabaseScreen> createState() => _RemedyDatabaseScreenState();
}

class _RemedyDatabaseScreenState extends State<RemedyDatabaseScreen> {
  final List<Map<String, String>> _allRemedies = [];

  List<Map<String, String>> _filteredRemedies = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredRemedies = _allRemedies;
  }

  void _filterRemedies(String query) {
    setState(() {
      _filteredRemedies = _allRemedies
          .where((r) =>
              r['name']!.toLowerCase().contains(query.toLowerCase()) ||
              r['use']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remedy Database'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search remedies or uses...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: _filterRemedies,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredRemedies.length,
              itemBuilder: (context, index) {
                final remedy = _filteredRemedies[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ExpansionTile(
                    title: Text(remedy['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(remedy['use']!),
                    leading: const Icon(Icons.medical_services_outlined, color: Colors.green),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Personal Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            TextField(
                              decoration: const InputDecoration(
                                hintText: 'Add your personal notes for this remedy...',
                                border: OutlineInputBorder(),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: const Text('Save Note'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRemedyDialog(context),
        label: const Text('Add Remedy'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRemedyDialog(BuildContext context) {
    final nameController = TextEditingController();
    final useController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Custom Remedy'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Remedy Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: useController,
              decoration: const InputDecoration(labelText: 'Common Uses'),
              maxLines: 2,
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
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _allRemedies.insert(0, {
                    'name': nameController.text,
                    'use': useController.text,
                  });
                  _filteredRemedies = _allRemedies;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
