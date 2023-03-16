import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';
import 'dart:ui' as ui;
import 'overlay_painter.dart';

class ScannerScreenMobile extends StatefulWidget {
  final FlutterBarcodeSdk barcodeReader;

  const ScannerScreenMobile({super.key, required this.barcodeReader});

  @override
  State<ScannerScreenMobile> createState() => _ScannerScreenMobileState();
}

class _ScannerScreenMobileState extends State<ScannerScreenMobile> {
  late FlutterBarcodeSdk _barcodeReader;
  late List<CameraDescription> _cameras;
  CameraController? _controller;
  final List<String> _cameraNames = [''];
  List<BarcodeResult>? _results;
  Size? _previewSize;
  bool _isScanAvailable = true;

  @override
  void initState() {
    super.initState();
    _barcodeReader = widget.barcodeReader;
    initCamera();
  }

  Future<void> toggleCamera(int index) async {
    if (_controller != null) _controller!.dispose();

    _controller = CameraController(_cameras[index], ResolutionPreset.max);
    _controller!.initialize().then((_) {
      if (!mounted) {
        return;
      }

      _previewSize = _controller!.value.previewSize;
      setState(() {});

      startVideo();
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> initCamera() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      toggleCamera(0);
    } on CameraException catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      stopVideo();
      _controller!.dispose();
    }
    _controller = null;
    super.dispose();
  }

  Widget getCameraWidget() {
    if (!_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    } else {
      // https://stackoverflow.com/questions/49946153/flutter-camera-appears-stretched
      final size = MediaQuery.of(context).size;
      var scale = size.aspectRatio * _controller!.value.aspectRatio;

      if (scale < 1) scale = 1 / scale;

      return Transform.scale(
        scale: scale,
        child: Center(
          child: CameraPreview(_controller!),
        ),
      );
    }
  }

  List<BarcodeResult> rotate90(List<BarcodeResult> input) {
    List<BarcodeResult> output = [];
    for (BarcodeResult result in input) {
      int x1 = result.x1;
      int x2 = result.x2;
      int x3 = result.x3;
      int x4 = result.x4;
      int y1 = result.y1;
      int y2 = result.y2;
      int y3 = result.y3;
      int y4 = result.y4;

      BarcodeResult newResult = BarcodeResult(
          result.format,
          result.text,
          _previewSize!.height.toInt() - y1,
          x1,
          _previewSize!.height.toInt() - y2,
          x2,
          _previewSize!.height.toInt() - y3,
          x3,
          _previewSize!.height.toInt() - y4,
          x4,
          result.angle,
          result.barcodeBytes);

      output.add(newResult);
    }

    return output;
  }

  void stopVideo() async {
    await _controller!.stopImageStream();
  }

  void startVideo() async {
    await _controller!.startImageStream((CameraImage availableImage) async {
      assert(defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
      int format = ImagePixelFormat.IPF_NV21.index;

      switch (availableImage.format.group) {
        case ImageFormatGroup.yuv420:
          format = ImagePixelFormat.IPF_NV21.index;
          break;
        case ImageFormatGroup.bgra8888:
          format = ImagePixelFormat.IPF_ARGB_8888.index;
          break;
        default:
          format = ImagePixelFormat.IPF_RGB_888.index;
      }

      if (!_isScanAvailable) {
        return;
      }

      _isScanAvailable = false;

      _barcodeReader
          .decodeImageBuffer(
              availableImage.planes[0].bytes,
              availableImage.width,
              availableImage.height,
              availableImage.planes[0].bytesPerRow,
              format)
          .then((results) {
        if (MediaQuery.of(context).size.width <
            MediaQuery.of(context).size.height) {
          if (Platform.isAndroid) {
            results = rotate90(results);
          }
        }
        setState(() {
          _results = results;
        });

        _isScanAvailable = true;
      }).catchError((error) {
        _isScanAvailable = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // override the pop action
        onWillPop: () async {
          // stopVideo();
          _controller!.dispose();
          _controller = null;
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
                          _controller == null || _previewSize == null
                              ? Image.asset(
                                  'images/default.png',
                                )
                              : SizedBox(
                                  width: MediaQuery.of(context).size.width <
                                          MediaQuery.of(context).size.height
                                      ? _previewSize!.height
                                      : _previewSize!.width,
                                  height: MediaQuery.of(context).size.width <
                                          MediaQuery.of(context).size.height
                                      ? _previewSize!.width
                                      : _previewSize!.height,
                                  child: CameraPreview(_controller!)),
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
              ],
            ),
          ),
        ));
  }
}
