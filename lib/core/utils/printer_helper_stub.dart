import '../models/printer_device.dart';

class PrinterHelper {
  static final PrinterHelper _instance = PrinterHelper._internal();
  factory PrinterHelper() => _instance;
  PrinterHelper._internal();

  bool get isConnected => false;

  Future<bool> checkPermission() async => false;

  Future<List<PrinterDevice>> getBondedDevices() async => const [];

  Future<bool> connect(String macAddress) async => false;

  Future<bool> disconnect() async => true;

  Future<void> printText(String text) async {}

  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
  }) async {}
}
