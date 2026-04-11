import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';

class Dashboard1 extends StatefulWidget {
  const Dashboard1({super.key});

  @override
  State<Dashboard1> createState() => _Dashboard1State();
}

class _Dashboard1State extends State<Dashboard1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;

  void _onNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/focus');
        break;
      case 3:
        context.go('/ai');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF13111A),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 24),
                  _buildHeroBanner(),
                  const SizedBox(height: 16),
                  _buildTopStats(),
                  const SizedBox(height: 16),
                  _buildFeatureGrid(),
                  const SizedBox(height: 32),
                  _buildTasksHeader(),
                  const SizedBox(height: 16),
                  _buildTasksList(),
                  const SizedBox(height: 24),
                  _buildFocusHeatmap(),
                  const SizedBox(height: 16),
                  _buildAIInsight(),
                  const SizedBox(height: 16),
                  _buildWeekWarrior(),
                ],
              ),
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu, color: Colors.white, size: 20),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good afternoon ☀️',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Text(
                  'Hello, Alex!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(Icons.notifications_none, color: Colors.white, size: 20),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8B878),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFB284BE), Color(0xFFA2ADD0)],
            ),
          ),
          alignment: Alignment.center,
          child: const Text(
            'AJ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB284BE), Color(0xFF8C9DF9)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.flash_on, color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                'READY TO FOCUS?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 10,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'start a',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'Syne', fontWeight: FontWeight.w800, height: 1.1),
                    ),
                    Text(
                      'Focus',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'Syne', fontWeight: FontWeight.w800, height: 1.1),
                    ),
                    Text(
                      'Session',
                      style: TextStyle(color: Colors.white, fontSize: 32, fontFamily: 'Syne', fontWeight: FontWeight.w800, height: 1.1),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white, size: 36),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.play_arrow, color: Colors.white, size: 12),
                SizedBox(width: 6),
                Text(
                  '25:00 Pomodoro',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Syne', fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.timer_outlined,
            value: '3h\n20m',
            label: 'Focused Today',
            colors: [const Color(0xFF262035), const Color(0xFF1E1A2A)],
            valueColor: const Color(0xFFB284BE),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_box_outlined,
            value: '1/3',
            label: 'Tasks Done',
            colors: [const Color(0xFF232030), const Color(0xFF1D1B28)],
            valueColor: const Color(0xFFA2ADD0),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.local_fire_department_outlined,
            value: '7\ndays',
            label: 'Streak',
            colors: [const Color(0xFF332620), const Color(0xFF28201B)],
            valueColor: const Color(0xFFF8B878),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> colors,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 16),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'AI Chat',
                subtitle: 'Ask anything',
                icon: Icons.psychology_outlined,
                colors: [const Color(0xFFB284BE), const Color(0xFF886392)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                title: 'Study Room',
                subtitle: 'Study together',
                icon: Icons.people_outline,
                colors: [const Color(0xFFEAA063), const Color(0xFFC7814A)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeatureCard(
                title: 'Discipline',
                subtitle: 'Block distractions',
                icon: Icons.shield_outlined,
                colors: [const Color(0xFFA2ADD0), const Color(0xFF7E89AB)],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeatureCard(
                title: 'Notes',
                subtitle: 'Your knowledge base',
                icon: Icons.menu_book_outlined,
                colors: [const Color(0xFFC8A2C8), const Color(0xFF9E7E9E)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Color> colors,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              Icon(Icons.arrow_forward_outlined, color: Colors.white.withOpacity(0.5), size: 16),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 11,
              fontFamily: 'Syne',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Today's Tasks",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '33% complete · 1 of 3 done',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
                fontFamily: 'Syne',
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 180,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB284BE), Color(0xFFF8B878)],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                'See all',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, color: Colors.white.withOpacity(0.8), size: 14),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    return Column(
      children: [
        _buildTaskItem(
          label: 'Health - 19:00',
          title: 'take doctor appointment',
          status: 'To-do',
          colors: [const Color(0xFFECEBBD), const Color(0xFFDCDAA7)],
          textColor: const Color(0xFF4A4B3A),
          tagColor: const Color(0xFFB4B390),
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          label: 'Grocery App - 12:00',
          title: 'Competitive Analysis',
          status: 'In Progress',
          colors: [const Color(0xFFB284BE), const Color(0xFF9E75AB)],
          textColor: Colors.white,
          tagColor: const Color(0xFF886392),
        ),
        const SizedBox(height: 12),
        _buildTaskItem(
          label: 'Uber Eats Redesign - 19:00',
          title: 'Low-fi Wireframes',
          status: 'To-do',
          colors: [const Color(0xFFF8B878), const Color(0xFFE2A05F)],
          textColor: const Color(0xFF5A3A1A),
          tagColor: const Color(0xFFC7814A),
        ),
      ],
    );
  }

  Widget _buildTaskItem({
    required String label,
    required String title,
    required String status,
    required List<Color> colors,
    required Color textColor,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 10,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: tagColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: textColor.withOpacity(0.9),
                fontSize: 10,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusHeatmap() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1C28),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.show_chart, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Focus Activity',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Syne', fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Past 7 days',
                        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11, fontFamily: 'Syne'),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF143022),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text(
                      '+12% this week',
                      style: TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontFamily: 'Syne', fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Simplified Heatmap Grid Simulation
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              // Creating a varied color pattern based on the image
              Color cellColor = const Color(0xFF232130);
              if (index % 7 == 4 && index > 10) {
                cellColor = const Color(0xFFB284BE);
              } else if (index % 3 == 0) cellColor = const Color(0xFF4A3C59);
              else if (index % 5 == 0) cellColor = const Color(0xFF383149);

              return Container(
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('M', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('T', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('W', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('T', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('F', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('S', style: TextStyle(color: Colors.grey, fontSize: 10)),
              Text('S', style: TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text('Less', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
              const SizedBox(width: 8),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF232130), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF383149), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF4A3C59), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF886392), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFFB284BE), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('More', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('18h\n40m', style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Syne', fontWeight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 6),
                  Text('Week Total', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontFamily: 'Syne')),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Friday', style: TextStyle(color: Color(0xFFF8B878), fontSize: 20, fontFamily: 'Syne', fontWeight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 6),
                  Text('Best Day', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontFamily: 'Syne')),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('2h\n40m', style: TextStyle(color: Color(0xFFA2ADD0), fontSize: 20, fontFamily: 'Syne', fontWeight: FontWeight.w800, height: 1.1)),
                  const SizedBox(height: 6),
                  Text('Daily Avg', style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, fontFamily: 'Syne')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        gradient: LinearGradient(
          colors: [const Color(0xFF1E1C28).withOpacity(0.8), const Color(0xFF13111A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.psychology_outlined, color: Color(0xFFA2ADD0), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFFA2ADD0), size: 12),
                        const SizedBox(width: 4),
                        const Text(
                          'AI INSIGHT',
                          style: TextStyle(color: Color(0xFFA2ADD0), fontSize: 10, fontFamily: 'Syne', fontWeight: FontWeight.w800, letterSpacing: 1.0),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: index == 0 ? 12 : 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: index == 0 ? const Color(0xFFA2ADD0) : const Color(0xFFA2ADD0).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '5-MIN BREAKS IMPROVE RETENTION BY UP TO 20%. 🧠',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekWarrior() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF8B878).withOpacity(0.2)),
        gradient: LinearGradient(
          colors: [const Color(0xFFF8B878).withOpacity(0.15), const Color(0xFF13111A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8B878).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.star, color: Color(0xFFF8B878), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Week Warrior 🏆',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Syne', fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  '7-day streak — keep it up!',
                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontFamily: 'Syne'),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '+100',
                style: TextStyle(color: Color(0xFFF8B878), fontSize: 20, fontFamily: 'Syne', fontWeight: FontWeight.w800),
              ),
              Text(
                'XP earned',
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontFamily: 'Syne'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return UnifiedBottomNavBar(
      selectedIndex: _currentIndex,
      onNavItemTapped: _onNavTapped,
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF13111A),
      width: 320,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(
                        'lib/features/onboarding/assets/logo.svg',
                        width: 28,
                        height: 28,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFB284BE),
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Neurova',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Syne', fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Profile Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFFB284BE).withOpacity(0.12), const Color(0xFFA2ADD0).withOpacity(0.03)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB284BE).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB284BE), Color(0xFFA2ADD0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: const Text('AJ', style: TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'Syne', fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Alex Johnson', style: TextStyle(color: Colors.white, fontSize: 15, fontFamily: 'Syne', fontWeight: FontWeight.w800)),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle)),
                              const SizedBox(width: 6),
                              Text('Level 5 · 1,340 XP', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 12, fontFamily: 'Syne', fontWeight: FontWeight.w400)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8B878).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF8B878).withOpacity(0.28)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.local_fire_department, color: Color(0xFFF8B878), size: 14),
                          SizedBox(width: 4),
                          Text('7', style: TextStyle(color: Color(0xFFF8B878), fontSize: 12, fontFamily: 'Syne', fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontFamily: 'Syne', fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _buildDrawerItem(icon: Icons.window, label: 'Dashboard', isActive: true, route: '/dashboard'),
                    _buildDrawerItem(icon: Icons.check_box_outlined, label: 'Tasks', isActive: false, route: '/tasks'),
                    _buildDrawerItem(icon: Icons.timer_outlined, label: 'Focus', isActive: false, route: '/focus'),
                    _buildDrawerItem(icon: Icons.auto_awesome, label: 'AI Assistant', isActive: false, route: '/ai'),
                    _buildDrawerItem(icon: Icons.menu_book_outlined, label: 'Notes', isActive: false, route: '/notes'),
                    _buildDrawerItem(icon: Icons.people_outline, label: 'Study Rooms', isActive: false, route: '/study-rooms'),
                    _buildDrawerItem(icon: Icons.shield_outlined, label: 'Discipline', isActive: false, route: '/discipline'),
                    _buildDrawerItem(icon: Icons.person_outline, label: 'Profile', isActive: false, route: '/profile'),
                  ],
                ),
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                children: [
                  _buildDrawerBottomItem(icon: Icons.notifications_none, label: 'Notifications', route: '/notifications'),
                  _buildDrawerBottomItem(icon: Icons.settings_outlined, label: 'Settings', route: '/settings'),
                  _buildDrawerBottomItem(icon: Icons.help_outline, label: 'Help & FAQ'),
                  const SizedBox(height: 8),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 22),
                    title: const Text('Sign Out', style: TextStyle(color: Color(0xFFEF4444), fontSize: 15, fontFamily: 'Syne', fontWeight: FontWeight.w600)),
                    onTap: () => context.go('/login'),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({required IconData icon, required String label, required bool isActive, String? route}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: isActive
          ? BoxDecoration(
              color: const Color(0xFFB284BE).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB284BE).withOpacity(0.28)),
            )
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFB284BE).withOpacity(0.18) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: isActive ? const Color(0xFFB284BE) : Colors.white.withOpacity(0.55), size: 18),
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFFB284BE) : Colors.white.withOpacity(0.8),
            fontSize: 14,
            fontFamily: 'Syne',
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: isActive ? const Icon(Icons.chevron_right, color: Color(0xFFB284BE), size: 20) : null,
        onTap: route != null ? () => context.go(route) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Widget _buildDrawerBottomItem({required IconData icon, required String label, String? route}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Icon(icon, color: Colors.white.withOpacity(0.55), size: 22),
      title: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 14,
          fontFamily: 'Syne',
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: route != null ? () => context.go(route) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
