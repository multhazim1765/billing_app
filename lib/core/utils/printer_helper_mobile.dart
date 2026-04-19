import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../models/printer_device.dart';

class EscPos {
  static const List<int> init = [0x1B, 0x40];
  static const List<int> alignCenter = [0x1B, 0x61, 0x01];
  static const List<int> alignLeft = [0x1B, 0x61, 0x00];
  static const List<int> alignRight = [0x1B, 0x61, 0x02];
  static const List<int> boldOn = [0x1B, 0x45, 0x01];
  static const List<int> boldOff = [0x1B, 0x45, 0x00];
  static const List<int> textNormal = [0x1D, 0x21, 0x00];
  static const List<int> textLarge = [0x1D, 0x21, 0x11];
  static const List<int> lineFeed = [0x0A];
}

class PrinterHelper {
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<bool> checkPermission() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  Future<List<PrinterDevice>> getBondedDevices() async {
    try {
      final list = await PrintBluetoothThermal.pairedBluetooths;
      return list
          .map((d) => PrinterDevice(name: d.name, macAddress: d.macAdress))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> connect(String macAddress) async {
    try {
      final result =
          await PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
      _isConnected = result;
      return result;
    } catch (_) {
      _isConnected = false;
      return false;
    }
  }

  Future<bool> disconnect() async {
    try {
      final result = await PrintBluetoothThermal.disconnect;
      _isConnected = !result;
      return result;
    } catch (_) {
      return false;
    }
  }

  Future<void> printText(String text) async {
    if (!_isConnected) return;

    final connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (!connectionStatus) return;

    await PrintBluetoothThermal.writeBytes(text.codeUnits);
  }

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
  }) async {
    if (!_isConnected) return;

    final bytes = <int>[];
    bytes.addAll(EscPos.init);

    bytes.addAll(EscPos.alignCenter);
    bytes.addAll(EscPos.boldOn);
    bytes.addAll(EscPos.textLarge);
    bytes.addAll(_textToBytes(shopName));
    bytes.addAll(EscPos.lineFeed);

    bytes.addAll(EscPos.textNormal);
    bytes.addAll(EscPos.boldOff);
    if (address1.isNotEmpty) {
      bytes.addAll(_textToBytes(address1));
      bytes.addAll(EscPos.lineFeed);
    }
    if (address2.isNotEmpty) {
      bytes.addAll(_textToBytes(address2));
      bytes.addAll(EscPos.lineFeed);
    }
    bytes.addAll(_textToBytes(phone));
    bytes.addAll(EscPos.lineFeed);

    final formattedDate = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.now());
    bytes.addAll(_textToBytes(formattedDate));
    bytes.addAll(EscPos.lineFeed);

    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(EscPos.lineFeed);

    bytes.addAll(EscPos.alignLeft);
    bytes.addAll(_textToBytes('Item            Price   Total'));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(EscPos.lineFeed);

    for (final item in items) {
      final name = item['name'].toString();
      final qty = item['qty'].toString();
      final price = item['price'].toString();
      final totalItem = item['total'].toString();

      var prefix = '$qty x $name';
      if (prefix.length > 16) prefix = prefix.substring(0, 16);

      final line = prefix.padRight(16) + price.padRight(8) + totalItem;
      bytes.addAll(_textToBytes(line));
      bytes.addAll(EscPos.lineFeed);
    }

    bytes.addAll(_textToBytes('--------------------------------'));
    bytes.addAll(EscPos.lineFeed);

    bytes.addAll(EscPos.alignRight);
    bytes.addAll(EscPos.boldOn);
    bytes.addAll(_textToBytes('TOTAL: $total'));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.boldOff);
    bytes.addAll(EscPos.lineFeed);

    bytes.addAll(EscPos.alignCenter);
    bytes.addAll(_textToBytes(footer));
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.lineFeed);
    bytes.addAll(EscPos.lineFeed);

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  List<int> _textToBytes(String text) {
    return List<int>.from(text.codeUnits);
  }
}
