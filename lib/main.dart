import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'reader_screen.dart';
import 'scanner_screen.dart';
import 'settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
          title: 'Flutter Web Demo: Barcode, QR Code and PDF417 Scanner'),
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
  late FlutterBarcodeSdk _barcodeReader;
  bool _isSDKLoaded = false;

  @override
  void initState() {
    super.initState();

    initBarcodeSDK();
  }

  Future<void> initBarcodeSDK() async {
    _barcodeReader = FlutterBarcodeSdk();
    await _barcodeReader.setLicense(
        'DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==');
    await _barcodeReader.init();
    await _barcodeReader.setBarcodeFormats(BarcodeFormat.ALL);
    setState(() {
      _isSDKLoaded = true;
    });
  }

  _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _isSDKLoaded
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_isSDKLoaded == false) {
                        _showDialog('Error', 'Barcode SDK is not loaded.');
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReaderScreen(
                                  barcodeReader: _barcodeReader,
                                )),
                      );
                    },
                    child: const Text('Barcode Reader'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_isSDKLoaded == false) {
                        _showDialog('Error', 'Barcode SDK is not loaded.');
                        return;
                      }

                      if (!kIsWeb) {
                        _showDialog('Error',
                            'Barcode Scanner is only supported on Web.');
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ScannerScreen(
                                  barcodeReader: _barcodeReader,
                                )),
                      );
                    },
                    child: const Text('Barcode Scanner'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      text: 'Loading ',
                      style: const TextStyle(fontSize: 16),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Dynamsoft Barcode Reader',
                          style: const TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              launchUrlString(
                                  'https://www.dynamsoft.com/barcode-reader/sdk-javascript/');
                            },
                        ),
                        const TextSpan(
                            text:
                                ' js and wasm files...The first time may take a few seconds.'),
                      ],
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_isSDKLoaded == false) {
            _showDialog('Error', 'Barcode SDK is not loaded.');
            return;
          }
          var result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
          int format = result['format'];
          await _barcodeReader.setBarcodeFormats(format);
        },
        tooltip: 'Settings',
        child: const Icon(Icons.settings),
      ),
    );
  }

  void launch(String s) {}
}
