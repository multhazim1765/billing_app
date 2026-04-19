import 'package:equatable/equatable.dart';

class PrinterDevice extends Equatable {
  final String name;
  final String macAddress;

  const PrinterDevice({
    required this.name,
    required this.macAddress,
  });

  @override
  List<Object?> get props => [name, macAddress];
}
