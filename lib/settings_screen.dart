import 'package:flutter/material.dart';
import 'package:flutter_barcode_sdk/dynamsoft_barcode.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _is1dChecked = true;
  bool _isQrChecked = true;
  bool _isPdf417Checked = true;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // override the pop action
      onWillPop: () async {
        int format = 0;
        if (_is1dChecked) {
          format |= BarcodeFormat.ONED;
        }
        if (_isQrChecked) {
          format |= BarcodeFormat.QR_CODE;
        }
        if (_isPdf417Checked) {
          format |= BarcodeFormat.PDF417;
        }
        Navigator.pop(context, {'format': format});
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: <Widget>[
            CheckboxListTile(
              title: const Text('1D Barcode'),
              value: _is1dChecked,
              onChanged: (bool? value) {
                setState(() {
                  _is1dChecked = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('QR Code'),
              value: _isQrChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isQrChecked = value!;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('PDF417'),
              value: _isPdf417Checked,
              onChanged: (bool? value) {
                setState(() {
                  _isPdf417Checked = value!;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
