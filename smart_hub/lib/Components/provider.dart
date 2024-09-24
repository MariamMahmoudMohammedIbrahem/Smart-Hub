import 'package:flutter/material.dart';

class ScreenDataProvider extends ChangeNotifier {
  bool _isDeviceConnected = false;
  bool _isThemeDark = true;

  bool get isDeviceConnected => _isDeviceConnected;
  bool get isThemeDark => _isThemeDark;

  void updateConnection(bool isConnected) {
    _isDeviceConnected = isConnected;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this data
  }

  void updateTheme(bool isDark) {
    _isThemeDark = isDark;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this data
  }
}
