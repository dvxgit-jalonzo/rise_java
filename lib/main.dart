import 'dart:async';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_awesome_alert_box/flutter_awesome_alert_box.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:rise_java/api/my_controllers.dart';
import 'package:rise_java/my_flutter_background_service.dart';
import 'package:rise_java/my_http_overrides.dart';
import 'package:rise_java/my_request_permissions.dart';
import 'package:rise_java/widgets/my_dial_screen_widget.dart';
import 'package:rise_java/my_general_configurations.dart';



void main() async
{
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  await requestCameraPermission();
  await requestMicrophonePermission();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _hasQrCode = false;

  @override
  void initState() {
    super.initState();
    _initializeQrCheck();
  }

  Future<void> _initializeQrCheck() async {
    bool status = await MyGeneralConfigurations().isAlreadyHaveQrCode(); // Handle null case
    if (!mounted) return;
    setState(() {
      _hasQrCode = status;
    });

    if (_hasQrCode) {
      _navigateToDialPad();
    } else {
      _scanQRCode();
    }
  }
  void _navigateToDialPad() async {
    await initializeService();
    Future.microtask(() {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyDialPadWidget()),
      );
    });
  }

  Future<void> _scanQRCode() async {
    String result;
    try {
      result = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", // Scan button color (hex)
        "Cancel", // Cancel button text
        true, // Show flash icon
        ScanMode.QR, // Scan mode (QR, BARCODE, DEFAULT)
      );
    } catch (e) {
      result = "Failed to scan QR code";
    }

    if (!mounted) return;

    if (MyGeneralConfigurations().verifyQr(result)) {
      await MyGeneralConfigurations().saveVerifiedQr(result);
      await MyControllers().storageLoad();
      SuccessAlertBox(
        context: context,
        title: "Success!",
        messageText: "QR Code verified",
      );
      _navigateToDialPad();
    } else {
      WarningAlertBox(
        context: context,
        title: "Warning!",
        messageText: "QR Code is incorrect.",
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: _hasQrCode
          ? const Text("Redirecting to Dial Pad...")
            : const CircularProgressIndicator(),
      ),
    );
  }
}
