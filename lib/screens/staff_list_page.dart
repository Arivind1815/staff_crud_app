import 'package:flutter/material.dart';
import '../models/staff.dart';
import '../services/firestore_service.dart';
import 'add_staff_page.dart';

class StaffListPage extends StatefulWidget {
  const StaffListPage({super.key});

  @override
  State<StaffListPage> createState() => _StaffListPageState();
}

class _StaffListPageState extends State<StaffListPage> {
  final _service = FirestoreService();
  String _searchQuery = '';
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              final confirm = await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear All Staff?'),
                  content: const Text('This will permanently delete all records.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _service.clearAllStaff();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All staff cleared')));
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search by name or ID', prefixIcon: Icon(Icons.search)),
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Sort by:'),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name')),
                    DropdownMenuItem(value: 'age', child: Text('Age')),
                  ],
                  onChanged: (value) => setState(() => _sortBy = value!),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Staff>>(
              stream: _service.getStaffList(sortBy: _sortBy),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final staffList = snapshot.data!
                    .where((s) => s.name.toLowerCase().contains(_searchQuery) || s.id.toLowerCase().contains(_searchQuery))
                    .toList();
                if (staffList.isEmpty) {
                  return const Center(child: Text('No staff found', style: TextStyle(color: Colors.grey)));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: staffList.length,
                  itemBuilder: (context, index) {
                    final staff = staffList[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        title: Text(staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: ${staff.id} • Age: ${staff.age}'),
                        trailing: Wrap(
                          spacing: 10,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () => Navigator.push(context,
                                MaterialPageRoute(builder: (_) => AddStaffPage(staffToEdit: staff)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete Staff'),
                                    content: const Text('Are you sure you want to delete this staff?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _service.deleteStaff(staff.docId!);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${staff.name} deleted')));
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddStaffPage())),
        label: const Text('Add Staff', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }
}
