import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';
import 'dart:ui' as ui;
import 'overlay_painter.dart';

class ScannerScreen extends StatefulWidget {
  final FlutterBarcodeSdk barcodeReader;

  const ScannerScreen({super.key, required this.barcodeReader});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late FlutterBarcodeSdk _barcodeReader;
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  bool _isCameraReady = false;
  String _selectedItem = '';
  final List<String> _cameraNames = [''];
  bool _loading = true;
  List<BarcodeResult>? _results;

  @override
  void initState() {
    super.initState();
    _barcodeReader = widget.barcodeReader;
    initCamera();
  }

  void _toggleLoading() {
    setState(() {
      _loading = !_loading;
    });
  }

  Future<void> toggleCamera(int index) async {
    _isCameraReady = false;
    if (_controller != null) _controller!.dispose();

    _controller = CameraController(_cameras[index], ResolutionPreset.max);
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _isCameraReady = true;

      setState(() {});

      decodeFrames();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            // Handle access errors here.
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });

    setState(() {
      _selectedItem = _cameras[index].name;
    });
  }

  Future<void> initCamera() async {
    _cameras = await availableCameras();

    if (_cameras.isEmpty) return;

    _cameraNames.clear();
    for (CameraDescription description in _cameras) {
      _cameraNames.add(description.name);
    }
    _selectedItem = _cameraNames[0];
    _loading = false;

    toggleCamera(0);
  }

  Future<void> decodeFrames() async {
    if (_controller == null || !_isCameraReady) return;

    Future.delayed(const Duration(milliseconds: 20), () async {
      XFile file = await _controller!.takePicture();

      _results = await _barcodeReader.decodeFile(file.path);
      setState(() {});
      decodeFrames();
    });
  }

  @override
  void dispose() {
    if (_controller != null) _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // override the pop action
        onWillPop: () async {
          _controller!.dispose();
          _controller = null;
          _isCameraReady = false;
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Scanner'),
          ),
          body: Center(
            child: Stack(
              children: <Widget>[
                SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Stack(
                        children: [
                          _controller == null
                              ? Image.asset(
                                  'images/default.png',
                                )
                              : SizedBox(
                                  width: 640,
                                  height: 480,
                                  child: CameraPreview(
                                    _controller!,
                                  )),
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            bottom: 0.0,
                            left: 0.0,
                            child: _results == null || _results!.isEmpty
                                ? Container(
                                    color: Colors.black.withOpacity(0.1),
                                    child: const Center(
                                      child: Text(
                                        'No barcode detected',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ))
                                : createOverlay(_results!),
                          ),
                        ],
                      ),
                    )),
                Align(
                    alignment:
                        _loading ? Alignment.center : Alignment.topCenter,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : DropdownButton<String>(
                            value: _selectedItem,
                            items: _cameraNames
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              int index = _cameraNames.indexOf(newValue!);
                              toggleCamera(index);
                            },
                          )),
              ],
            ),
          ),
        ));
  }
}
