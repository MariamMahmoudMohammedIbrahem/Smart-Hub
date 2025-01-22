import 'package:smart_hub/commons.dart';

void toastFun(String title, bool isDark) {
  Fluttertoast.cancel();
  Fluttertoast.showToast(
    msg: title,
    gravity: ToastGravity.BOTTOM,
    backgroundColor: isDark ? Colors.white24 : Colors.black87 ,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
