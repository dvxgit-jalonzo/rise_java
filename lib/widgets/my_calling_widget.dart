import 'package:flutter/material.dart';

class MyCallingWidget extends StatefulWidget {
  const MyCallingWidget({super.key});

  @override
  State<MyCallingWidget> createState() => _MyCallingWidgetState();
}

class _MyCallingWidgetState extends State<MyCallingWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calling"),
        automaticallyImplyLeading: true,
      ),
      body:  const Center(
        child: Text("Calling",
          style: TextStyle(
            fontSize: 20,
            color: Colors.green,
            fontWeight: FontWeight.bold
          ),
        ),
      )
    );
  }
}
