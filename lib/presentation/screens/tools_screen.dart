/// Tools screen — Campus Directory + Friday Hub + Attendance Tracker.
/// Fully adapts to both Dark and Light modes.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/datasources/local_schedule_datasource.dart';
import '../bloc/preferences_cubit.dart';
import '../widgets/friday_hub_widget.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              loc.tools,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.getTextPrimary(context),
              ),
            ),
          ),
        ),

        // ── Campus Directory Card ──
        SliverToBoxAdapter(
          child: _ToolCard(
            icon: Icons.map_rounded,
            title: loc.campusDirectory,
            subtitle: loc.isArabic
                ? 'الخرائط الرسمية، شرح المباني، وأكواد القاعات والمعامل'
                : loc.campusDirectoryDesc,
            color: AppTheme.info,
            badge: loc.isArabic ? 'صور رسمية 🗺️' : 'Official Maps',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _CampusDirectoryPage()),
            ),
          ),
        ),

        // ── Attendance Tracker Card ──
        SliverToBoxAdapter(
          child: _ToolCard(
            icon: Icons.check_circle_outline_rounded,
            title: loc.attendanceTracker,
            subtitle: loc.isArabic
                ? 'تتبع حضورك وغيابك للمحاضرات والسكاشن والمعامل'
                : 'Track your attendance for lectures and sections/labs',
            color: AppTheme.success,
            badge: loc.isArabic ? 'محاضرات وسكاشن' : 'Lectures & Labs',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _AttendanceTrackerPage()),
            ),
          ),
        ),

        // ── University Portals & Student Links Card ──
        SliverToBoxAdapter(
          child: _ToolCard(
            icon: Icons.language_rounded,
            title: loc.isArabic ? 'بوابات ومنصات المعهد 🌐' : 'University & Student Portals 🌐',
            subtitle: loc.isArabic
                ? 'المنصة التعليمية، منصة الكويزات، ونظام ابن الهيثم'
                : 'Educational Portal, Exams & Ibn Al-Haytham',
            color: const Color(0xFF3B82F6),
            badge: loc.isArabic ? 'روابط مباشرة 🔗' : 'Direct Links',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const _UniversityPortalsPage()),
            ),
          ),
        ),

        // ── Friday Azkar & Sunan Card ──
        SliverToBoxAdapter(
          child: _ToolCard(
            icon: Icons.spa_rounded,
            title: loc.isArabic ? 'سنن وأذكار يوم الجمعة 🌸' : 'Friday Sunan & Azkar 🌸',
            subtitle: loc.isArabic
                ? 'عداد الصلاة على النبي، سورة الكهف، والأدعية'
                : 'Salawat counter, Surah Al-Kahf & Duas',
            color: const Color(0xFF00B894),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(
                    title: Text(loc.isArabic ? 'سنن وأذكار يوم الجمعة' : 'Friday Hub'),
                  ),
                  body: const SingleChildScrollView(
                    padding: EdgeInsets.only(top: 12),
                    child: FridayHubWidget(
                      upcomingSaturdayEntries: [],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glassDecorationWithColor(color, context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getTextPrimary(context),
                          ),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
                          ),
                          child: Text(
                            badge!,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Campus Directory Page (Interactive with Official Images)
// ═══════════════════════════════════════════

class _CampusDirectoryPage extends StatefulWidget {
  const _CampusDirectoryPage();

  @override
  State<_CampusDirectoryPage> createState() => _CampusDirectoryPageState();
}

class _CampusDirectoryPageState extends State<_CampusDirectoryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _directory = [];
  bool _loading = true;
  String _searchQuery = '';
  String _selectedFilter = 'all'; // 'all', 'hall', 'room', 'lab'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await LocalScheduleDataSource().loadCampusDirectory();
    setState(() {
      _directory = data;
      _loading = false;
    });
  }

  void _openImageViewer(String imagePath, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenImageViewer(imagePath: imagePath, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);


    return Scaffold(
      appBar: AppBar(
        title: Text(loc.campusDirectory),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.getTextHint(context),
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.photo_library_rounded, size: 20),
              text: loc.isArabic ? 'الخرائط الرسمية' : 'Official Maps',
            ),
            Tab(
              icon: const Icon(Icons.search_rounded, size: 20),
              text: loc.isArabic ? 'دليل الأماكن' : 'Directory',
            ),
            Tab(
              icon: const Icon(Icons.lightbulb_outline_rounded, size: 20),
              text: loc.isArabic ? 'شرح الأكواد' : 'Code Key',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Official Photos & Maps
          _buildMapsTab(context),

          // Tab 2: Searchable Directory
          _buildDirectoryTab(context),

          // Tab 3: Code Decoding Key
          _buildCodeKeyTab(context),
        ],
      ),
    );
  }

  // ── Tab 1: Official Maps & Guide Images ──
  Widget _buildMapsTab(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Helper Note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.touch_app_rounded, color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  loc.isArabic
                      ? 'اضغط على أي صورة لتكبيرها والشاشات الكاملة والتكبير بلمستين 🔍'
                      : 'Tap any image to view in full screen with pinch-to-zoom 🔍',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFD6E4FF) : const Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Image Card 1: Campus Buildings Map (A, B, C, D, E)
        _buildImageCard(
          title: loc.isArabic
              ? '🏢 خريطة وتوزيع مباني المعهد والأدوار (A, B, C, D, E)'
              : '🏢 Campus Buildings & Floors Map (A, B, C, D, E)',
          subtitle: loc.isArabic
              ? 'توزيع الإدارة والمدرجات والمعامل في المباني A, B, C, D, E'
              : 'Full floor breakdown for buildings A, B, C, D, E',
          imageAsset: 'assets/images/campus_buildings_map.jpg',
          context: context,
        ),

        const SizedBox(height: 20),

        // Image Card 2: Halls, Labs & Classrooms Guide
        _buildImageCard(
          title: loc.isArabic
              ? '📋 جدول توزيع الأماكن التعليمية للطلاب'
              : '📋 Classrooms, Halls & Labs Educational Guide',
          subtitle: loc.isArabic
              ? 'أماكن مدرجات المحاضرات، قاعات السكاشن، ومعامل السكاشن العملي'
              : 'Lecture halls, section rooms and computer lab locations',
          imageAsset: 'assets/images/campus_halls_guide.jpg',
          context: context,
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildImageCard({
    required String title,
    required String subtitle,
    required String imageAsset,
    required BuildContext context,
  }) {
    final isDark = AppTheme.isDark(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with overlay button
            GestureDetector(
              onTap: () => _openImageViewer(imageAsset, title),
              child: Stack(
                children: [
                  Hero(
                    tag: imageAsset,
                    child: Image.asset(
                      imageAsset,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'تكبير وعرض كامل',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.getTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.getTextSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Searchable Directory ──
  Widget _buildDirectoryTab(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _directory.where((item) {
      final nameAr = (item['name_ar'] as String? ?? '').toLowerCase();
      final nameEn = (item['name_en'] as String? ?? '').toLowerCase();
      final buildingAr = (item['building_ar'] as String? ?? '').toLowerCase();
      final type = (item['type'] as String? ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase().trim();

      final matchesQuery = q.isEmpty ||
          nameAr.contains(q) ||
          nameEn.contains(q) ||
          buildingAr.contains(q);

      final matchesType = _selectedFilter == 'all' || type == _selectedFilter;

      return matchesQuery && matchesType;
    }).toList();

    return Column(
      children: [
        // Search & Filters Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: isDark ? AppTheme.bgCard.withValues(alpha: 0.5) : const Color(0xFFF8FAFC),
          child: Column(
            children: [
              TextField(
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: loc.isArabic ? 'ابحث عن قاعة، معمل، أو مدرج...' : 'Search hall, lab or room...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () => setState(() => _searchQuery = ''),
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppTheme.bgCard : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterPill(label: loc.isArabic ? 'الكل' : 'All', value: 'all'),
                    const SizedBox(width: 8),
                    _buildFilterPill(label: loc.isArabic ? '🏛️ المدرجات' : 'Halls', value: 'hall'),
                    const SizedBox(width: 8),
                    _buildFilterPill(label: loc.isArabic ? '💻 المعامل' : 'Labs', value: 'lab'),
                    const SizedBox(width: 8),
                    _buildFilterPill(label: loc.isArabic ? '🚪 قاعات السكاشن' : 'Rooms', value: 'room'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off_rounded, size: 48, color: AppTheme.getTextHint(context)),
                      const SizedBox(height: 8),
                      Text(
                        loc.isArabic ? 'لا توجد نتائج مطابقة' : 'No matching locations found',
                        style: TextStyle(color: AppTheme.getTextHint(context)),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final name = isArabic
                        ? item['name_ar'] as String? ?? ''
                        : item['name_en'] as String? ?? '';
                    final floor = isArabic
                        ? item['floor_ar'] as String? ?? ''
                        : item['floor_en'] as String? ?? '';
                    final building = isArabic
                        ? item['building_ar'] as String? ?? ''
                        : item['building_en'] as String? ?? '';
                    final type = item['type'] as String? ?? 'room';

                    IconData icon;
                    Color color;
                    if (type == 'lab') {
                      icon = Icons.computer_rounded;
                      color = isDark ? AppTheme.labColor : AppTheme.labColorLight;
                    } else if (type == 'hall') {
                      icon = Icons.meeting_room_rounded;
                      color = isDark ? AppTheme.lectureColor : AppTheme.lectureColorLight;
                    } else {
                      icon = Icons.room_rounded;
                      color = isDark ? AppTheme.sectionColor : AppTheme.sectionColorLight;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                      padding: const EdgeInsets.all(14),
                      decoration: AppTheme.glassDecorationWithColor(color, context),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(icon, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  building,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.getTextSecondary(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              floor,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.getTextHint(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterPill({required String label, required String value}) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppTheme.primary,
          ),
        ),
      ),
    );
  }

  // ── Tab 3: Code Decoding Key ──
  Widget _buildCodeKeyTab(BuildContext context) {
    final isDark = AppTheme.isDark(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rule 1: Section Rooms (R.C503)
        _buildDecoderCard(
          icon: Icons.door_sliding_rounded,
          title: 'قاعات السكاشن (مثال: R.C503)',
          color: const Color(0xFF6C5CE7),
          breakdown: [
            {'part': 'R', 'meaning': 'قاعة سكاشن (Room)'},
            {'part': 'C', 'meaning': 'مبنى C'},
            {'part': '5', 'meaning': 'الدور الخامس علوي'},
            {'part': '03', 'meaning': 'رقم القاعة'},
          ],
          context: context,
        ),

        const SizedBox(height: 16),

        // Rule 2: Practical Labs (L.D202)
        _buildDecoderCard(
          icon: Icons.computer_rounded,
          title: 'معامل السكاشن العملي (مثال: L.D202)',
          color: const Color(0xFF00B894),
          breakdown: [
            {'part': 'L', 'meaning': 'معمل عملي (Lab)'},
            {'part': 'D', 'meaning': 'مبنى D'},
            {'part': '2', 'meaning': 'الدور الثاني علوي'},
            {'part': '02', 'meaning': 'رقم المعمل'},
          ],
          context: context,
        ),

        const SizedBox(height: 16),

        // Rule 3: Main Lecture Halls (مدرج A, B, C, D, E, F, G)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.bgCard : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.theater_comedy_rounded, color: Color(0xFFE17055), size: 24),
                  SizedBox(width: 10),
                  Text(
                    'توزيع مدرجات المحاضرات الكبرى',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildBulletPoint('🏛️ مدرج A: مبنى C — الدور الثاني علوي'),
              _buildBulletPoint('🏛️ مدرج B: مبنى C — الدور الثالث علوي'),
              _buildBulletPoint('🏛️ مدرج C: مبنى C — الدور الرابع علوي'),
              _buildBulletPoint('🏛️ مدرج D & E: مبنى D — الدور الثالث علوي'),
              _buildBulletPoint('🏛️ مدرج F & G: مبنى D — الدور الرابع علوي'),
              _buildBulletPoint('🏛️ مدرج 301 هـ & 402 هـ: مبنى E (الملحق الجديد)'),
              _buildBulletPoint('🏛️ مدرج LG006: مبنى E — الدور الأرضي المنخفض'),
            ],
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildDecoderCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<Map<String, String>> breakdown,
    required BuildContext context,
  }) {
    final isDark = AppTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: breakdown.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item['part']!,
                      style: TextStyle(fontWeight: FontWeight.w900, color: color, fontSize: 13),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '= ${item['meaning']!}',
                      style: TextStyle(fontSize: 12, color: AppTheme.getTextPrimary(context)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, height: 1.4),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Full-screen Pinch-to-Zoom Image Viewer
// ═══════════════════════════════════════════

class _FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final String title;

  const _FullScreenImageViewer({
    required this.imagePath,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: imagePath,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.8,
            maxScale: 5.0,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// Attendance & Absence Tracker Page (Lectures & Sections/Labs)
// ═══════════════════════════════════════════

class _AttendanceTrackerPage extends StatefulWidget {
  const _AttendanceTrackerPage();

  @override
  State<_AttendanceTrackerPage> createState() => _AttendanceTrackerPageState();
}

class _AttendanceTrackerPageState extends State<_AttendanceTrackerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _subjects = [
    {
      'id': 'dss',
      'ar': 'نظم دعم القرار',
      'en': 'Decision Support Systems',
      'color': '#6C5CE7',
      'secTypeAr': '💻 معمل عملي',
      'secTypeEn': '💻 Computer Lab',
    },
    {
      'id': 'gis',
      'ar': 'نظم المعلومات الجغرافية',
      'en': 'Geographic Information Systems',
      'color': '#00B894',
      'secTypeAr': '💻 معمل عملي',
      'secTypeEn': '💻 Computer Lab',
    },
    {
      'id': 'hrm',
      'ar': 'إدارة الموارد البشرية',
      'en': 'Human Resources Management',
      'color': '#FFAA00',
      'secTypeAr': '🚪 سكشن نظري',
      'secTypeEn': '🚪 Section',
    },
    {
      'id': 'ma',
      'ar': 'محاسبة إدارية',
      'en': 'Managerial Accounting',
      'color': '#0984E3',
      'secTypeAr': '🚪 سكشن نظري',
      'secTypeEn': '🚪 Section',
    },
    {
      'id': 'ase',
      'ar': 'دراسات محاسبية بلغة إنجليزية',
      'en': 'Accounting Studies in English',
      'color': '#E84393',
      'secTypeAr': '🚪 سكشن نظري',
      'secTypeEn': '🚪 Section',
    },
  ];

  static const int _maxAllowedAbsences = 4; // 25% of semester (14 weeks)

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'متتبع الحضور والغياب' : 'Attendance & Absences'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.getTextHint(context),
          indicatorColor: AppTheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.school_rounded, size: 20),
              text: isArabic ? '🎓 غياب المحاضرات' : 'Lectures Attendance',
            ),
            Tab(
              icon: const Icon(Icons.computer_rounded, size: 20),
              text: isArabic ? '💻 غياب السكاشن والمعامل' : 'Sections & Labs',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: loc.resetAll,
            onPressed: () => _showResetDialog(context, loc),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Lectures
          _buildAttendanceList(context, isLecture: true),

          // Tab 2: Sections & Labs
          _buildAttendanceList(context, isLecture: false),
        ],
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context, {required bool isLecture}) {
    final loc = AppLocalizations.of(context);
    final isArabic = loc.isArabic;
    final isDark = AppTheme.isDark(context);
    final prefix = isLecture ? 'lec' : 'sec';

    return BlocBuilder<PreferencesCubit, PreferencesState>(
      builder: (context, prefs) {
        int totalAttended = 0;
        int totalAbsences = 0;

        for (final s in _subjects) {
          final key = '${s['id']!}_$prefix';
          // Support both new key and legacy key for lecture
          final legacyKey = s['id']!;
          final att = prefs.attendance[key] ?? (isLecture ? (prefs.attendance[legacyKey] ?? 0) : 0);
          final abs = prefs.absences[key] ?? (isLecture ? (prefs.absences[legacyKey] ?? 0) : 0);

          totalAttended += att;
          totalAbsences += abs;
        }

        final totalRecorded = totalAttended + totalAbsences;
        final overallPercentage = totalRecorded > 0
            ? ((totalAttended / totalRecorded) * 100).toInt()
            : 100;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ── Overall Stats Dashboard ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          isLecture ? const Color(0xFF1E1B4B) : const Color(0xFF064E3B),
                          isLecture ? const Color(0xFF312E81) : const Color(0xFF047857),
                        ]
                      : [
                          isLecture ? const Color(0xFF4338CA) : const Color(0xFF059669),
                          isLecture ? const Color(0xFF6366F1) : const Color(0xFF10B981),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: (isLecture ? const Color(0xFF4F46E5) : const Color(0xFF10B981))
                        .withValues(alpha: isDark ? 0.35 : 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic
                                ? (isLecture ? 'معدل حضور المحاضرات' : 'معدل حضور السكاشن والمعامل')
                                : (isLecture ? 'Lectures Attendance Rate' : 'Labs & Sections Rate'),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$overallPercentage%',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFFD166),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isLecture ? Icons.school_rounded : Icons.computer_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'إجمالي الحضور' : 'Attended',
                                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                  Text(
                                    '$totalAttended ${isLecture ? (isArabic ? 'محاضرة' : 'Lec') : (isArabic ? 'سكشن/معمل' : 'Lab')}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cancel_rounded, color: Color(0xFFFF6B6B), size: 18),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isArabic ? 'إجمالي الغياب' : 'Absences',
                                    style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8)),
                                  ),
                                  Text(
                                    '$totalAbsences غياب',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Policy Alert Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFCBD5E1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 18, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isArabic
                          ? 'الحد الأقصى للغياب في ${isLecture ? "المحاضرات" : "السكاشن والمعامل"} هو 4 مرات (25%) قبل الحرمان.'
                          : 'Maximum allowed absence in ${isLecture ? "lectures" : "labs/sections"} is 4 sessions (25%).',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.getTextSecondary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Subjects Attendance Cards ──
            ...List.generate(_subjects.length, (index) {
              final subject = _subjects[index];
              final rawId = subject['id']!;
              final key = '${rawId}_$prefix';
              final legacyKey = rawId;

              final name = isArabic ? subject['ar']! : subject['en']!;
              final secType = isArabic ? subject['secTypeAr']! : subject['secTypeEn']!;
              final colorHex = subject['color']!;
              final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

              final attendedCount = prefs.attendance[key] ?? (isLecture ? (prefs.attendance[legacyKey] ?? 0) : 0);
              final absentCount = prefs.absences[key] ?? (isLecture ? (prefs.absences[legacyKey] ?? 0) : 0);

              final totalSubRecorded = attendedCount + absentCount;
              final subPercentage = totalSubRecorded > 0
                  ? ((attendedCount / totalSubRecorded) * 100).toInt()
                  : 100;

              final remainingAbsences = _maxAllowedAbsences - absentCount;
              final _StatusInfo status = _getAbsenceStatus(absentCount, isArabic);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.bgCard : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: absentCount >= 3
                        ? AppTheme.error.withValues(alpha: isDark ? 0.4 : 0.6)
                        : (isDark ? Colors.white.withValues(alpha: 0.07) : const Color(0xFFE2E8F0)),
                    width: absentCount >= 3 ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subject Header & Status Badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.getTextPrimary(context),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: isDark ? 0.2 : 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      isLecture ? (isArabic ? '🎓 محاضرة' : '🎓 Lecture') : secType,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isArabic
                                        ? 'الالتزام: $subPercentage%'
                                        : 'Rate: $subPercentage%',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.getTextHint(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: status.color.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: status.color.withValues(alpha: 0.35), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(status.emoji, style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text(
                                status.label,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: status.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Linear Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: totalSubRecorded > 0 ? (attendedCount / totalSubRecorded) : 1.0,
                        minHeight: 6,
                        backgroundColor: AppTheme.error.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          absentCount >= 3 ? AppTheme.error : AppTheme.success,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Counter Controls (Attended & Absent)
                    Row(
                      children: [
                        // Attended Section
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.success.withValues(alpha: isDark ? 0.08 : 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.success.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      loc.attended,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.success,
                                      ),
                                    ),
                                    Text(
                                      '$attendedCount',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.success,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _CounterButton(
                                      icon: Icons.remove,
                                      color: AppTheme.success,
                                      onTap: () => context
                                          .read<PreferencesCubit>()
                                          .decrementAttendance(key),
                                    ),
                                    const SizedBox(width: 4),
                                    _CounterButton(
                                      icon: Icons.add,
                                      color: AppTheme.success,
                                      onTap: () => context
                                          .read<PreferencesCubit>()
                                          .incrementAttendance(key),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Absent Section
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.error.withValues(alpha: isDark ? 0.08 : 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.error.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isArabic ? 'غياب' : 'Absent',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.error,
                                      ),
                                    ),
                                    Text(
                                      '$absentCount',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: AppTheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _CounterButton(
                                      icon: Icons.remove,
                                      color: AppTheme.error,
                                      onTap: () => context
                                          .read<PreferencesCubit>()
                                          .decrementAbsence(key),
                                    ),
                                    const SizedBox(width: 4),
                                    _CounterButton(
                                      icon: Icons.add,
                                      color: AppTheme.error,
                                      onTap: () => context
                                          .read<PreferencesCubit>()
                                          .incrementAbsence(key),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (remainingAbsences > 0 && absentCount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        isArabic
                            ? '💡 متبقي لك $remainingAbsences غيابات مسموحة في ${isLecture ? "المحاضرة" : "السكشن"} قبل الحرمان'
                            : '💡 $remainingAbsences remaining allowed absence(s)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.getTextHint(context),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 80),
          ],
        );
      },
    );
  }

  _StatusInfo _getAbsenceStatus(int absences, bool isArabic) {
    if (absences == 0) {
      return _StatusInfo(
        label: isArabic ? 'ملتزم تماماً' : 'Perfect',
        emoji: '🟢',
        color: const Color(0xFF10B981),
      );
    } else if (absences == 1) {
      return _StatusInfo(
        label: isArabic ? 'في أمان' : 'Safe',
        emoji: '🟢',
        color: const Color(0xFF10B981),
      );
    } else if (absences == 2) {
      return _StatusInfo(
        label: isArabic ? 'إنذار أول' : 'Warning',
        emoji: '🟡',
        color: const Color(0xFFF59E0B),
      );
    } else if (absences == 3) {
      return _StatusInfo(
        label: isArabic ? 'خطر حرمان' : 'Critical',
        emoji: '🟠',
        color: const Color(0xFFE17055),
      );
    } else {
      return _StatusInfo(
        label: isArabic ? 'تجاوزت الحد' : 'Deprived',
        emoji: '🔴',
        color: const Color(0xFFEF4444),
      );
    }
  }

  void _showResetDialog(BuildContext context, AppLocalizations loc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.getCardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(loc.resetAll),
        content: Text(
          loc.isArabic
              ? 'هل أنت متأكد من تصفير جميع عدادات الحضور والغياب للمحاضرات والسكاشن؟'
              : loc.resetConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<PreferencesCubit>().resetAttendance();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text(loc.resetAll),
          ),
        ],
      ),
    );
  }
}

class _StatusInfo {
  final String label;
  final String emoji;
  final Color color;

  const _StatusInfo({
    required this.label,
    required this.emoji,
    required this.color,
  });
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CounterButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// University & Student Portals Page
// ═══════════════════════════════════════════

class _UniversityPortalsPage extends StatelessWidget {
  const _UniversityPortalsPage();

  static const _portals = [
    _PortalInfo(
      titleAr: 'المنصة التعليمية للمعهد (MET Portal)',
      titleEn: 'MET Student Educational Portal',
      url: 'https://student.metmans.edu.eg/',
      descriptionAr:
          'المقررات والمحاضرات الإلكترونية، رفع التكليفات والواجبات، ومتابعة الحساب الدراسي وسداد الرسوم.',
      descriptionEn:
          'Course materials, lecture slides, assignments submission, and academic tuition services.',
      icon: Icons.school_rounded,
      color: Color(0xFF0984E3),
      badgeAr: 'المنصة الرئيسية 🎓',
      badgeEn: 'Official Portal',
    ),
    _PortalInfo(
      titleAr: 'منصة الاختبارات والكويزات (Exams)',
      titleEn: 'Mansoura University Online Exams',
      url: 'https://exexams.mans.edu.eg/',
      descriptionAr:
          'أداء الامتحانات والكويزات الإلكترونية المعتمدة لجامعة المنصورة والمعهد خلال الفصل الدراسي.',
      descriptionEn:
          'Online quizzes, midterms, and semester electronic examination system.',
      icon: Icons.quiz_rounded,
      color: Color(0xFF6C5CE7),
      badgeAr: 'كويزات أونلاين 📝',
      badgeEn: 'Online Exams',
    ),
    _PortalInfo(
      titleAr: 'نظام ابن الهيثم لشؤون الطلاب (STDA)',
      titleEn: 'Ibn Al-Haytham Student Affairs',
      url: 'https://stda.mans.edu.eg/',
      descriptionAr:
          'معرفة النتائج ودرجات الامتحانات، تسجيل الرغبات، السجل الأكاديمي التراكمي، والجداول الرسمية.',
      descriptionEn:
          'Academic records, semester results, registration, and official university status.',
      icon: Icons.account_balance_rounded,
      color: Color(0xFF00B894),
      badgeAr: 'النتائج والسجل 🏛️',
      badgeEn: 'Results & Records',
    ),
  ];

  static Future<void> _launch(BuildContext context, String urlString) async {
    final uri = Uri.parse(urlString);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && context.mounted) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر فتح الرابط في المتصفح'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static void _copyUrl(BuildContext context, String urlString, String title) {
    Clipboard.setData(ClipboardData(text: urlString));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'تم نسخ رابط $title بنجاح! 📋',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          loc.isArabic ? 'بوابات ومنصات المعهد' : 'University Portals',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          // ── Header Banner ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.25 : 0.15),
                  const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.20 : 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.public_rounded,
                    color: Color(0xFF3B82F6),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isArabic
                            ? 'روابط المعهد والجامعة المعتمدة'
                            : 'Official College & University Portals',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.getTextPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.isArabic
                            ? 'كل المنصات والخدمات الطلابية التي تحتاجها في مكان واحد وبضغطة زر.'
                            : 'All student services and e-learning platforms in one place.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.getTextSecondary(context),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Portal Cards ──
          ..._portals.map((portal) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: AppTheme.glassDecorationWithColor(portal.color, context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Badge Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: portal.color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(portal.icon, color: portal.color, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loc.isArabic ? portal.titleAr : portal.titleEn,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.getTextPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              portal.url,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: portal.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: portal.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: portal.color.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          loc.isArabic ? portal.badgeAr : portal.badgeEn,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: portal.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    loc.isArabic ? portal.descriptionAr : portal.descriptionEn,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.getTextSecondary(context),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Open in Browser Button
                      Expanded(
                        flex: 3,
                        child: ElevatedButton.icon(
                          onPressed: () => _launch(context, portal.url),
                          icon: const Icon(Icons.open_in_browser_rounded, size: 18),
                          label: Text(
                            loc.isArabic ? 'فتح المنصة ↗' : 'Open Portal ↗',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: portal.color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

                      // Copy URL Button
                      OutlinedButton.icon(
                        onPressed: () => _copyUrl(
                          context,
                          portal.url,
                          loc.isArabic ? portal.titleAr : portal.titleEn,
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: Text(
                          loc.isArabic ? 'نسخ' : 'Copy',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white70 : AppTheme.textPrimaryLight,
                          side: BorderSide(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : const Color(0xFFCBD5E1),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // ── Helpful Tip Card ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFFF39C12).withValues(alpha: 0.12)
                  : const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF39C12).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.isArabic ? 'تنويه هام للطلاب' : 'Important Note',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFFDCB6E)
                              : const Color(0xFFB45309),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        loc.isArabic
                            ? 'تأكد من الاحتفاظ ببيانات الدخول الرسمية (كود الطالب / الرقم القومي وكلمة المرور) للدخول السريع على المنصات الامتحانية والتعليمية.'
                            : 'Make sure to keep your student credentials (National ID / Student Code) ready for fast portal access.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.white70
                              : const Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalInfo {
  final String titleAr;
  final String titleEn;
  final String url;
  final String descriptionAr;
  final String descriptionEn;
  final IconData icon;
  final Color color;
  final String badgeAr;
  final String badgeEn;

  const _PortalInfo({
    required this.titleAr,
    required this.titleEn,
    required this.url,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.icon,
    required this.color,
    required this.badgeAr,
    required this.badgeEn,
  });
}



