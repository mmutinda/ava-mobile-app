import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedGraphLoader extends StatefulWidget {
  final double maxY; // Maximum height of the bars
  final int barCount; // Number of bars
  final EdgeInsetsGeometry padding; // Padding around the loader
  final Duration animationDuration; // Duration of the up-and-down animation

  const AnimatedGraphLoader({
    Key? key,
    this.maxY = 20,
    this.barCount = 6,
    this.padding = const EdgeInsets.all(16.0),
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  _AnimatedGraphLoaderState createState() => _AnimatedGraphLoaderState();
}

class _AnimatedGraphLoaderState extends State<AnimatedGraphLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _animations = List.generate(
      widget.barCount,
      (index) => Tween<double>(
        begin: widget.maxY * (0.6 + Random().nextDouble() * 0.2),
        end: widget.maxY * (0.9 + Random().nextDouble() * 0.1),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      )),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return Flexible(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 15,
                      height: _animations[index].value,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade900.withOpacity(0.3),
                            Colors.cyan.withOpacity(0.3),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 8,
                      width: 30,
                      color: Colors.grey.shade300,
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
