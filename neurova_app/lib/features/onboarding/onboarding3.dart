import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'onboarding4.dart';

class Onboarding3 extends StatelessWidget {
  const Onboarding3({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 40),

                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      const Text(
                        "NEUROVA",
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: -35,
                        top: -30,
                        child: SvgPicture.asset(
                          'lib/features/onboarding/logo.svg',
                          width: 51,
                          height: 39,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChatMessageBubble(
                      message:
                          "Merge sort runs in O(n log n)  here's why that beats bubble sort every time…",
                      time: '12:55',
                      isSent: false,
                      backgroundColor: Color.fromRGBO(162, 173, 208, 0.23),
                      showDoubleCheck: false,
                    ),
                    const SizedBox(height: 10),

                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ChatMessageBubble(
                          message: "Can you make me a 7-day study plan?",
                          time: '12:56',
                          isSent: true,
                          backgroundColor: Color.fromRGBO(200, 162, 200, 0.45),
                          showDoubleCheck: true,
                        ),

                        Positioned(
                          left: -40,
                          bottom: 0,
                          child: Container(
                            width: 87,
                            height: 36.84,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 34,
                                  top: 23,
                                  child: Container(
                                    transform: Matrix4.identity()
                                      ..translate(0.0, 0.0)
                                      ..rotateZ(3.14),
                                    width: 7,
                                    height: 7,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 47,
                                  top: 23,
                                  child: Container(
                                    transform: Matrix4.identity()
                                      ..translate(0.0, 0.0)
                                      ..rotateZ(3.14),
                                    width: 7,
                                    height: 7,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 60,
                                  top: 21,
                                  child: Container(
                                    transform: Matrix4.identity()
                                      ..translate(0.0, 0.0)
                                      ..rotateZ(3.14),
                                    width: 7,
                                    height: 7,
                                    decoration: const ShapeDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: OvalBorder(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: 411,
                  height: 128,
                  child: const Text(
                    ' AI Assistant',
                    style: TextStyle(
                      color: Color(0xFFFFFFF0),
                      fontSize: 75,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w700,
                      height: 0.80,
                      letterSpacing: 0.35,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Transform.translate(
                  offset: const Offset(-35, 0),
                  child: SizedBox(
                    width: 343,
                    height: 80,
                    child: const Text(
                      'Get concept explanations, personalized study plans, and weakness analysis tailored to your major.',
                      style: TextStyle(
                        color: Color(0xFFFFFFF0),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        letterSpacing: 0.35,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Onboarding4(),
                      ),
                    );
                  },
                  child: Container(
                    width: 63.99,
                    height: 63.99,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFB284BE),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1000),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: Color(0x3F000000),
                          blurRadius: 50,
                          offset: Offset(0, 25),
                          spreadRadius: -12,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_forward_outlined,
                        color: Color.fromARGB(26, 15, 15, 15),
                        size: 20,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Container(
                  width: 74,
                  height: 6,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1000),
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
}

class ChatMessageBubble extends StatelessWidget {
  final String message;
  final String time;
  final bool isSent;
  final Color backgroundColor;
  final bool showDoubleCheck;

  ChatMessageBubble({
    Key? key,
    required this.message,
    required this.time,
    required this.isSent,
    required this.backgroundColor,
    this.showDoubleCheck = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: isSent
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isSent ? 16 : 0),
              bottomRight: Radius.circular(isSent ? 0 : 16),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: isSent
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Color(0xFFF8B878),
                        fontSize: 11,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              if (showDoubleCheck) const SizedBox(width: 4),
              if (showDoubleCheck)
                const Icon(Icons.done_all, size: 14, color: Color(0xFFF8B878)),
            ],
          ),
        ),
      ],
    );
  }
}
