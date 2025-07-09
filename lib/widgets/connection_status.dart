import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ConnectionStatus extends StatelessWidget {
  final BluetoothDevice? device;

  const ConnectionStatus({super.key, this.device});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Icon(
            Icons.bluetooth,
            size: 20,
            color: device != null ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            device != null ? 'Connected' : 'Disconnected',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: device != null ? Colors.green : Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}