import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ScanButton extends StatelessWidget {
  final bool isScanning;
  final VoidCallback onPressed;

  const ScanButton({
    super.key,
    required this.isScanning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isScanning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            else
              const Icon(Icons.bluetooth, size: 20),
            const SizedBox(width: 8),
            Text(
              isScanning ? 'Scanning...' : 'Scan Devices',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ).animate().shake(
            hz: isScanning ? 2 : 0,
            curve: Curves.easeInOut,
          ),
    );
  }
}