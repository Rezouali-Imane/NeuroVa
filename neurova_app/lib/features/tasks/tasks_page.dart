import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import '../../features/focus/dashboard1.dart';
import '../../features/focus/focus_page.dart';          
import '../../features/ai/ai_page.dart';                 
import '../../features/profil/userprofil.dart';
 
class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}
 
 

class _TasksPageState extends State<TasksPage> {
  int selectedIndex = 1;
   int selectedTab = 0;
 String selectedPriority = "Medium";
 String selectedCategory = "Design";
 List<Task> tasks = [];
 final TextEditingController taskController = TextEditingController();
final TextEditingController projectController = TextEditingController();
TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: SafeArea(
        child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 6),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '2 of 6 done · ⚡ 1250 XP',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.32),
                                fontSize: 12,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'My Tasks',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontFamily: 'Syne',
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1,
                              ),
                            ),
                          ],
                        ),

                         GestureDetector(
  onTap: () {
    _showNewTaskBottomSheet();    
  },
  child: Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFB284BE), Color(0xFFA2ADD0)],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: const [
        BoxShadow(
          color: Color(0x50B284BE),
          blurRadius: 18,
          offset: Offset(0, 4),
        )
      ],
    ),
    child: const Icon(
      Icons.add_rounded,
      color: Colors.white,
      size: 26,
    ),
  ),
),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                 
                Container(
                  width: double.infinity,
                  height: 120,
                  decoration: ShapeDecoration(
                    color: const Color(0xFF1A1628),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                        width: 0.75,
                        color: Color(0xFF2A2440),
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Stack(
                    children: [

                      Positioned(
                        left: 112,
                        top: 23,
                        child: SizedBox(
                          width: 197,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              const Text(
                                'Overall Progress',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.35),
                                          fontSize: 18,
                                          fontFamily: 'Syne',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'To-do',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 16),

                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: Color(0xFFF8B878),
                                          fontSize: 18,
                                          fontFamily: 'Syne',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'In Progress',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(width: 16),

                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '2',
                                        style: TextStyle(
                                          color: Color(0xFF4ADE80),
                                          fontSize: 18,
                                          fontFamily: 'Syne',
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Done',
                                        style: TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Positioned(
                        left: 16,
                        top: 25,
                        child: SizedBox(
                          width: 70,
                          height: 70,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CustomPaint(
                                size: const Size(70, 70),
                                painter: ProgressCirclePainter(progress: 0.33),
                              ),
                              const Text(
                                '33%',
                                style: TextStyle(
                                  color: Color(0xFFB284BE),
                                  fontSize: 16,
                                  fontFamily: 'Syne',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                
                Container(
  width: double.infinity,
  height: 47.99,
  padding: const EdgeInsets.symmetric(horizontal: 15.99),
  decoration: ShapeDecoration(
    color: const Color(0xFF1A1628),
    shape: RoundedRectangleBorder(
      side: const BorderSide(
        width: 0.75,
        color: Color(0xFF2A2440),
      ),
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: TextField(
    controller: searchController,
    onChanged: (value) {
      setState(() {});
    },
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      icon: SizedBox(
        width: 15,
        height: 15,
        child: SvgPicture.asset(
          'lib/features/onboarding/assets/search.svg',
        ),
      ),
      hintText: "Search tasks…",
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.28),
        fontSize: 14,
        fontFamily: 'Syne',
      ),
      border: InputBorder.none,
    ),
  ),
),

                const SizedBox(height: 15),
  
 Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    _tab(0, "All", "6"),
    _tab(1, "To Do", "3"),
    _tab(2, "In Progress", "2"),
    _tab(3, "Done", "2"),
  ],
),
 const SizedBox(height:20),
ListView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  itemCount: tasks.length,
  itemBuilder: (context, index) {
    return _taskCard(tasks[index]);
  },
),


 
               
 
 
 
  
              ],
            ),
         
          ),
          
        ),
        
      ),
       bottomNavigationBar: Container(
        width: double.infinity,
        height: 73.47,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1628),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            width: 0.75,
            color: const Color(0xFF2A2440),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, "Home", "lib/features/onboarding/assets/Icon21.svg", const Dashboard1()),
            _navItem(1, "Tasks", "lib/features/onboarding/assets/task2.svg", const TasksPage()),
            _navItem(2, "Focus", "lib/features/onboarding/assets/Icon6.svg", const FocusPage()),
            _navItem(3, "AI", "lib/features/onboarding/assets/ia.svg", const AIPage()),
            _navItem(4, "Profile", "lib/features/onboarding/assets/Icon1.svg", const ProfilePage()),
          ],
        ),
      ),

    );
  }
  Widget _navItem(int index, String label, String assetPath, Widget page) {
    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        width: 64.24,
        height: 53.49,
        decoration: ShapeDecoration(
          color: isSelected ? const Color(0x14B284BE) : Colors.transparent,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 0.75,
              color: isSelected ? const Color(0x24B284BE) : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              assetPath,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(
                isSelected ? const Color(0xFFB284BE) : Colors.white70,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFB284BE) : Colors.white54,
                fontSize: 10,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
 Widget _tab(int index, String title, String count) {
  final bool isSelected = selectedTab == index;

  return InkWell(
    onTap: () {
      setState(() {
        selectedTab = index;
      });
    },
    child: Container(
      height: 53,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: ShapeDecoration(
        color: isSelected ? const Color(0x17B284BE) : Colors.transparent,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 0.75,
            color: isSelected
                ? const Color(0x3FB284BE)
                : const Color(0xFF2A2440),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TITLE
          Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFB284BE)
                  : Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(width: 6),
 
          Container(
            height: 17,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0x28B284BE)
                  : Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(100),
            ),
            alignment: Alignment.center,
            child: Text(
              count,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFFB284BE)
                    : Colors.white.withOpacity(0.28),
                fontSize: 9,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ),
  );
} 
    void _showNewTaskBottomSheet() {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        width: double.infinity,
        height: 636,
        decoration: ShapeDecoration(
          color: const Color(0xFF181526),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 0.75, color: Color(0xFF2A2440)),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(32),
              topRight: Radius.circular(32),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
               
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 30),

          Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    const Text(
      'New Task',
      style: TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontFamily: 'Syne',
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
    ),

    GestureDetector(
  onTap: () {
    Navigator.pop(context);  
  },
  child: Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        width: 0.75,
        color: const Color(0xFF2A2440),
      ),
    ),
    child: const Icon(
      Icons.close,
      color: Colors.white,
      size: 16,
    ),
  ),
),
  ],
),
              const SizedBox(height: 40),

       
  Text(
  'TASK',
  style: TextStyle(
    color: Colors.white.withValues(alpha: 0.30),
    fontSize: 10,
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 1,
  ),
),
              const SizedBox(height: 8),
              TextField(
                  controller: taskController, 
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'What needs to be done?',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2A2440), width: 0.75),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2A2440), width: 0.75),
                  ),
                ),
              ),

              const SizedBox(height: 25),

               
        Text(
  'PROJECT',
  style: TextStyle(
    color: Colors.white.withValues(alpha: 0.30),
    fontSize: 10,
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 1,
  ),
),
              const SizedBox(height: 8),
              TextField(
                  controller: projectController, 
                style: const TextStyle(color: Colors.white, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Project name…',
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.28)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2A2440), width: 0.75),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF2A2440), width: 0.75),
                  ),
                ),
              ),
              const SizedBox(height:20),

              Text(
  'PRIORITY',
  style: TextStyle(
    color: Colors.white.withValues(alpha: 0.30),
    fontSize: 10,
    fontFamily: 'Syne',
    fontWeight: FontWeight.w700,
    height: 1.50,
    letterSpacing: 1,
  ),
),

