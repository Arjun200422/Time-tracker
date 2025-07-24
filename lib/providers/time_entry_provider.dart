import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/time_entry.dart';
import '../models/project.dart';
import '../models/task.dart';
import 'dart:collection';

class TimeEntryProvider extends ChangeNotifier {
  List<TimeEntry> _entries = [];
  List<Project> _projects = [];
  List<Task> _tasks = [];
  bool _initialized = false;

  UnmodifiableListView<TimeEntry> get entries => UnmodifiableListView(_entries);
  UnmodifiableListView<Project> get projects => UnmodifiableListView(_projects);
  UnmodifiableListView<Task> get tasks => UnmodifiableListView(_tasks);
  bool get initialized => _initialized;

  TimeEntryProvider() {
    _init();
  }

  Future<void> _init() async {
    await _loadData();
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesString = prefs.getString('entries');
    if (entriesString != null) {
      final List decoded = jsonDecode(entriesString);
      _entries = decoded.map((e) => TimeEntry.fromJson(e)).toList();
    }
    final projectsString = prefs.getString('projects');
    if (projectsString != null) {
      final List decoded = jsonDecode(projectsString);
      _projects = decoded.map((e) => Project.fromJson(e)).toList();
    }
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      final List decoded = jsonDecode(tasksString);
      _tasks = decoded.map((e) => Task.fromJson(e)).toList();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('entries', jsonEncode(_entries.map((e) => e.toJson()).toList()));
    await prefs.setString('projects', jsonEncode(_projects.map((e) => e.toJson()).toList()));
    await prefs.setString('tasks', jsonEncode(_tasks.map((e) => e.toJson()).toList()));
  }

  void addTimeEntry(TimeEntry entry) {
    _entries.add(entry);
    _saveData();
    notifyListeners();
  }

  void deleteTimeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    _saveData();
    notifyListeners();
  }

  void addProject(Project project) {
    _projects.add(project);
    _saveData();
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveData();
    notifyListeners();
  }

  void deleteProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    _saveData();
    notifyListeners();
  }

  void deleteTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _saveData();
    notifyListeners();
  }

  List<TimeEntry> getEntriesByProject(String projectId) =>
      _entries.where((e) => e.projectId == projectId).toList();

  List<Task> getTasksByProject(String projectId) =>
      _tasks.where((t) => t.projectId == projectId).toList();
}
