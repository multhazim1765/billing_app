import 'package:vibration/vibration.dart';

Future<void> vibrateOnScan() async {
  final hasVibrator = await Vibration.hasVibrator();
  if (hasVibrator == true) {
    await Vibration.vibrate();
  }
}
