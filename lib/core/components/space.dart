import 'package:flutter/material.dart';

class SpaceHeight extends StatelessWidget {
  final double height;
  final Widget? child;
  const SpaceHeight(this.height, {super.key, this.child});

  @override
  Widget build(BuildContext context) => SizedBox(height: height, child: child);
}

class SpaceWidth extends StatelessWidget {
  final double width;
  final Widget? child;
  const SpaceWidth(this.width, {super.key, this.child});

  @override
  Widget build(BuildContext context) => SizedBox(width: width, child: child);
}