const SizedBox(height: 8),

Row(
  children: [
    Expanded(child: _priorityItem("High")),
    const SizedBox(width: 6),
    Expanded(child: _priorityItem("Medium")),
    const SizedBox(width: 6),
    Expanded(child: _priorityItem("Low")),
  ],
),
const SizedBox(height:20),

Text(
'CATEGORY',
style: TextStyle(
color: Colors.white.withValues(alpha: 0.30),
fontSize: 10,
fontFamily: 'Syne',
fontWeight: FontWeight.w700,
height: 1.50,
letterSpacing: 1,
),
),
const SizedBox(height:5),
Wrap(
  spacing: 8,
  runSpacing: 8,
  children: [
    _categoryItem("🎨", "Design"),
    _categoryItem("⚛️", "Development"),
    _categoryItem("🔍", "Research"),
    _categoryItem("📚", "Study"),
    _categoryItem("🌱", "Personal"),
    _categoryItem("📌", "Other"),
  ],
),

              const Spacer(),

               
              GestureDetector(
  onTap: () {
    if (taskController.text.isEmpty || projectController.text.isEmpty) return;
 
    Color taskColor;

    switch (selectedCategory) {
      case "Design":
        taskColor = const Color(0xFFB284BE);
        break;
      case "Development":
        taskColor = const Color(0xFFA2ADD0);
        break;
      case "Research":
        taskColor = const Color(0xFFF8B878);
        break;
      case "Study":
        taskColor = const Color(0xC0EDECBF);
        break;
      default:
        taskColor = const Color(0xFFB284BE);
    }

    setState(() {
      tasks.add(
        Task(
          title: taskController.text,
          project: projectController.text,
          category: selectedCategory,
          color: taskColor, 
        ),
      );
    });
  taskController.clear();
  projectController.clear();

  Navigator.pop(context);
},
                child: Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB284BE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Add Task',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    },
  );
  
}
Widget _priorityItem(String text) {
  final bool isSelected = selectedPriority == text;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedPriority = text;
      });
    },
    child: Container(
      height: 42,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0x17F8B878)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0x50F8B878)
              : const Color(0xFF2A2440),
          width: 0.75,
        ),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFF8B878)
                : Colors.white.withValues(alpha: 0.35),
            fontSize: 13,
            fontFamily: 'Syne',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    ),
  );
}
Widget _categoryItem(String emoji, String text) {
  final isSelected = selectedCategory == text;

  return GestureDetector(
    onTap: () {
      setState(() {
        selectedCategory = text;
      });
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0x17B284BE)
            : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          width: 0.75,
          color: isSelected
              ? const Color(0x3FB284BE)
              : const Color(0xFF2A2440),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isSelected
                  ? const Color(0xFFB284BE)
                  : Colors.white.withValues(alpha: 0.35),
              fontSize: 12,
              fontFamily: 'Syne',
              fontWeight:
                  isSelected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  );
}
 Widget _taskCard(Task task) {
  Color statusColor;
  String statusText;

  if (task.isDone) {
    statusColor = const Color(0xFF4ADE80);
    statusText = "Done";
  } else {
    statusColor = const Color(0xFFF8B878);
    statusText = "In Progress";
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    height: 131,
    decoration: BoxDecoration(
      color: task.color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        width: 0.75,
      color: task.color.withValues(alpha: 0.15),
      ),
    ),
    child: Stack(
      children: [

       
        Positioned(
          left: 24,
          top: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFFB284BE),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  Text(
                    task.project,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(width: 6),
                  const Text("·", style: TextStyle(color: Colors.white38)),
                  const SizedBox(width: 6),

                  Text(
                    task.category,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),

              
              GestureDetector(
                onTap: () {
                  setState(() {
                    task.isDone = !task.isDone;  
                  });
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: task.isDone
                        ? const Color(0x1F4ADE80)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: task.isDone
                          ? const Color(0x5F4ADE80)
                          : const Color(0xFF2A2440),
                    ),
                  ),
                  child: Icon(
                    task.isDone
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                    size: 16,
                    color: task.isDone
                        ? const Color(0xFF4ADE80)
                        : Colors.white38,
                  ),
                ),
              ),
            ],
          ),
        ),

        
        Positioned(
          left: 24,
          top: 56,
          child: Text(
            task.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              decoration:
                  task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        ),

        
        Positioned(
          left: 24,
          right: 16,
          bottom: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// DATE (temporaire)
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 12, color: Colors.white38),
                  const SizedBox(width: 4),
                  const Text(
                    "Mar 10",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "10:00 AM",
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),

               
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
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


class ProgressCirclePainter extends CustomPainter {
  final double progress;
  ProgressCirclePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final bgPaint = Paint()
      ..color = const Color(0x5EE8E8FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFB284BE), Color(0xFFC8A2C8)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
 class Task {
  final String title;
  final String project;
  final String category;
  final Color color;  
  bool isDone;

  Task({
    required this.title,
    required this.project,
    required this.category,
    required this.color,  
    this.isDone = false,
  });
}
