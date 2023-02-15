import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';
import 'package:flutter_barcode_sdk/flutter_barcode_sdk.dart';
import 'package:image_picker/image_picker.dart';

import 'overlay_painter.dart';

class ReaderScreen extends StatefulWidget {
  final FlutterBarcodeSdk barcodeReader;

  const ReaderScreen({super.key, required this.barcodeReader});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  late FlutterBarcodeSdk _barcodeReader;
  final _imagePicker = ImagePicker();
  String? _file;
  List<BarcodeResult>? _results;
  GlobalKey imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _barcodeReader = widget.barcodeReader;
  }

  Widget getImage() {
    if (_file != null) {
      Image image = kIsWeb
          ? Image.network(
              _file!,
            )
          : Image.file(
              File(_file!),
            );
      return image;
    }
    return Image.asset(
      'images/default.png',
    );
  }

  void getImageSizeAndPosition() {
    if (imageKey.currentContext == null) return;

    RenderBox? imageBox =
        imageKey.currentContext!.findRenderObject() as RenderBox;
    Size imageSize = imageBox.size;
    Offset imagePosition = imageBox.localToGlobal(Offset.zero);
    print('Image Size: $imageSize, offset: $imagePosition');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reader'),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                child: FittedBox(
                  key: imageKey,
                  fit: BoxFit.contain,
                  child: Stack(
                    children: [
                      getImage(),
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
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                    height: 100,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ElevatedButton(
                              onPressed: () async {
                                XFile? pickedFile;
                                if (kIsWeb ||
                                    Platform.isWindows ||
                                    Platform.isLinux) {
                                  const XTypeGroup typeGroup = XTypeGroup(
                                    label: 'images',
                                    extensions: <String>['jpg', 'png'],
                                  );
                                  pickedFile = await openFile(
                                      acceptedTypeGroups: <XTypeGroup>[
                                        typeGroup
                                      ]);
                                } else if (Platform.isAndroid ||
                                    Platform.isIOS) {
                                  pickedFile = await _imagePicker.pickImage(
                                      source: ImageSource.gallery);
                                }

                                if (pickedFile != null) {
                                  _file = pickedFile.path;
                                  _results =
                                      await _barcodeReader.decodeFile(_file!);
                                  setState(() {});
                                }
                              },
                              child: const Text('Load Image')),
                        ]))),
          ],
        ),
      ),
    );
  }
}
