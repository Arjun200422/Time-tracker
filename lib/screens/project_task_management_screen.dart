import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/time_entry_provider.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class ProjectTaskManagementScreen extends StatefulWidget {
  const ProjectTaskManagementScreen({super.key});

  @override
  State<ProjectTaskManagementScreen> createState() => _ProjectTaskManagementScreenState();
}

class _ProjectTaskManagementScreenState extends State<ProjectTaskManagementScreen> {
  final _projectController = TextEditingController();
  final _taskController = TextEditingController();
  String? _selectedProject;

  @override
  void dispose() {
    _projectController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TimeEntryProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Projects & Tasks')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Projects', style: TextStyle(fontWeight: FontWeight.bold)),
            ...provider.projects.map((p) => ListTile(
              title: Text(p.name),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => provider.deleteProject(p.id),
              ),
              onTap: () {
                setState(() {
                  _selectedProject = p.id;
                });
              },
              selected: _selectedProject == p.id,
            )),
            TextField(
              controller: _projectController,
              decoration: InputDecoration(
                labelText: 'Add Project',
                hintText: 'Enter project name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_projectController.text.trim().isNotEmpty) {
                      provider.addProject(
                        Project(id: const Uuid().v4(), name: _projectController.text.trim()),
                      );
                      _projectController.clear();
                    }
                  },
                ),
              ),
            ),
            const Divider(height: 32),
            if (_selectedProject != null) ...[
              Text('Tasks for selected project', style: const TextStyle(fontWeight: FontWeight.bold)),
              ...provider.getTasksByProject(_selectedProject!).map((t) => ListTile(
                title: Text(t.name),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => provider.deleteTask(t.id),
                ),
              )),
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'Add Task',
                  hintText: 'Enter task name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      if (_taskController.text.trim().isNotEmpty) {
                        provider.addTask(
                          Task(
                            id: const Uuid().v4(),
                            projectId: _selectedProject!,
                            name: _taskController.text.trim(),
                          ),
                        );
                        _taskController.clear();
                      }
                    },
                  ),
                ),
              ),
            ] else
              const Text('Select a project to manage its tasks.'),
          ],
        ),
      ),
    );
  }
}
