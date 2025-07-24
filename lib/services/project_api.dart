import 'package:http/http.dart' as http;
import 'dart:convert';

class Project {
  final int id;
  final int userId;
  final String name;

  Project({required this.id, required this.userId, required this.name});

  factory Project.fromJson(Map<String, dynamic> json) => Project(
    id: json['id'],
    userId: json['user_id'],
    name: json['name'],
  );
}

Future<List<Project>> fetchProjects() async {
  final response = await http.get(Uri.parse('http://localhost:5000/projects'));
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    return data.map((json) => Project.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load projects');
  }
}

Future<void> addProject(int userId, String name) async {
  final response = await http.post(
    Uri.parse('http://localhost:5000/projects'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'user_id': userId, 'name': name}),
  );
  if (response.statusCode == 201) {
    // Success
    return;
  } else {
    final error = jsonDecode(response.body);
    throw Exception(error['error'] ?? 'Failed to add project');
  }
}
