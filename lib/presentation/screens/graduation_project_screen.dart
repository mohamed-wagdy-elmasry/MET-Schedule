/// Graduation Project Hub & Workspace — Fully interactive team, tasks, links, and milestones manager.
/// Features smooth nested scrolling where the header scrolls away and spacious input sheets.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/project_workspace_service.dart';

class GraduationProjectScreen extends StatefulWidget {
  const GraduationProjectScreen({super.key});

  @override
  State<GraduationProjectScreen> createState() =>
      _GraduationProjectScreenState();
}

class _GraduationProjectScreenState extends State<GraduationProjectScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProjectWorkspaceData _data = ProjectWorkspaceData.clean();
  bool _isLoading = true;
  String _taskFilter = 'all'; // 'all', 'pending', 'completed'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final loaded = await ProjectWorkspaceStorage.load();
    if (mounted) {
      setState(() {
        _data = loaded;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveData() async {
    await ProjectWorkspaceStorage.save(_data);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _openUrl(String url) async {
    if (url.trim().isEmpty) return;
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') &&
        !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.parse(formattedUrl);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        final loc = AppLocalizations.of(context);
        _copyToClipboard(formattedUrl, loc.isArabic ? 'تم نسخ الرابط' : 'Link copied');
      }
    } catch (_) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        _copyToClipboard(formattedUrl, loc.isArabic ? 'تم نسخ الرابط' : 'Link copied');
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String memberName) async {
    if (phone.trim().isEmpty) return;
    String cleanNumber = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanNumber.startsWith('01')) {
      cleanNumber = '2$cleanNumber'; // Egypt country code
    }
    final loc = AppLocalizations.of(context);
    final msgText = loc.isArabic
        ? 'السلام عليكم يا $memberName، بخصوص مشروع التخرج:'
        : 'Hello $memberName, regarding the graduation project:';
    final message = Uri.encodeComponent(msgText);
    final url = 'https://wa.me/$cleanNumber?text=$message';
    final uri = Uri.parse(url);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        _copyToClipboard(phone, loc.isArabic ? 'تم نسخ رقم الهاتف' : 'Phone number copied');
      }
    } catch (_) {
      if (mounted) {
        _copyToClipboard(phone, loc.isArabic ? 'تم نسخ رقم الهاتف' : 'Phone number copied');
      }
    }
  }

  void _copyToClipboard(String text, String successMsg) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(successMsg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Project Header Card ──
  Widget _buildProjectHeader(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final loc = AppLocalizations.of(context);
    final progress = _data.progressPercentage;
    final progressPercent = (progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF312E81),
                  const Color(0xFF1E293B),
                ]
              : [
                  const Color(0xFF4338CA),
                  const Color(0xFF6366F1),
                  const Color(0xFF4F46E5),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5)
                .withValues(alpha: isDark ? 0.35 : 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -25,
            top: -25,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showEditProjectSheet(context),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD166)
                                    .withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFFFD166)
                                      .withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                _data.displayProjectTrack(loc.isArabic),
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFE082),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _data.displayProjectName(loc.isArabic),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded,
                          color: Colors.white, size: 26),
                      tooltip:
                          loc.isArabic ? 'تعديل بيانات المشروع' : 'Edit Project',
                      onPressed: () => _showEditProjectSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildInfoBadge(
                      icon: Icons.person_rounded,
                      text: _data.displayDoctor(loc.isArabic),
                    ),
                    _buildInfoBadge(
                      icon: Icons.co_present_rounded,
                      text: _data.displayTa(loc.isArabic),
                    ),
                    _buildInfoBadge(
                      icon: Icons.calendar_month_rounded,
                      text: _data.displayMeetingDays(loc.isArabic),
                      color: const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          loc.isArabic
                              ? 'نسبة إنجاز المشروع'
                              : 'Project Progress',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          '$progressPercent%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD166),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.white.withValues(alpha: 0.18),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFFD166),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge({
    required IconData icon,
    required String text,
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (color ?? Colors.white).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (color ?? Colors.white).withValues(alpha: 0.25),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color ?? Colors.white),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1: Links & Vault ──
  Widget _buildLinksTab(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                loc.isArabic
                    ? '📁 روابط ومستندات المشروع'
                    : '📁 Project Vault & Links',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _showAddLinkSheet(context),
              icon: const Icon(Icons.add_link_rounded, size: 18),
              label: Text(loc.isArabic ? 'إضافة رابط' : 'Add Link'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_data.links.isEmpty)
          _buildEmptyState(
            icon: Icons.link_off_rounded,
            title: loc.isArabic ? 'لا توجد روابط مضافة' : 'No links added',
            subtitle: loc.isArabic
                ? 'أضف روابط الـ Google Drive, Figma, GitHub هنا للوصول السريع'
                : 'Add your Google Drive, Figma or GitHub links here',
            buttonLabel: loc.isArabic ? 'إضافة أول رابط' : 'Add First Link',
            onAction: () => _showAddLinkSheet(context),
          )
        else
          Column(
            children: List.generate(_data.links.length, (index) {
              final link = _data.links[index];
              final iconData = _getLinkIcon(link.type);
              final iconColor = _getLinkColor(link.type);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            link.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            link.url,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.getTextHint(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new_rounded, size: 20),
                      color: AppTheme.primary,
                      tooltip: loc.isArabic ? 'فتح الرابط' : 'Open Link',
                      onPressed: () => _openUrl(link.url),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded,
                          size: 20, color: AppTheme.getTextHint(context)),
                      onSelected: (val) {
                        if (val == 'copy') {
                          _copyToClipboard(link.url, loc.isArabic ? 'تم نسخ الرابط' : 'Link copied');
                        } else if (val == 'delete') {
                          setState(() {
                            _data.links.removeAt(index);
                          });
                          _saveData();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              const Icon(Icons.copy_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(loc.isArabic ? 'نسخ الرابط' : 'Copy'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                loc.isArabic ? 'حذف' : 'Delete',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  IconData _getLinkIcon(String type) {
    switch (type.toLowerCase()) {
      case 'drive':
        return Icons.add_to_drive_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'figma':
        return Icons.design_services_rounded;
      case 'slides':
        return Icons.slideshow_rounded;
      case 'docs':
        return Icons.description_rounded;
      default:
        return Icons.link_rounded;
    }
  }

  Color _getLinkColor(String type) {
    switch (type.toLowerCase()) {
      case 'drive':
        return const Color(0xFF0F9D58);
      case 'github':
        return const Color(0xFF8B5CF6);
      case 'figma':
        return const Color(0xFFF24E1E);
      case 'slides':
        return const Color(0xFFF4B400);
      case 'docs':
        return const Color(0xFF4285F4);
      default:
        return AppTheme.primary;
    }
  }

  // ── Tab 2: Team Members ──
  Widget _buildTeamTab(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                loc.isArabic
                    ? '👥 فريق العمل وتوزيع الأدوار'
                    : '👥 Team Members & Roles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _showAddMemberSheet(context),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: Text(loc.isArabic ? 'إضافة عضو' : 'Add Member'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_data.teamMembers.isEmpty)
          _buildEmptyState(
            icon: Icons.group_off_rounded,
            title:
                loc.isArabic ? 'لم يتم إضافة أعضاء بعد' : 'No team members',
            subtitle: loc.isArabic
                ? 'أضف زملاء فريق التخرج لتسهيل التواصل وتوزيع المهام'
                : 'Add your team members to coordinate tasks and roles',
            buttonLabel: loc.isArabic ? 'إضافة أول زميل' : 'Add First Member',
            onAction: () => _showAddMemberSheet(context),
          )
        else
          Column(
            children: List.generate(_data.teamMembers.length, (index) {
              final member = _data.teamMembers[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor:
                          AppTheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        member.name.isNotEmpty
                            ? member.name.characters.first
                            : '👤',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.getTextPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(
                                  alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              member.role,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (member.phone.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.chat_rounded,
                            color: Color(0xFF25D366), size: 24),
                        tooltip:
                            loc.isArabic ? 'محادثة واتساب' : 'WhatsApp Chat',
                        onPressed: () =>
                            _openWhatsApp(member.phone, member.name),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded,
                          size: 20, color: AppTheme.getTextHint(context)),
                      onSelected: (val) {
                        if (val == 'edit') {
                          _showEditMemberSheet(context, index);
                        } else if (val == 'delete') {
                          setState(() {
                            _data.teamMembers.removeAt(index);
                          });
                          _saveData();
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_rounded, size: 18),
                              const SizedBox(width: 8),
                              Text(loc.isArabic ? 'تعديل' : 'Edit'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded,
                                  size: 18, color: Colors.red),
                              const SizedBox(width: 8),
                              Text(
                                loc.isArabic ? 'حذف' : 'Delete',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Tab 3: Tasks & Sprints ──
  Widget _buildTasksTab(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    final filteredTasks = _data.tasks.where((t) {
      if (_taskFilter == 'completed') return t.isCompleted;
      if (_taskFilter == 'pending') return !t.isCompleted;
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                loc.isArabic
                    ? '📋 قائمة المهام والتسليمات'
                    : '📋 Tasks & Sprints',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _showAddTaskSheet(context),
              icon: const Icon(Icons.add_task_rounded, size: 18),
              label: Text(loc.isArabic ? 'مهمة جديدة' : 'Add Task'),
              style: FilledButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Filters Chip Row
        Row(
          children: [
            _buildFilterChip(
              label: loc.isArabic
                  ? 'الكل (${_data.tasks.length})'
                  : 'All (${_data.tasks.length})',
              value: 'all',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: loc.isArabic
                  ? 'قيد التنفيذ (${_data.tasks.where((t) => !t.isCompleted).length})'
                  : 'Pending (${_data.tasks.where((t) => !t.isCompleted).length})',
              value: 'pending',
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: loc.isArabic
                  ? 'تم الإنجاز (${_data.tasks.where((t) => t.isCompleted).length})'
                  : 'Done (${_data.tasks.where((t) => t.isCompleted).length})',
              value: 'completed',
            ),
          ],
        ),

        const SizedBox(height: 12),

        if (filteredTasks.isEmpty)
          _buildEmptyState(
            icon: Icons.checklist_rounded,
            title: loc.isArabic ? 'لا توجد مهام حالياً' : 'No tasks',
            subtitle: loc.isArabic
                ? 'أضف مهام المشروع ووزعها على أفراد الفريق'
                : 'Add project tasks and assign them to your team',
            buttonLabel: loc.isArabic ? 'إضافة أول مهمة' : 'Add First Task',
            onAction: () => _showAddTaskSheet(context),
          )
        else
          Column(
            children: List.generate(filteredTasks.length, (index) {
              final task = filteredTasks[index];
              final catColor = _getCategoryColor(task.category);

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: task.isCompleted
                        ? AppTheme.success.withValues(alpha: 0.3)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.07)
                            : const Color(0xFFE2E8F0)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      activeColor: AppTheme.success,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      onChanged: (val) {
                        setState(() {
                          final origIdx = _data.tasks.indexOf(task);
                          if (origIdx != -1) {
                            _data.tasks[origIdx] = task.copyWith(
                              isCompleted: val ?? false,
                            );
                          }
                        });
                        _saveData();
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.isCompleted
                                  ? AppTheme.getTextHint(context)
                                  : AppTheme.getTextPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: catColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _getCategoryLabel(
                                      task.category, loc.isArabic),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: catColor,
                                  ),
                                ),
                              ),
                              if (task.assignedTo.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.person_outline_rounded,
                                        size: 12,
                                        color: AppTheme.getTextHint(context)),
                                    const SizedBox(width: 3),
                                    Text(
                                      task.assignedTo,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppTheme.getTextSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                              if (task.dueDate.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.event_outlined,
                                        size: 12,
                                        color: AppTheme.getTextHint(context)),
                                    const SizedBox(width: 3),
                                    Text(
                                      task.dueDate,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color:
                                            AppTheme.getTextSecondary(context),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 18, color: Colors.redAccent),
                      onPressed: () {
                        setState(() {
                          _data.tasks.remove(task);
                        });
                        _saveData();
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip({required String label, required String value}) {
    final isSelected = _taskFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _taskFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'docs':
        return const Color(0xFF3B82F6);
      case 'dev':
        return const Color(0xFF8B5CF6);
      case 'design':
        return const Color(0xFFEC4899);
      case 'review':
        return const Color(0xFFF59E0B);
      case 'meeting':
        return const Color(0xFF10B981);
      default:
        return AppTheme.primary;
    }
  }

  String _getCategoryLabel(String category, bool isArabic) {
    switch (category) {
      case 'docs':
        return isArabic ? '📝 توثيق' : '📝 Docs';
      case 'dev':
        return isArabic ? '💻 برمجة' : '💻 Dev';
      case 'design':
        return isArabic ? '🎨 تصميم' : '🎨 Design';
      case 'review':
        return isArabic ? '🔍 مراجعة' : '🔍 Review';
      case 'meeting':
        return isArabic ? '🤝 اجتماع' : '🤝 Meeting';
      default:
        return category;
    }
  }

  // ── Tab 4: Milestones Timeline ──
  Widget _buildMilestonesTab(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.isArabic
                  ? '🚩 محطات ومواعيد التسليم الرسمية'
                  : '🚩 Milestones & Defense Timeline',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          children: List.generate(_data.milestones.length, (index) {
            final ms = _data.milestones[index];
            final isLast = index == _data.milestones.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 32,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _data.milestones[index] = ms.copyWith(
                                isCompleted: !ms.isCompleted,
                              );
                            });
                            _saveData();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ms.isCompleted
                                  ? AppTheme.success
                                  : (isDark
                                      ? AppTheme.bgCardLight
                                      : const Color(0xFFE2E8F0)),
                              border: Border.all(
                                color: ms.isCompleted
                                    ? AppTheme.success
                                    : const Color(0xFF94A3B8),
                                width: 2,
                              ),
                            ),
                            child: ms.isCompleted
                                ? const Icon(Icons.check,
                                    size: 13, color: Colors.white)
                                : null,
                          ),
                        ),
                        if (!isLast)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: ms.isCompleted
                                  ? AppTheme.success.withValues(alpha: 0.4)
                                  : const Color(0xFF94A3B8)
                                      .withValues(alpha: 0.25),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _data.milestones[index] = ms.copyWith(
                            isCompleted: !ms.isCompleted,
                          );
                        });
                        _saveData();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.bgCard : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: ms.isCompleted
                                ? AppTheme.success.withValues(alpha: 0.35)
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.07)
                                    : const Color(0xFFE2E8F0)),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: isDark ? 0.2 : 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _data.milestoneTitle(ms, loc.isArabic),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: ms.isCompleted
                                          ? (isDark
                                              ? AppTheme.success
                                              : const Color(0xFF059669))
                                          : AppTheme.getTextPrimary(context),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.08)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _data.milestoneDate(ms, loc.isArabic),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getTextHint(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _data.milestoneDesc(ms, loc.isArabic),
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getTextSecondary(context),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? buttonLabel,
    VoidCallback? onAction,
  }) {
    final isDark = AppTheme.isDark(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.bgCard.withValues(alpha: 0.5)
            : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.getTextHint(context)),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.getTextPrimary(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.getTextHint(context),
            ),
          ),
          if (buttonLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(buttonLabel),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Spacious Modal Bottom Sheets for smooth editing ──

  void _showEditProjectSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final nameCtrl = TextEditingController(text: _data.projectName);
    final trackCtrl = TextEditingController(text: _data.projectTrack);
    final docCtrl = TextEditingController(text: _data.doctorSupervisor);
    final taCtrl = TextEditingController(text: _data.taSupervisor);
    final meetCtrl = TextEditingController(text: _data.meetingDays);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getTextHint(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.isArabic
                    ? '✏️ تعديل بيانات مشروع التخرج'
                    : '✏️ Edit Project Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic
                      ? 'اسم فكرة المشروع'
                      : 'Project Title',
                  hintText: loc.isArabic
                      ? 'مثال: نظام إدارة سلاسل الإمداد BIS'
                      : 'e.g. ERP System',
                  prefixIcon: const Icon(Icons.rocket_launch_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: trackCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText:
                      loc.isArabic ? 'المسار / التخصص' : 'Track / Major',
                  prefixIcon: const Icon(Icons.school_rounded),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: docCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: loc.isArabic
                            ? 'اسم الدكتور المشرف'
                            : 'Doctor',
                        prefixIcon: const Icon(Icons.person_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: taCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: loc.isArabic
                            ? 'اسم المعيد'
                            : 'TA',
                        prefixIcon: const Icon(Icons.co_present_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: meetCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic
                      ? 'أيام ومواعيد المتابعة'
                      : 'Meeting Schedule',
                  prefixIcon: const Icon(Icons.calendar_month_rounded),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _data = _data.copyWith(
                          projectName: nameCtrl.text.trim(),
                          projectTrack: trackCtrl.text.trim(),
                          doctorSupervisor: docCtrl.text.trim(),
                          taSupervisor: taCtrl.text.trim(),
                          meetingDays: meetCtrl.text.trim(),
                        );
                      });
                      _saveData();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    loc.save,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLinkSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titleCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    String type = 'drive';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getTextHint(context)
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.isArabic
                      ? '🔗 إضافة رابط جديد للمشروع'
                      : '🔗 Add Project Resource',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: loc.isArabic
                        ? 'عنوان الرابط (مثلاً: مجلد الـ Google Drive)'
                        : 'Title',
                    prefixIcon: const Icon(Icons.title_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: urlCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    labelText: 'URL (drive.google.com, figma, ...)',
                    prefixIcon: Icon(Icons.link_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: InputDecoration(
                    labelText: loc.isArabic ? 'نوع الرابط' : 'Link Type',
                  ),
                  items: [
                    const DropdownMenuItem(
                        value: 'drive',
                        child: Text('📁 Google Drive / Docs')),
                    const DropdownMenuItem(
                        value: 'figma', child: Text('🎨 Figma UI/UX')),
                    const DropdownMenuItem(
                        value: 'github', child: Text('💻 GitHub / Git')),
                    const DropdownMenuItem(
                        value: 'slides',
                        child: Text('📊 Presentation / Slides')),
                    const DropdownMenuItem(
                        value: 'docs', child: Text('📝 Documentation')),
                    DropdownMenuItem(
                        value: 'other', child: Text(loc.isArabic ? '🔗 عام / أخرى' : '🔗 Other')),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheetState(() => type = val);
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty &&
                          urlCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          _data.links.add(ProjectLink(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: titleCtrl.text.trim(),
                            url: urlCtrl.text.trim(),
                            type: type,
                          ));
                        });
                        _saveData();
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(
                      loc.save,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getTextHint(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.isArabic
                    ? '👥 إضافة عضو في فريق المشروع'
                    : '👥 Add Team Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic ? 'اسم الزميل' : 'Member Name',
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: roleCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic
                      ? 'الدور / التخصص (Flutter, Backend, Docs, Leader...)'
                      : 'Role / Specialty',
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic
                      ? 'رقم الهاتف (للتواصل المباشر عبر الواتساب)'
                      : 'Phone (WhatsApp)',
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _data.teamMembers.add(TeamMember(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          name: nameCtrl.text.trim(),
                          role: roleCtrl.text.trim().isEmpty
                              ? (loc.isArabic ? 'عضو فريق' : 'Team Member')
                              : roleCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                        ));
                      });
                      _saveData();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    loc.save,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditMemberSheet(BuildContext context, int index) {
    final loc = AppLocalizations.of(context);
    final member = _data.teamMembers[index];
    final nameCtrl = TextEditingController(text: member.name);
    final roleCtrl = TextEditingController(text: member.role);
    final phoneCtrl = TextEditingController(text: member.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getTextHint(context).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.isArabic
                    ? '✏️ تعديل بيانات العضو'
                    : '✏️ Edit Member',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.getTextPrimary(context),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic ? 'الاسم' : 'Name',
                  prefixIcon: const Icon(Icons.person_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: roleCtrl,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic ? 'الدور' : 'Role',
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  labelText: loc.isArabic ? 'رقم الهاتف' : 'Phone',
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      setState(() {
                        _data.teamMembers[index] = member.copyWith(
                          name: nameCtrl.text.trim(),
                          role: roleCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                        );
                      });
                      _saveData();
                      Navigator.pop(ctx);
                    }
                  },
                  child: Text(
                    loc.save,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final titleCtrl = TextEditingController();
    final assignCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    String category = 'dev';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getCardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.getTextHint(context)
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.isArabic
                      ? '📋 إضافة مهمة جديدة'
                      : '📋 Add New Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: titleCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: loc.isArabic ? 'عنوان المهمة' : 'Task Title',
                    prefixIcon: const Icon(Icons.task_alt_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  decoration: InputDecoration(
                    labelText: loc.isArabic ? 'التصنيف' : 'Category',
                  ),
                  items: [
                    DropdownMenuItem(
                        value: 'dev',
                        child: Text(loc.isArabic
                            ? '💻 برمجة وتطوير'
                            : '💻 Development')),
                    DropdownMenuItem(
                        value: 'docs',
                        child: Text(loc.isArabic
                            ? '📝 توثيق وكتابة'
                            : '📝 Documentation')),
                    DropdownMenuItem(
                        value: 'design',
                        child: Text(loc.isArabic
                            ? '🎨 تصميم واجهات'
                            : '🎨 Design')),
                    DropdownMenuItem(
                        value: 'review',
                        child: Text(loc.isArabic
                            ? '🔍 مراجعة واختبار'
                            : '🔍 Review')),
                    DropdownMenuItem(
                        value: 'meeting',
                        child: Text(loc.isArabic
                            ? '🤝 اجتماع ومناقشة'
                            : '🤝 Meeting')),
                  ],
                  onChanged: (val) {
                    if (val != null) setSheetState(() => category = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: assignCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText:
                        loc.isArabic ? 'المسؤول عنها' : 'Assigned To',
                    prefixIcon: const Icon(Icons.person_outline_rounded),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: dateCtrl,
                  style: const TextStyle(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: loc.isArabic
                        ? 'تاريخ التسليم (مثلاً: 25 ديسمبر)'
                        : 'Due Date',
                    prefixIcon: const Icon(Icons.event_outlined),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.trim().isNotEmpty) {
                        setState(() {
                          _data.tasks.add(ProjectTask(
                            id: DateTime.now()
                                .millisecondsSinceEpoch
                                .toString(),
                            title: titleCtrl.text.trim(),
                            category: category,
                            assignedTo: assignCtrl.text.trim(),
                            dueDate: dateCtrl.text.trim(),
                            isCompleted: false,
                          ));
                        });
                        _saveData();
                        Navigator.pop(ctx);
                      }
                    },
                    child: Text(
                      loc.save,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Project Card (Scrolls with page)
          SliverToBoxAdapter(
            child: _buildProjectHeader(context),
          ),

          // Pinned Sticky TabBar
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              child: Container(
                color: isDark ? AppTheme.bgDark : const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.bgCard.withValues(alpha: 0.8)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: false,
                    dividerColor: Colors.transparent,
                    dividerHeight: 0,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.getTextHint(context),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: isDark
                          ? AppTheme.primary.withValues(alpha: 0.20)
                          : AppTheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: isDark ? 0.35 : 0.25),
                        width: 1,
                      ),
                    ),
                    labelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: [
                      Tab(
                        height: 50,
                        icon: const Icon(Icons.link_rounded, size: 20),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                        text: loc.isArabic ? 'الروابط' : 'Links',
                      ),
                      Tab(
                        height: 50,
                        icon: const Icon(Icons.group_rounded, size: 20),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                        text: loc.isArabic ? 'الفريق' : 'Team',
                      ),
                      Tab(
                        height: 50,
                        icon: const Icon(Icons.checklist_rounded, size: 20),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                        text: loc.isArabic ? 'المهام' : 'Tasks',
                      ),
                      Tab(
                        height: 50,
                        icon: const Icon(Icons.flag_rounded, size: 20),
                        iconMargin: const EdgeInsets.only(bottom: 2),
                        text: loc.isArabic ? 'المراحل' : 'Timeline',
                      ),
                    ],
                  ),
                ),
              ),
              height: 60,
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLinksTab(context),
          _buildTeamTab(context),
          _buildTasksTab(context),
          _buildMilestonesTab(context),
        ],
      ),
    );
  }
}

/// Custom delegate for sticky pinned TabBar
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverTabBarDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}
