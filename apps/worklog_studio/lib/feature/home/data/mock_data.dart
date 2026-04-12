import 'package:flutter/material.dart';

enum Priority { low, medium, high, urgent }

enum EntryStatus { active, completed }

class User {
  final String id;
  final String name;
  final String role;
  final String avatarUrl;

  User({
    required this.id,
    required this.name,
    required this.role,
    required this.avatarUrl,
  });
}

class Project {
  final String id;
  final String name;
  final Color accentColor;

  Project({required this.id, required this.name, required this.accentColor});
}

class Task {
  final String id;
  final String title;
  final Project project;
  final DateTime dueDate;
  final Priority priority;

  Task({
    required this.id,
    required this.title,
    required this.project,
    required this.dueDate,
    required this.priority,
  });
}

class TimeEntry {
  final String id;
  final Task task;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final String? comment;
  final EntryStatus status;

  TimeEntry({
    required this.id,
    required this.task,
    required this.startTime,
    this.endTime,
    required this.duration,
    this.comment,
    required this.status,
  });
}

// 1. User
final mockUser = User(
  id: 'u1',
  name: 'Alex Rivera',
  role: 'Lead Designer',
  avatarUrl: 'assets/images/avatars/alex.png',
);

// 2. Projects
final projectNova = Project(
  id: 'p1',
  name: 'Nova Project',
  accentColor: const Color(0xFF0053DB),
);
final projectWorklog = Project(
  id: 'p2',
  name: 'Worklog Core',
  accentColor: const Color(0xFF4B5563),
);
final projectClientHub = Project(
  id: 'p3',
  name: 'Client Hub',
  accentColor: const Color(0xFFF59E0B),
);

final mockProjects = [projectNova, projectWorklog, projectClientHub];

// 3. Tasks (Priority List)
final mockTasks = [
  Task(
    id: 't1',
    title: 'Design System Architecture Refresh',
    project: projectNova,
    dueDate: DateTime.now().add(const Duration(hours: 3)),
    priority: Priority.high,
  ),
  Task(
    id: 't2',
    title: 'Frontend component auditing',
    project: projectWorklog,
    dueDate: DateTime.now().add(const Duration(days: 1)),
    priority: Priority.medium,
  ),
  Task(
    id: 't3',
    title: 'Client Review Meeting Notes',
    project: projectClientHub,
    dueDate: DateTime.now().add(const Duration(days: 2)),
    priority: Priority.low,
  ),
];

// 4. Time Entries (Recent Activity & Active Session)
final mockTimeEntries = [
  // ACTIVE SESSION
  TimeEntry(
    id: 'te1',
    task: Task(
      id: 't4',
      title: 'Nova Branding Phase 2',
      project: projectNova,
      dueDate: DateTime.now(),
      priority: Priority.high,
    ),
    startTime: DateTime.now().subtract(
      const Duration(hours: 2, minutes: 45, seconds: 12),
    ),
    duration: const Duration(hours: 2, minutes: 45, seconds: 12),
    status: EntryStatus.active,
  ),
  // COMPLETED SESSIONS
  TimeEntry(
    id: 'te2',
    task: mockTasks[1], // Dashboard Component Audit
    startTime: DateTime.now().subtract(const Duration(hours: 4, minutes: 30)),
    endTime: DateTime.now().subtract(const Duration(hours: 3)),
    duration: const Duration(hours: 1, minutes: 30),
    status: EntryStatus.completed,
  ),
  TimeEntry(
    id: 'te3',
    task: Task(
      id: 't5',
      title: 'Sprint Planning: October Q4',
      project: projectWorklog,
      dueDate: DateTime.now(),
      priority: Priority.medium,
    ),
    startTime: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
    endTime: DateTime.now().subtract(
      const Duration(days: 1, hours: 1, minutes: 15),
    ),
    duration: const Duration(minutes: 45),
    status: EntryStatus.completed,
  ),
  TimeEntry(
    id: 'te4',
    task: Task(
      id: 't6',
      title: 'Worklog UI Mobile Concept',
      project: projectWorklog,
      dueDate: DateTime.now(),
      priority: Priority.medium,
    ),
    startTime: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    endTime: DateTime.now().subtract(
      const Duration(days: 2, hours: 1, minutes: 48),
    ),
    duration: const Duration(hours: 3, minutes: 12),
    status: EntryStatus.completed,
  ),
];
