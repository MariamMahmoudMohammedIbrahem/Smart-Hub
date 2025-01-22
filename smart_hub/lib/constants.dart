import 'package:flutter/material.dart';

/// animated colors*
const colorizeColors = [
  Colors.white,
  Colors.black,
  Colors.white,
  Colors.white,
  Colors.black,
  Colors.white,
];

const colorizeTextStyle = TextStyle(
  fontSize: 35.0,
  letterSpacing: 1,
  fontWeight: FontWeight.w900,
  fontFamily: 'Horizon',
);

/// battery constants*
/// Battery edge radius*
double edgeRadius = 2;

/// ble constants*
/// UUIDs for the HM-10 (replace with the correct UUIDs if different)*
String serviceUuid = "0000ffe0-0000-1000-8000-00805f9b34fb";
String txUuid =
    "0000ffe1-0000-1000-8000-00805f9b34fb"; // Tx characteristic UUID for writing

/// Container Radius *
double containerRadius = 30;
double statusCircleCardRadius = 80;

/// loading screen*
const loadingScreenColorizeColors = [
  Colors.white,
  Colors.grey,
  Colors.black,
  Colors.black,
  Colors.grey,
  Colors.black,
  Colors.black,
  Colors.grey,
];

/// version*
String version = 'v1.0.0';

/// Container Radius *

// double containerRadius = 30;
// double statusCircleCardRadius = 80;

/* Wireless charger constants */



/// Port A*
bool portA_ChannelOne_isConnected = true;
bool portA_ChannelTwo_isConnected = false;
/// Port B*
bool portC_ChannelOne_isConnected = true;
bool portC_ChannelTwo_isConnected = true;
/// Wireless Part*
double wirelessPower = 0;
/// -----------------Global Variables-------------------------*
// bool g_ScreenReady = false;
