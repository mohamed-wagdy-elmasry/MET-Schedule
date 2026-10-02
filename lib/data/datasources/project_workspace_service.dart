import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model representing a quick resource/link for the project (Drive, GitHub, Figma, etc.)
class ProjectLink {
  final String id;
  final String title;
  final String url;
  final String type; // 'drive', 'github', 'figma', 'slides', 'docs', 'other'

  ProjectLink({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'url': url,
        'type': type,
      };

  factory ProjectLink.fromJson(Map<String, dynamic> json) => ProjectLink(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        url: json['url'] as String? ?? '',
        type: json['type'] as String? ?? 'other',
      );

  ProjectLink copyWith({String? title, String? url, String? type}) {
    return ProjectLink(
      id: id,
      title: title ?? this.title,
      url: url ?? this.url,
      type: type ?? this.type,
    );
  }
}

/// Model representing a team member with their role and contact
class TeamMember {
  final String id;
  final String name;
  final String role; // e.g. 'Team Leader', 'Backend & DB', 'Flutter / Mobile', 'UI/UX Design', 'System Analysis'
  final String phone;

  TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.phone,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'phone': phone,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );

  TeamMember copyWith({String? name, String? role, String? phone}) {
    return TeamMember(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
    );
  }
}

/// Model representing a specific deliverable or task in the project
class ProjectTask {
  final String id;
  final String title;
  final String category; // 'docs', 'dev', 'design', 'review', 'meeting'
  final String assignedTo;
  final String dueDate;
  final bool isCompleted;

