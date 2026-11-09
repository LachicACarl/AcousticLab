import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE Central service for discovering and connecting to compatible earbuds.
///
/// This service intentionally does not assume vendor-specific UUIDs. Most
/// commercial earbuds use proprietary GATT services for ANC, EQ, touch
/// controls, and case battery. Those controls can only be implemented once
/// the target earbud's advertised services and protocol are known.
class BluetoothService {
  BluetoothService._();

  static final BluetoothService instance = BluetoothService._();

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  final StreamController<List<ScanResult>> _resultsController =
      StreamController<List<ScanResult>>.broadcast();

  BluetoothDevice? _device;
  bool _isScanning = false;

  Stream<List<ScanResult>> get scanResults => _resultsController.stream;
  BluetoothDevice? get connectedDevice => _device;
  bool get isScanning => _isScanning;

  Stream<BluetoothConnectionState>? get connectionState {
    final device = _device;
    return device?.connectionState;
  }

  Future<BluetoothAdapterState> getAdapterState() async {
    return FlutterBluePlus.adapterState.first;
  }

  Future<void> startScan({
    Duration timeout = const Duration(seconds: 12),
  }) async {
    if (_isScanning) return;

    final state = await getAdapterState();
    if (state != BluetoothAdapterState.on) {
      throw StateError('Bluetooth is not turned on.');
    }

    await _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        _resultsController.add(results);
      },
      onError: (Object error, StackTrace stackTrace) {
        _resultsController.addError(error, stackTrace);
      },
    );

    _isScanning = true;
    try {
      await FlutterBluePlus.startScan(timeout: timeout);
    } catch (_) {
      _isScanning = false;
      rethrow;
    }

    FlutterBluePlus.isScanning.listen((scanning) {
      _isScanning = scanning;
    });
  }

  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
    _isScanning = false;
  }

  Future<void> connect(BluetoothDevice device) async {
    if (_device?.remoteId == device.remoteId) return;

    await disconnect();
    _device = device;

    try {
      await device.connect(
        license: License.free,
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );
      await device.discoverServices();
    } catch (_) {
      _device = null;
      rethrow;
    }
  }

  Future<List<BluetoothServiceData>> discoverServices() async {
    final device = _device;
    if (device == null) {
      throw StateError('No BLE device is connected.');
    }

    final services = await device.discoverServices();
    return services
        .map(
          (service) => BluetoothServiceData(
            uuid: service.serviceUuid.toString(),
            characteristics: service.characteristics
                .map(
                  (characteristic) => BluetoothCharacteristicData(
                    uuid: characteristic.characteristicUuid.toString(),
                    canRead: characteristic.properties.read,
                    canWrite: characteristic.properties.write ||
                        characteristic.properties.writeWithoutResponse,
                    canNotify: characteristic.properties.notify ||
                        characteristic.properties.indicate,
                  ),
                )
                .toList(growable: false),
          ),
        )
        .toList(growable: false);
  }

  Future<List<int>> readCharacteristic({
    required Guid serviceUuid,
    required Guid characteristicUuid,
  }) async {
    final characteristic = await _findCharacteristic(
      serviceUuid,
      characteristicUuid,
    );
    if (!characteristic.properties.read) {
      throw StateError('This characteristic does not support reads.');
    }
    return characteristic.read();
  }

  Future<void> writeCharacteristic({
    required Guid serviceUuid,
    required Guid characteristicUuid,
    required List<int> value,
    bool withoutResponse = false,
  }) async {
    final characteristic = await _findCharacteristic(
      serviceUuid,
      characteristicUuid,
    );

    final canWrite = withoutResponse
        ? characteristic.properties.writeWithoutResponse
        : characteristic.properties.write;
    if (!canWrite) {
      throw StateError('This characteristic does not support that write type.');
    }

    await characteristic.write(
      value,
      withoutResponse: withoutResponse,
    );
  }

  Future<BluetoothCharacteristic> _findCharacteristic(
    Guid serviceUuid,
    Guid characteristicUuid,
  ) async {
    final device = _device;
    if (device == null) {
      throw StateError('No BLE device is connected.');
    }

    final services = await device.discoverServices();
    for (final service in services) {
      if (service.serviceUuid == serviceUuid) {
        for (final characteristic in service.characteristics) {
          if (characteristic.characteristicUuid == characteristicUuid) {
            return characteristic;
          }
        }
      }
    }

    throw StateError(
      'Characteristic $characteristicUuid was not found in service $serviceUuid.',
    );
  }

  Future<void> disconnect() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    final current = _device;
    _device = null;

    if (current != null) {
      try {
        await current.disconnect();
      } catch (_) {
        // A device may already have disconnected; treat this as cleanup.
      }
    }
  }

  Future<void> dispose() async {
    await stopScan();
    await disconnect();
    await _scanSubscription?.cancel();
    await _resultsController.close();
  }
}

class BluetoothServiceData {
  const BluetoothServiceData({
    required this.uuid,
    required this.characteristics,
  });

  final String uuid;
  final List<BluetoothCharacteristicData> characteristics;
}

class BluetoothCharacteristicData {
  const BluetoothCharacteristicData({
    required this.uuid,
    required this.canRead,
    required this.canWrite,
    required this.canNotify,
  });

  final String uuid;
  final bool canRead;
  final bool canWrite;
  final bool canNotify;
}
