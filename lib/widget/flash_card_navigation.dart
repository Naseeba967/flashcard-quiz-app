import 'package:flutter/material.dart';

class FlashCardNavigation extends StatelessWidget {
  const FlashCardNavigation({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
  });

  final String text;
  final Icon icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: onPressed,
            color: onPressed != null
                ? Colors.black.withValues(alpha: 0.7)
                : Colors.black.withValues(alpha: 0.3),
            icon: icon,
          ),
          Text(
            text,
            style: TextStyle(
              color: onPressed != null
                  ? Colors.black.withValues(alpha: 0.7)
                  : Colors.black.withValues(alpha: 0.3),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
