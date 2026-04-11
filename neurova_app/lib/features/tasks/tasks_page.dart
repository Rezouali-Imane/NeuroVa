import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neurova_app/features/auth/state/auth_notifier.dart';
import '../../shared/widgets/unified_bottom_nav_bar.dart';
import 'state/tasks_notifier.dart';
import 'models/task_model.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});

  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  int selectedIndex = 1;
  int selectedTab = 0;
  String selectedPriority = "1";
  String selectedCategory = "OTHER";
  final TextEditingController taskController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(tasksNotifierProvider.notifier).fetchTasks();
    });
  }

  @override
  void dispose() {
    taskController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksNotifierProvider);

    List<Task> filteredTasks = tasksState.tasks;
    if (selectedTab == 1) {
      filteredTasks = tasksState.tasks.where((t) => t.status == 'PENDING').toList();
    } else if (selectedTab == 2) {
      filteredTasks = tasksState.tasks.where((t) => t.status == 'IN_PROGRESS').toList();
    } else if (selectedTab == 3) {
      filteredTasks = tasksState.tasks.where((t) => t.status == 'COMPLETED').toList();
    }

    int totalTasks = tasksState.tasks.length;
    int completedTasks = tasksState.tasks.where((t) => t.status == 'COMPLETED').length;
    int inProgress = tasksState.tasks.where((t) => t.status == 'IN_PROGRESS').length;
    int pending = tasksState.tasks.where((t) => t.status == 'PENDING').length;
    double progressPercent = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF13111A),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
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
                                '$completedTasks of $totalTasks done · ⚡ 1250 XP',
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
                            onTap: () => _showNewTaskBottomSheet(context),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$pending',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            fontSize: 18,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        Text(
                                          'To-do',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.28),
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$inProgress',
                                          style: const TextStyle(
                                            color: Color(0xFFF8B878),
                                            fontSize: 18,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Text(
                                          'In Progress',
                                          style: TextStyle(
                                            color: Colors.white38,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$completedTasks',
                                          style: const TextStyle(
                                            color: Color(0xFF4ADE80),
                                            fontSize: 18,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const Text(
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
                                  painter: ProgressCirclePainter(
                                      progress: progressPercent / 100),
                                ),
                                Text(
                                  '${progressPercent.toStringAsFixed(0)}%',
                                  style: const TextStyle(
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
                      _buildTab(0, "All", filteredTasks.length.toString()),
                      _buildTab(1, "To Do", pending.toString()),
                      _buildTab(2, "In Progress", inProgress.toString()),
                      _buildTab(3, "Done", completedTasks.toString()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (tasksState.isLoading)
                    const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFB284BE)))
                  else if (tasksState.error != null)
                    Center(
                      child: Text(
                        'Error: ${tasksState.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else if (filteredTasks.isEmpty)
                    Center(
                      child: Text(
                        'No tasks yet. Create one to get started!',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(filteredTasks[index]);
                      },
                    ),
                ],
              ),
            ),
          ),
          UnifiedBottomNavBar(
            selectedIndex: selectedIndex,
            onNavItemTapped: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String title, String count) {
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

  void _showNewTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              height: 550,
              decoration: ShapeDecoration(
                color: const Color(0xFF181526),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                      width: 0.75, color: Color(0xFF2A2440)),
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
                          onTap: () => Navigator.pop(context),
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
                    const SizedBox(height: 25),
                    Text(
                      'TASK TITLE',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.30),
                        fontSize: 10,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: taskController,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'What needs to be done?',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.28)),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.04),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF2A2440), width: 0.75),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: Color(0xFF2A2440), width: 0.75),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'PRIORITY',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.30),
                        fontSize: 10,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: _buildPriorityItem(
                                "3", "High", setModalState)),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _buildPriorityItem(
                                "1", "Medium", setModalState)),
                        const SizedBox(width: 6),
                        Expanded(
                            child: _buildPriorityItem("0", "Low", setModalState)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'CATEGORY',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.30),
                        fontSize: 10,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildCategoryItem("ACADEMIC", setModalState),
                        _buildCategoryItem("PERSONAL", setModalState),
                        _buildCategoryItem("WORK", setModalState),
                        _buildCategoryItem("HEALTH", setModalState),
                        _buildCategoryItem("OTHER", setModalState),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        if (taskController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Please enter a task title')),
                          );
                          return;
                        }

                        final localStorage =
                            ref.read(localStorageServiceProvider);
                        final userId =
                            await localStorage.readUserId();

                        if (!context.mounted) return;

                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('User not authenticated')),
                          );
                          return;
                        }

                        await ref
                            .read(tasksNotifierProvider.notifier)
                            .createTask(
                              userId: userId,
                              title: taskController.text,
                              listId: 'default',
                              priority:
                                  int.tryParse(selectedPriority) ?? 1,
                              status: 'PENDING',
                              category: selectedCategory,
                            );

                        taskController.clear();
                        selectedPriority = "1";
                        selectedCategory = "OTHER";

                        if (!context.mounted) return;
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
      },
    );
  }

  Widget _buildPriorityItem(
      String value, String text, Function setModalState) {
    final bool isSelected = selectedPriority == value;
    return GestureDetector(
      onTap: () {
        setModalState(() {
          selectedPriority = value;
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

  Widget _buildCategoryItem(String text, Function setModalState) {
    final isSelected = selectedCategory == text;
    return GestureDetector(
      onTap: () {
        setModalState(() {
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
        child: Text(
          text,
          style: TextStyle(
            color: isSelected
                ? const Color(0xFFB284BE)
                : Colors.white.withValues(alpha: 0.35),
            fontSize: 12,
            fontFamily: 'Syne',
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    Color statusColor;
    String statusText;
    Color taskColor;

    if (task.status == 'COMPLETED') {
      statusColor = const Color(0xFF4ADE80);
      statusText = "Done";
      taskColor = const Color(0xFF1A1628).withValues(alpha: 0.5);
    } else if (task.status == 'IN_PROGRESS') {
      statusColor = const Color(0xFFF8B878);
      statusText = "In Progress";
      taskColor = const Color(0xFFA2ADD0).withValues(alpha: 0.15);
    } else {
      statusColor = const Color(0xFF6366F1);
      statusText = "To Do";
      taskColor = const Color(0xFFB284BE).withValues(alpha: 0.1);
    }

    String deadlineText = "No deadline";
    if (task.deadline != null) {
      final date = task.deadline!;
      deadlineText = "${date.month}/${date.day}";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 120,
      decoration: BoxDecoration(
        color: taskColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          width: 0.75,
          color: Colors.white.withValues(alpha: 0.1),
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
                      task.category,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("·", style: TextStyle(color: Colors.white38)),
                    const SizedBox(width: 6),
                    Text(
                      task.priority.toString(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    final newStatus = task.status == 'COMPLETED'
                        ? 'PENDING'
                        : 'COMPLETED';
                    ref
                        .read(tasksNotifierProvider.notifier)
                        .updateTaskStatus(task.taskid, newStatus);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: task.status == 'COMPLETED'
                          ? const Color(0x1F4ADE80)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: task.status == 'COMPLETED'
                            ? const Color(0x5F4ADE80)
                            : const Color(0xFF2A2440),
                      ),
                    ),
                    child: Icon(
                      task.status == 'COMPLETED'
                          ? Icons.check_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: task.status == 'COMPLETED'
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
            right: 16,
            child: Text(
              task.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                decoration: task.status == 'COMPLETED'
                    ? TextDecoration.lineThrough
                    : null,
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
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        size: 12, color: Colors.white38),
                    const SizedBox(width: 4),
                    Text(
                      deadlineText,
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
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
