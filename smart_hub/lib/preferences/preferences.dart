import '../commons.dart';

late final SharedPreferences prefs;

class Preferences {
/*
  Title: Save in Local Storage
  Description: This function uses shared preference package to
  save data
   */
  Future<void> saveToLocalStorage(bool screenTheme) async {
    await prefs.setBool('Theme', screenTheme); // save the device id
  }

  Future<void> initPackages() async {
      prefs = await SharedPreferences.getInstance();
    /* keeps listening to the connection */
  }
}