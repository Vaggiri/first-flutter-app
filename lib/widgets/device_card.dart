import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeviceCard extends StatelessWidget {
  final BluetoothDevice device;
  final VoidCallback onTap;

  const DeviceCard({
    super.key,
    required this.device,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.devices, size: 36),
        title: Text(
          device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          device.remoteId.toString(),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    ).animate().scaleXY(
          begin: 0.9,
          end: 1,
          curve: Curves.easeOutBack,
        );
  }
}