import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 60,
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      'Typing',
                      textStyle: Theme.of(context).textTheme.bodySmall,
                      speed: const Duration(milliseconds: 100),
                    ),
                  ],
                  repeatForever: true,
                ),
              ),
              const SizedBox(width: 4),
              SizedBox(
                width: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Animate(
                      effects: [
                        ScaleEffect(
                          duration: 600.ms,
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1.0, 1.0),
                        ),
                        ScaleEffect(
                          duration: 600.ms,
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(0.6, 0.6),
                        ),
                      ],
                      onPlay: (controller) => controller.repeat(),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Animate(
                      effects: [
                        ScaleEffect(
                          delay: 150.ms,
                          duration: 600.ms,
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1.0, 1.0),
                        ),
                        ScaleEffect(
                          duration: 600.ms,
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(0.6, 0.6),
                        ),
                      ],
                      onPlay: (controller) => controller.repeat(),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Animate(
                      effects: [
                        ScaleEffect(
                          delay: 300.ms,
                          duration: 600.ms,
                          begin: const Offset(0.6, 0.6),
                          end: const Offset(1.0, 1.0),
                        ),
                        ScaleEffect(
                          duration: 600.ms,
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(0.6, 0.6),
                        ),
                      ],
                      onPlay: (controller) => controller.repeat(),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}