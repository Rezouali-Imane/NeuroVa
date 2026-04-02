import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_chat_bubble/chat_bubble.dart' as fcb;

class ChatBubble extends StatefulWidget {
  final String text;
  final String time;
  final bool isMe;
  final Duration delay;
  const ChatBubble({
    super.key,
    required this.text,
    required this.time,
    required this.isMe,
    this.delay = Duration.zero,
  });

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;

  double _sharedBubbleWidth(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.60;
  }

  Future<void> _startEntrance() async {
    _entranceController
      ..stop()
      ..value = 0;
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (!mounted) return;
    _entranceController.forward();
  }

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startEntrance());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startEntrance());
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Widget _buildMetaReveal(Widget child) {
    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, metaChild) {
        final metaAnim = CurvedAnimation(
          parent: _entranceController,
          curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
        );
        return Opacity(opacity: metaAnim.value, child: metaChild);
      },
    );
  }

  Widget _buildReceiverBubble(BuildContext context) {
    return Container(
      width: _sharedBubbleWidth(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0x3BA2ADD0),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
          bottomLeft: Radius.circular(8),
        ),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          _buildMetaReveal(
            Text(
              widget.time,
              style: const TextStyle(
                color: Color(0xFFF8B878),
                fontSize: 11,
                fontFamily: 'Syne',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenderBubble(BuildContext context) {
    return Container(
      width: _sharedBubbleWidth(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0x73C8A2C8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(8),
          bottomLeft: Radius.circular(28),
        ),
        border: Border.fromBorderSide(
          BorderSide(color: Color(0x1FFFFFFF), width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Syne',
              fontWeight: FontWeight.w500,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 4),
          _buildMetaReveal(
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  widget.time,
                  style: const TextStyle(
                    color: Color(0xFFF8B878),
                    fontSize: 11,
                    fontFamily: 'Syne',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.done_all, size: 16, color: Color(0xFFF8B878)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.isMe ? 0.18 : 0.0;
    final entranceAnim = CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );
    final child = widget.isMe
        ? _buildSenderBubble(context)
        : _buildReceiverBubble(context);

    return AnimatedBuilder(
      animation: _entranceController,
      child: child,
      builder: (context, bubbleChild) {
        final dx = (widget.isMe ? 20.0 : -20.0) * (1 - entranceAnim.value);
        final scale = 0.97 + (0.03 * entranceAnim.value);
        return Opacity(
          opacity: entranceAnim.value,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.scale(
              scale: scale,
              child: bubbleChild,
            ),
          ),
        );
      },
    );
  }
}

class TypingBubble extends StatefulWidget {
  final Duration delay;

  const TypingBubble({
    super.key,
    this.delay = Duration.zero,
  });

  @override
  State<TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<TypingBubble>
  with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _breathController;
  late final AnimationController _appearController;

  Future<void> _startTypingSequence() async {
    _appearController
      ..stop()
      ..value = 0;
    _controller.stop();
    _breathController.stop();

    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (!mounted) return;
    _appearController.forward();
    _controller.repeat();
    _breathController.repeat(reverse: true);
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTypingSequence());
  }

  @override
  void reassemble() {
    super.reassemble();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startTypingSequence());
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_appearController, _breathController]),
      child: fcb.ChatBubble(
        clipper: fcb.ChatBubbleClipper9(type: fcb.BubbleType.receiverBubble),
        alignment: Alignment.topLeft,
        backGroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Container(
          width: 60,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: const BoxDecoration(
            color: Color(0xFF252535),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
              bottomRight: Radius.circular(50),
              bottomLeft: Radius.circular(4),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Dot(controller: _controller, start: 0.0, end: 0.6),
              Dot(controller: _controller, start: 0.2, end: 0.8),
              Dot(controller: _controller, start: 0.4, end: 1.0),
            ],
          ),
        ),
      ),
      builder: (context, child) {
        final appear = CurvedAnimation(
          parent: _appearController,
          curve: Curves.easeOutCubic,
        ).value;
        final breathe = 1.0 + (0.03 * _breathController.value);
        final scale = (0.96 + (0.04 * appear)) * breathe;
        return Opacity(
          opacity: appear,
          child: Transform.scale(scale: scale, child: child),
        );
      },
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({
    super.key,
    required this.controller,
    required this.start,
    required this.end,
  });

  final AnimationController controller;
  final double start;
  final double end;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      child: Container(
        width: 7,
        height: 7,
        decoration: const ShapeDecoration(
          color: Color(0xFFD9D9D9),
          shape: OvalBorder(),
        ),
      ),
      builder: (context, child) {
        final anim = CurvedAnimation(
          parent: controller,
          curve: Interval(start, end, curve: Curves.easeInOut),
        );
        final pulse = 0.35 + (0.65 * anim.value);
        return Opacity(opacity: pulse, child: child);
      },
    );
  }
}