  ProjectTask({
    required this.id,
    required this.title,
    required this.category,
    required this.assignedTo,
    required this.dueDate,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'assignedTo': assignedTo,
        'dueDate': dueDate,
        'isCompleted': isCompleted,
      };

  factory ProjectTask.fromJson(Map<String, dynamic> json) => ProjectTask(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        category: json['category'] as String? ?? 'docs',
        assignedTo: json['assignedTo'] as String? ?? '',
        dueDate: json['dueDate'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  ProjectTask copyWith({
    String? title,
    String? category,
    String? assignedTo,
    String? dueDate,
    bool? isCompleted,
  }) {
    return ProjectTask(
      id: id,
      title: title ?? this.title,
      category: category ?? this.category,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Model representing project milestones / supervision checkpoints
class ProjectMilestone {
  final String id;
  final String title;
  final String desc;
  final String date;
  final bool isCompleted;

  ProjectMilestone({
    required this.id,
    required this.title,
    required this.desc,
    required this.date,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'desc': desc,
        'date': date,
        'isCompleted': isCompleted,
      };

  factory ProjectMilestone.fromJson(Map<String, dynamic> json) =>
      ProjectMilestone(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        desc: json['desc'] as String? ?? '',
        date: json['date'] as String? ?? '',
        isCompleted: json['isCompleted'] as bool? ?? false,
      );

  ProjectMilestone copyWith({
    String? title,
    String? desc,
    String? date,
    bool? isCompleted,
  }) {
    return ProjectMilestone(
      id: id,
      title: title ?? this.title,
      desc: desc ?? this.desc,
      date: date ?? this.date,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// Root Project State model
class ProjectWorkspaceData {
  final String projectName;
  final String projectTrack;
  final String doctorSupervisor;
  final String taSupervisor;
  final String meetingDays;
  final List<ProjectLink> links;
  final List<TeamMember> teamMembers;
  final List<ProjectTask> tasks;
  final List<ProjectMilestone> milestones;

  ProjectWorkspaceData({
    required this.projectName,
    required this.projectTrack,
    required this.doctorSupervisor,
    required this.taSupervisor,
    required this.meetingDays,
    required this.links,
    required this.teamMembers,
    required this.tasks,
    required this.milestones,
  });

  double get progressPercentage {
    final totalItems = tasks.length + milestones.length;
    if (totalItems == 0) return 0.0;
    final completedItems =
        tasks.where((t) => t.isCompleted).length +
        milestones.where((m) => m.isCompleted).length;
    return completedItems / totalItems;
  }

  Map<String, dynamic> toJson() => {
        'projectName': projectName,
        'projectTrack': projectTrack,
        'doctorSupervisor': doctorSupervisor,
        'taSupervisor': taSupervisor,
        'meetingDays': meetingDays,
        'links': links.map((e) => e.toJson()).toList(),
        'teamMembers': teamMembers.map((e) => e.toJson()).toList(),
        'tasks': tasks.map((e) => e.toJson()).toList(),
        'milestones': milestones.map((e) => e.toJson()).toList(),
      };

  factory ProjectWorkspaceData.fromJson(Map<String, dynamic> json) =>
      ProjectWorkspaceData(
        projectName: json['projectName'] as String? ?? 'مشروع التخرج',
        projectTrack:
            json['projectTrack'] as String? ?? 'نظم معلومات الأعمال — الفرقة الرابعة',
        doctorSupervisor:
            json['doctorSupervisor'] as String? ?? 'المشرف الأكاديمي',
        taSupervisor:
            json['taSupervisor'] as String? ?? 'المعيد المساعد',
        meetingDays:
            json['meetingDays'] as String? ?? 'الاثنين & الخميس',
        links: (json['links'] as List<dynamic>?)
                ?.map((e) => ProjectLink.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        teamMembers: (json['teamMembers'] as List<dynamic>?)
                ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        tasks: (json['tasks'] as List<dynamic>?)
                ?.map((e) => ProjectTask.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        milestones: (json['milestones'] as List<dynamic>?)
                ?.map(
                    (e) => ProjectMilestone.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  /// Clean initial state ready for user's personal entries
  factory ProjectWorkspaceData.clean() => ProjectWorkspaceData(
        projectName: 'مشروع التخرج (اضغط لتعديل الاسم)',
        projectTrack: 'نظم معلومات الأعمال — الفرقة الرابعة',
        doctorSupervisor: 'المشرف الأكاديمي',
        taSupervisor: 'المعيد المساعد',
        meetingDays: 'الاثنين & الخميس',
        links: [],
        teamMembers: [],
        tasks: [],
        milestones: [
          ProjectMilestone(
            id: 'ms1',
            title: 'اختيار واعتماد فكرة المشروع',
            desc: 'تسجيل الفكرة واعتمادها من القسم',
            date: 'أكتوبر 2026',
            isCompleted: false,
          ),
          ProjectMilestone(
            id: 'ms2',
            title: 'تسليم مقترح المشروع (Proposal)',
            desc: 'تقديم البروبوزال والجدول الزمني للعمل',
            date: 'نوفمبر 2026',
            isCompleted: false,
          ),
          ProjectMilestone(
            id: 'ms3',
            title: 'توثيق النظام وتصميم الواجهات (Ch. 1 & 2)',
            desc: 'تحليل المتطلبات، المخططات، وتصميم UI/UX',
            date: 'ديسمبر 2026',
            isCompleted: false,
          ),
          ProjectMilestone(
            id: 'ms4',
            title: 'المناقشة النصفية (Midterm Review)',
            desc: 'عرض النموذج الأولي للبروجكت',
            date: 'يناير 2027',
            isCompleted: false,
          ),
          ProjectMilestone(
            id: 'ms5',
            title: 'التسليم النهائي والمناقشة وحفل التخرج 🎓',
            desc: 'تسليم المشروع الكامل وكتاب التوثيق والمناقشة',
            date: 'مايو 2027',
            isCompleted: false,
          ),
        ],
      );

  ProjectWorkspaceData copyWith({
    String? projectName,
    String? projectTrack,
    String? doctorSupervisor,
    String? taSupervisor,
    String? meetingDays,
    List<ProjectLink>? links,
    List<TeamMember>? teamMembers,
    List<ProjectTask>? tasks,
    List<ProjectMilestone>? milestones,
  }) {
    return ProjectWorkspaceData(
      projectName: projectName ?? this.projectName,
      projectTrack: projectTrack ?? this.projectTrack,
      doctorSupervisor: doctorSupervisor ?? this.doctorSupervisor,
      taSupervisor: taSupervisor ?? this.taSupervisor,
      meetingDays: meetingDays ?? this.meetingDays,
      links: links ?? this.links,
      teamMembers: teamMembers ?? this.teamMembers,
      tasks: tasks ?? this.tasks,
      milestones: milestones ?? this.milestones,
    );
  }
}

/// Storage service for saving and loading project workspace state
class ProjectWorkspaceStorage {
  static const _key = 'gp_workspace_user_data_v2';

  static Future<ProjectWorkspaceData> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null && raw.isNotEmpty) {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        return ProjectWorkspaceData.fromJson(map);
      }
    } catch (_) {}
    return ProjectWorkspaceData.clean();
  }

  static Future<void> save(ProjectWorkspaceData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(data.toJson());
      await prefs.setString(_key, raw);
    } catch (_) {}
  }

  static Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (_) {}
  }
}
