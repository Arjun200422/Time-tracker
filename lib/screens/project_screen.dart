import 'package:flutter/material.dart';
import '../services/project_api.dart';

class ProjectScreen extends StatefulWidget {
  @override
  _ProjectScreenState createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  late Future<List<Project>> _futureProjects;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureProjects = fetchProjects();
  }

  void _addProject() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    await addProject(1, name); // Replace 1 with the actual userId as needed
    _controller.clear();
    setState(() {
      _futureProjects = fetchProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Projects')),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(labelText: 'Project Name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addProject,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _futureProjects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final projects = snapshot.data ?? [];
                return ListView(
                  children: projects.map((p) => ListTile(title: Text(p.name))).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
