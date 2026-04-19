import 'package:app_settings/app_settings.dart';

Future<bool> openBluetoothSettings() async {
  await AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
  return true;
}
