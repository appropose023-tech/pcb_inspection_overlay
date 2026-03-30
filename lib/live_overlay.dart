import 'package:flutter/material.dart';
import 'models.dart';

class LiveOverlay extends StatelessWidget {
  final List<PCBDefect> defects;
  final double scaleX;
  final double scaleY;

  const LiveOverlay({
    super.key,
    required this.defects,
    required this.scaleX,
    required this.scaleY,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: defects.map((d) {
        return Positioned(
          left: d.x * scaleX,
          top: d.y * scaleY,
          width: d.w * scaleX,
          height: d.h * scaleY,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
          ),
        );
      }).toList(),
    );
  }
}
