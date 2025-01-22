
import '../commons.dart';

void alertFunBLE(
    BuildContext context, String title, String descrip, AlertType alertType) {
  Alert(
    context: context,
    type: alertType,
    title: title,
    desc: descrip,
    style: const AlertStyle(
      backgroundColor: Color(0x9929283A),
      alertElevation: 30,
      animationType: AnimationType.grow,
      alertBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(30),
        ),
      ),
      titleStyle: TextStyle(
        color: Colors.white, // Set the title color here
        fontSize: 24, // Adjust the font size if necessary
        fontWeight: FontWeight.bold,
      ),
      descStyle: TextStyle(
        color: Colors.white70, // Set the description text color here
        fontSize: 16,
      ),
    ),
    buttons: [
      DialogButton(
        color: Colors.white12,
        onPressed: () {
          Navigator.pop(context);
        },
        radius: BorderRadius.circular(20),
        width: 100,
        child: const Text(
          "Ok",
          style: TextStyle(color: Color(0xFFd5d1dd), fontSize: 20),
        ),
      ),
      DialogButton(
        color: Colors.white12,
        onPressed: () {
          AppSettings.openAppSettings(type: AppSettingsType.bluetooth);
        },
        radius: BorderRadius.circular(20),
        width: 130,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Settings",
              style: TextStyle(color: Color(0xFFd5d1dd), fontSize: 20),
            ),
            SizedBox(
              width: 3,
            ),
            Icon(
              Icons.settings,
              size: 21,
            ),
          ],
        ),
      )
    ],
  ).show();
}

