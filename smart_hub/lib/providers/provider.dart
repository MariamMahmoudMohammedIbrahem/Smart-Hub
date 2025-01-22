
import '../commons.dart';

class ScreenDataProvider extends ChangeNotifier {

  bool _isThemeDark = true;

  bool get isThemeDark => _isThemeDark;



  void updateTheme(bool isDark) {
    _isThemeDark = isDark;
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this data
  }
}
