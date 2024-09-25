import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

void alertFun(
    BuildContext context, String title, String descrip, AlertType alertType) {
  Alert(
    context: context,
    type: alertType,
    title: title,
    desc: descrip,
    style: AlertStyle(
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
      titleStyle: const TextStyle(
        color: Colors.white, // Set the title color here
        fontSize: 24, // Adjust the font size if necessary
        fontWeight: FontWeight.bold,
      ),
      descStyle: const TextStyle(
        color: Colors.white70, // Set the description text color here
        fontSize: 16,
      ),
    ),
    buttons: [
      DialogButton(
        color: Colors.white12,
        onPressed: () => Navigator.pop(context),
        radius: BorderRadius.circular(20),
        width: 120,
        child: const Text(
          "Ok",
          style: TextStyle(color: Color(0xFFd5d1dd), fontSize: 20),
        ),
      )
    ],
  ).show();
}

void errorCheck(BuildContext context, String errorMessage) {
  if (errorMessage == 'email-already-in-use') {
    /* show the pop up window */
    alertFun(
        context, 'Error', 'This Email is already in use!', AlertType.warning);
  } else if (errorMessage == 'weak-password') {
    alertFun(context, 'Error', 'Password must be more than 6 characters!',
        AlertType.warning);
  } else if (errorMessage == 'invalid-credential') {
    alertFun(context, 'Error', 'Email is not registered on this app!',
        AlertType.error);
  } else if (errorMessage == 'invalid-email') {
    alertFun(context, 'Error', 'Invalid Email!', AlertType.error);
  } else if (errorMessage == 'channel-error') {
    alertFun(context, 'Error', 'Empty Field!', AlertType.error);
  } else if (errorMessage == 'NotAvailable') {
    alertFun(
        context,
        'Error',
        'No Authentication Available\nUse your Email and Password!',
        AlertType.error);
  } else if (errorMessage == 'Timeout') {
    alertFun(context, 'Connection Timeout',
        'Bad internet connection\nPlease try again later!', AlertType.warning);
  } else if (errorMessage == 'SubjectMessageClear') {
    alertFun(
        context,
        'Empty Subject or Message',
        'Please ensure that all necessary containers have been properly filled!',
        AlertType.warning);
  } else if (errorMessage == 'SpeedClear') {
    alertFun(
        context,
        'Empty Container',
        'Please ensure that you have entered a correct speed integer value within range of 0 - 500 Km/h!',
        AlertType.warning);
  } else if (errorMessage == 'BLE') {
    alertFun(
        context,
        'Permission Error',
        'Please enable the access for location and bluetooth and then try again!',
        AlertType.warning);
  } else if (errorMessage == 'BLE_OFF') {
    alertFun(context, 'Bluetooth issue', 'Please turn on your bluetooth!',
        AlertType.warning);
  } else {
    alertFun(
      context,
      'Error',
      'Unknown error!\n try again',
      AlertType.error,
    );
  }
}

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
