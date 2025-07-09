import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:app2/widgets/device_card.dart';
import 'package:app2/widgets/scan_button.dart';
import 'package:app2/chat_screen.dart';
import 'package:app2/utils/bluetooth_manager.dart';
import 'package:app2/widgets/connection_status.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<BluetoothDevice> _devices = [];
  bool _isScanning = false;
  BluetoothDevice? _connectedDevice;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _setupBluetoothListeners();
  }

  void _checkPermissions() async {
    await BluetoothManager.checkPermissions();
  }

  void _setupBluetoothListeners() {
    FlutterBluePlus.onScanResults.listen((results) {
      if (_isScanning) {
        setState(() {
          _devices = results.map((r) => r.device).toList();
          _devices = _devices.where((d) => d.platformName.isNotEmpty).toList();
          _devices = _devices.toSet().toList(); // Remove duplicates
        });
      }
    });

    // FIX: connectedDevices is already a Future<List<BluetoothDevice>>
    Future(() async {
      final connectedDevices = FlutterBluePlus.connectedDevices;
      if (connectedDevices.isNotEmpty) {
        setState(() {
          _connectedDevice = connectedDevices.first;
        });
        _navigateToChatScreen(connectedDevices.first);
      }
    });

    // FIX: BluetoothState.disconnected is not a valid adapter state
    // Use BluetoothState.off to detect if Bluetooth is turned off
    FlutterBluePlus.state.listen((state) {
      if (state == BluetoothState.off) {
        setState(() {
          _connectedDevice = null;
        });
      }
    });
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
      _devices.clear();
    });

    await BluetoothManager.startScan();

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    });
  }

  void _stopScan() {
    BluetoothManager.stopScan();
    setState(() => _isScanning = false);
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      await BluetoothManager.connectToDevice(device);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to connect: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToChatScreen(BluetoothDevice device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(device: device),
      ),
    ).then((_) {
      setState(() {
        _connectedDevice = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Chat'),
        actions: [
          ConnectionStatus(device: _connectedDevice),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _devices.isEmpty && !_isScanning
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth,
                          size: 80,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No devices found',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap the scan button to discover nearby devices',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _devices.length,
                    itemBuilder: (context, index) {
                      return DeviceCard(
                        device: _devices[index],
                        onTap: () => _connectToDevice(_devices[index]),
                      ).animate().fadeIn(delay: (100 * index).ms);
                    },
                  ),
          ),
          ScanButton(
            isScanning: _isScanning,
            onPressed: _isScanning ? _stopScan : _startScan,
          ),
        ],
      ),
    );
  }
}