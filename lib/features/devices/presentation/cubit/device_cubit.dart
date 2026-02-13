import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:finalproject/features/devices/domain/entities/user_device.dart';

class DeviceState {
  final List<UserDevice> devices;
  final bool isLoading;
  final String? error;

  DeviceState({this.devices = const [], this.isLoading = false, this.error});
}

class DeviceCubit extends Cubit<DeviceState> {
  DeviceCubit() : super(DeviceState()) {
    loadDevices();
  }

  Future<void> loadDevices() async {
    try {
      final box = await Hive.openBox<UserDevice>('user_devices');
      final devices = box.values.where((d) => d.isActive).toList();
      emit(DeviceState(devices: devices));
    } catch (e) {
      emit(DeviceState(error: e.toString()));
    }
  }

  Future<void> addDevice(UserDevice device) async {
    try {
      final box = await Hive.openBox<UserDevice>('user_devices');
      await box.add(device);
      loadDevices();
    } catch (e) {
      emit(DeviceState(error: e.toString()));
    }
  }

  Future<void> removeDevice(UserDevice device) async {
    try {
      await device.delete();
      loadDevices();
    } catch (e) {
      emit(DeviceState(error: e.toString()));
    }
  }

  Future<void> updateDevice(UserDevice device) async {
    try {
      await device.save();
      loadDevices();
    } catch (e) {
      emit(DeviceState(error: e.toString()));
    }
  }
}
