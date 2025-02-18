import 'package:flutter/material.dart';

class MyCallHistoryWidget extends StatefulWidget {
  const MyCallHistoryWidget({super.key});

  @override
  State<MyCallHistoryWidget> createState() => _MyCallHistoryWidgetState();
}

class _MyCallHistoryWidgetState extends State<MyCallHistoryWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Call History"),
          automaticallyImplyLeading: true,
        ),
      body: const Text("This is call history"),
    );
  }
}
