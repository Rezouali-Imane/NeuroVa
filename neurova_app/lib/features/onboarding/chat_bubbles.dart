import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_chat_bubble/chat_bubble.dart' as fcb;

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isMe;
  const ChatBubble({super.key, required this.text, required this.time, required this.isMe});

  @override
  Widget build(BuildContext context) {
    if (!isMe) {
      // Receiver bubble
      return fcb.ChatBubble(
        clipper: fcb.ChatBubbleClipper9(type: fcb.BubbleType.receiverBubble),
        alignment: Alignment.topLeft,
        backGroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: const BoxDecoration(
            color: Color(0xFF363A4D),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w400,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                time,
                style: const TextStyle(
                  color: Color(0xFFF8B878),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Sender bubble
      return fcb.ChatBubble(
        clipper: fcb.ChatBubbleClipper9(type: fcb.BubbleType.sendBubble),
        alignment: Alignment.topRight,
        backGroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF7E647F), Color(0xFFB284BE)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontFamily: 'Syne',
                  fontWeight: FontWeight.w400,
                  height: 1.18,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      color: Color(0xFFF8B878),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.done_all, size: 16, color: Color(0xFFF8B878)),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }
  }

class TypingBubble extends StatelessWidget {
  const TypingBubble({super.key});
  @override
  Widget build(BuildContext context) {
    return fcb.ChatBubble(
      clipper: fcb.ChatBubbleClipper9(type: fcb.BubbleType.receiverBubble),
      alignment: Alignment.topLeft,
      backGroundColor: Colors.transparent,
      padding: EdgeInsets.zero,
      child: Container(
        width: 90,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF363A4D),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Dot(),
            const SizedBox(width: 4),
            Dot(),
            const SizedBox(width: 4),
            Dot(),
          ],
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  const Dot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.white54,
        shape: BoxShape.circle,
      ),
    );
  }
}

class FigmaChatMock extends StatelessWidget {
  const FigmaChatMock({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
            left: 136.50,
            top: 109,
            child: SizedBox(
              width: 197,
              child: Text(
                'Can you make me a 7-day study plan?',
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
