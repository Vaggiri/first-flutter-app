import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothManager {
  static const String serviceUUID = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static const String characteristicUUID = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static final Guid _serviceUuid = Guid(serviceUUID);
  static final Guid _characteristicUuid = Guid(characteristicUUID);

  static final StreamController<String> _messageStreamController = 
      StreamController<String>.broadcast();
  static Stream<String> get onMessageReceived => _messageStreamController.stream;

  static Future<void> checkPermissions() async {
    await FlutterBluePlus.turnOn();
  }

  static Future<void> startScan() async {
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 10),
      oneByOne: true,
    );
  }

  static Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  static Future<void> connectToDevice(BluetoothDevice device) async {
    await device.connect(autoConnect: false);
    await device.discoverServices();
    
    final services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid == _serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == _characteristicUuid) {
            await characteristic.setNotifyValue(true);
            characteristic.lastValueStream.listen((value) {
              if (value.isNotEmpty) {
                _messageStreamController.add(String.fromCharCodes(value));
              }
            });
            break;
          }
        }
        break;
      }
    }
  }

  static Future<void> sendMessage(BluetoothDevice device, String message) async {
    final services = await device.discoverServices();
    for (var service in services) {
      if (service.uuid == _serviceUuid) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid == _characteristicUuid) {
            await characteristic.write(message.codeUnits);
            break;
          }
        }
        break;
      }
    }
  }

  static Future<void> disconnectDevice(BluetoothDevice device) async {
    await device.disconnect();
  }
}