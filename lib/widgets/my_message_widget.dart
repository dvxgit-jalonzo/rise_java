import 'package:flutter/material.dart';

class MyMessageWidget extends StatefulWidget {
  const MyMessageWidget({super.key});

  @override
  State<MyMessageWidget> createState() => _MyMessageWidgetState();
}

class _MyMessageWidgetState extends State<MyMessageWidget> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        automaticallyImplyLeading: true,
      ),
      body: const Text("This is messages"),
    );
  }
}
