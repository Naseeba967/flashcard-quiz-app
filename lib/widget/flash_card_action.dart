import 'package:flutter/material.dart';

class FlashCardAction extends StatelessWidget {
  const FlashCardAction({
    required this.text,
    required this.color,
    required this.icon,
    super.key,
  });
  final Color color;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      height: 30,
      width: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Icon(icon), Text(text)],
      ),
    );
  }
}
