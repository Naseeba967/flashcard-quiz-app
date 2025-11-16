import 'package:flutter/material.dart';
import 'dart:math' as math;

class FlashCardWidget extends StatefulWidget {
  final String question;
  final String answer;
  final bool showAnswer;

  const FlashCardWidget({
    super.key,
    required this.question,
    required this.answer,
    required this.showAnswer,
  });

  @override
  State<FlashCardWidget> createState() => _FlashCardWidgetState();
}

class _FlashCardWidgetState extends State<FlashCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(FlashCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAnswer != widget.showAnswer) {
      if (widget.showAnswer) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final angle = _animation.value * math.pi;
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle);

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: angle < math.pi / 2
                ? _buildFront()
                : Transform(
                    transform: Matrix4.identity()..rotateY(math.pi),
                    alignment: Alignment.center,
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _buildCard(
      title: 'Question',
      content: widget.question,
      color: Colors.blue,
      icon: Icons.help_outline,
    );
  }

  Widget _buildBack() {
    return _buildCard(
      title: 'Answer',
      content: widget.answer,
      color: Colors.green,
      icon: Icons.check_circle_outline,
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              content,
              style: const TextStyle(fontSize: 18, height: 1.4),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
