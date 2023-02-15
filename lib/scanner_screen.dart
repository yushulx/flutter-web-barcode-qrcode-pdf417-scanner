import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';

class ScannerScreen extends StatefulWidget {
  final FlutterBarcodeSdk barcodeReader;

  const ScannerScreen({super.key, required this.barcodeReader});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late FlutterBarcodeSdk _barcodeReader;

  @override
  void initState() {
    super.initState();
    _barcodeReader = widget.barcodeReader;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