class FigmaChatMock extends StatelessWidget {
  const FigmaChatMock({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Center(
        child: SizedBox(
          width: 354.50,
          height: 206.10,
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(354.50, 206.10),
                painter: _FigmaChatPainter(),
              ),
              Positioned(
                left: 8,
                top: 54,
                child: SizedBox(
                  width: 36.46,
                  height: 24,
                  child: Text(
                    '12:55',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF8B878),
                      fontSize: 11,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 42.03,
                top: 24.17,
                child: SizedBox(
                  width: 175,
                  height: 28.33,
                  child: Text(
                    'Merge sort runs in O(n log n)  here\'s why that beats bubble sort every time…',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 298,
                top: 130,
                child: SizedBox(
                  width: 23,
                  height: 14,
                  child: Text(
                    '1:43',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFF8B878),
                      fontSize: 11,
                      fontFamily: 'Syne',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 320.50,
                top: 134,
                child: const Icon(
                  Icons.done_all,
                  size: 14,
                  color: Color(0xFFF8B878),
                ),
              ),
              Positioned(
                left: 141.03,
                top: 99,
                child: SizedBox(
                  width: 237.47,
                  height: 48.26,
                  child: Transform.rotate(
                    angle: math.pi,
                    child: const Text(
                      'Can you make me a 7-day study plan?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontFamily: 'Syne',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 34.03,
                top: 192.26,
                child: Transform.rotate(
                  angle: math.pi,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 60.03,
                top: 190.26,
                child: Transform.rotate(
                  angle: math.pi,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 47.03,
                top: 192.26,
                child: Transform.rotate(
                  angle: math.pi,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFD9D9D9),
                      shape: OvalBorder(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FigmaChatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Left (receiver) bubble
    paint.color = const Color(0xFF363A4D);
    final r1 = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 8, 230, 96), const Radius.circular(36));
    canvas.drawRRect(r1, paint);

    final tail1 = Path()
      ..moveTo(22, 48)
      ..quadraticBezierTo(12, 42, 8, 54)
      ..quadraticBezierTo(12, 66, 22, 60)
      ..close();
    canvas.drawPath(tail1, paint);
 final r2Rect = Rect.fromLTWH(136.5, 88, 197, 58);
    final gradient = const LinearGradient(
      colors: [Color(0xFF7E647F), Color(0xFFB284BE)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final paint2 = Paint()..shader = gradient.createShader(r2Rect);
    canvas.drawRRect(RRect.fromRectAndRadius(r2Rect, const Radius.circular(30)), paint2);

    final tail2 = Path()
      ..moveTo(r2Rect.right - 28, r2Rect.top + 24)
      ..quadraticBezierTo(r2Rect.right - 14, r2Rect.top + 18, r2Rect.right - 6, r2Rect.top + 26)
      ..quadraticBezierTo(r2Rect.right - 14, r2Rect.top + 36, r2Rect.right - 28, r2Rect.top + 32)
      ..close();
    canvas.drawPath(tail2, paint2);

    paint.color = const Color(0xFF363A4D);
    final typing = RRect.fromRectAndRadius(const Rect.fromLTWH(18, 168, 90, 36), const Radius.circular(20));
    canvas.drawRRect(typing, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
