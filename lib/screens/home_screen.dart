import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import 'add_time_entry_screen.dart';
import 'project_task_management_screen.dart';
import 'package:intl/intl.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'project_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);

    if (!provider.initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final projectTotals = <String, int>{};
    for (var entry in provider.entries) {
      projectTotals[entry.projectId] =
          (projectTotals[entry.projectId] ?? 0) + entry.minutes;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Time Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ProjectScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: provider.entries.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No time entries yet!',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 8),
                  Text('Tap the + button to add your first entry.',
                      style: TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              children: [
                if (projectTotals.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.indigo.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Total Time by Project",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            ...projectTotals.entries.map((e) {
                              final project = provider.projects
                                  .firstWhere(
                                      (p) => p.id == e.key,
                                      orElse: () => Project(
                                          id: e.key, name: "Unknown Project"));
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 2),
                                child: Text(
                                  "${project.name}: ${e.value} min",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ...provider.entries.map((entry) {
                  final project = provider.projects.firstWhere(
                      (p) => p.id == entry.projectId,
                      orElse: () => Project(id: '', name: 'Unknown Project'));
                  final task = provider.tasks.firstWhere(
                      (t) => t.id == entry.taskId,
                      orElse: () => Task(id: '', projectId: '', name: 'Unknown Task'));
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    elevation: 2,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Text(
                          project.name.isNotEmpty ? project.name[0] : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        "${project.name} - ${task.name}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${DateFormat.yMMMd().format(entry.date)}\n"
                        "${entry.minutes} min | ${entry.notes}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          provider.deleteTimeEntry(entry.id);
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTimeEntryScreen()),
          );
        },
        label: const Text('Add Entry'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
