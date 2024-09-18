import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ble_test extends StatefulWidget {
  const ble_test({super.key});

  @override
  State<ble_test> createState() => _ble_testState();
}

class _ble_testState extends State<ble_test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [ElevatedButton(onPressed: () {}, child: Container())],
    ));
  }
}
