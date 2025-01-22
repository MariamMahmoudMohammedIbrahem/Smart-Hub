part of 'drawer_screen.dart';

abstract class DrawerListController extends State<DrawerList> {

  bool isThemeExpanded = false; // Controls the expand/collapse
  bool isConnectionExpanded = false;
  bool isSettingsExpanded = false;
  late final SharedPreferences prefs;

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPackages();
  }
}