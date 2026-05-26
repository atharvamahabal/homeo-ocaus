import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final String backendIp;
  SettingsState({required this.backendIp});
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  static const String _boxName = 'settingsBox';
  static const String _ipKey = 'backendIp';
  static const String _defaultIp = '192.168.68.101';

  SettingsNotifier() : super(SettingsState(backendIp: _defaultIp)) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = await Hive.openBox(_boxName);
    final savedIp = box.get(_ipKey, defaultValue: _defaultIp);
    state = SettingsState(backendIp: savedIp);
  }

  Future<void> updateIp(String newIp) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_ipKey, newIp);
    state = SettingsState(backendIp: newIp);
  }
}
