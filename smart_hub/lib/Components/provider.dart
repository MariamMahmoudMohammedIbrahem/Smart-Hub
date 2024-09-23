import 'package:flutter/material.dart';

class ScreenDataProvider extends ChangeNotifier {
  bool _isDeviceConnected = false;
  bool _isThemeDark = true;

  bool get isDeviceConnected => _isDeviceConnected;
  bool get isThemeDark => _isThemeDark;

  void updateConnection() {
    _isDeviceConnected = !_isDeviceConnected;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this data
  }

  void updateTheme() {
    _isThemeDark = !_isThemeDark;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this data
  }
}
