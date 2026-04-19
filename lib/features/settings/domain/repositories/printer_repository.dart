import '../../../../core/models/printer_device.dart';

abstract class PrinterRepository {
  Future<List<PrinterDevice>> scanDevices();
  Future<bool> connect(String macAddress);
  Future<bool> disconnect();
  bool get isConnected;
  String? getSavedPrinterMac();
  String? getSavedPrinterName();
  Future<void> savePrinterData(String mac, String name);
  Future<void> clearPrinterData();
  Future<void> testPrint(String shopName);
  Future<void> printReceipt({
    required String shopName,
    required String address1,
    required String address2,
    required String phone,
    required List<Map<String, dynamic>> items,
    required double total,
    required String footer,
  });
}
