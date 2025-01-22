part of 'settings_screen.dart';

abstract class SettingsController extends State<SettingsScreen> {
  bool isThemeExpanded = false; // Controls the expand/collapse
  final _myPreferences = Preferences();

  // @override
  // void initState() {
    // super.initState();
    // _myPreferences.initPackages();
  // }
}