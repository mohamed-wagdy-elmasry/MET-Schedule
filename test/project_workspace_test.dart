import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:met1/data/datasources/project_workspace_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProjectWorkspaceData & Storage Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Default project data has valid initial structure', () {
      final data = ProjectWorkspaceData.clean();
      expect(data.projectName, isNotEmpty);
      expect(data.teamMembers, isEmpty);
      expect(data.tasks, isEmpty);
      expect(data.links, isEmpty);
      expect(data.milestones, isNotEmpty);
      expect(data.progressPercentage, greaterThanOrEqualTo(0.0));
      expect(data.progressPercentage, lessThanOrEqualTo(1.0));
    });

    test('Json serialization and deserialization works correctly', () {
      final data = ProjectWorkspaceData.clean();
      final json = data.toJson();
      final fromJson = ProjectWorkspaceData.fromJson(json);

      expect(fromJson.projectName, equals(data.projectName));
      expect(fromJson.doctorSupervisor, equals(data.doctorSupervisor));
      expect(fromJson.teamMembers.length, equals(data.teamMembers.length));
      expect(fromJson.tasks.length, equals(data.tasks.length));
      expect(fromJson.links.length, equals(data.links.length));
      expect(fromJson.milestones.length, equals(data.milestones.length));
    });

    test('Save and load from storage works with persistence', () async {
      var data = await ProjectWorkspaceStorage.load();
      expect(data.projectName, equals(ProjectWorkspaceData.clean().projectName));

      data = data.copyWith(projectName: 'New AI ERP System');
      await ProjectWorkspaceStorage.save(data);

      final reloaded = await ProjectWorkspaceStorage.load();
      expect(reloaded.projectName, equals('New AI ERP System'));
    });

    test('Progress percentage updates when tasks are completed', () {
      final task1 = ProjectTask(
        id: '1',
        title: 'Task 1',
        category: 'dev',
        assignedTo: 'Me',
        dueDate: 'Tomorrow',
        isCompleted: false,
      );
      final task2 = ProjectTask(
        id: '2',
        title: 'Task 2',
        category: 'docs',
        assignedTo: 'Me',
        dueDate: 'Tomorrow',
        isCompleted: true,
      );

      final data = ProjectWorkspaceData(
        projectName: 'Test',
        projectTrack: 'Track',
        doctorSupervisor: 'Doc',
        taSupervisor: 'TA',
        meetingDays: 'Mon',
        links: [],
        teamMembers: [],
        tasks: [task1, task2],
        milestones: [],
      );

      expect(data.progressPercentage, equals(0.5));
    });
  });
}
