# Flutter Barcode, QR Code and PDF417 Scanner

A Flutter project that demonstrates how to use [Dynamsoft Barcode Reader SDK](https://www.dynamsoft.com/barcode-reader/overview/) to scan 1D barcodes, QR codes and PDF417 in web browser, Android and Windows.

## Supported Platforms
- Flutter Web
    ```bash
    flutter run -d chrome
    ```
- Flutter Android
    ```bash
    flutter run
    ```
- Flutter Windows
    ```bash
    flutter run -d windows
    ```

## Getting Started
1. Apply for a [30-day trial license](https://www.dynamsoft.com/customer/license/trialLicense/?product=dbr) of Dynamsoft Barcode Reader and replace the license key in the `main.dart` file with your own:

    ```dart
    await _barcodeReader.setLicense(
        'DLS2eyJoYW5kc2hha2VDb2RlIjoiMjAwMDAxLTE2NDk4Mjk3OTI2MzUiLCJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSIsInNlc3Npb25QYXNzd29yZCI6IndTcGR6Vm05WDJrcEQ5YUoifQ==');
    ```

2. Run the project:

    ![Flutter web barcode, QR code, and PDF417 scanner](https://www.dynamsoft.com/codepool/img/2023/02/flutter-web-barcode-qr-pdf417-scanner.png)
    
## Try Online Demo
[https://yushulx.me/flutter-web-barcode-qrcode-pdf417-scanner](https://yushulx.me/flutter-web-barcode-qrcode-pdf417-scanner)


![flutter web barcode qr scanner](https://www.dynamsoft.com/codepool/img/2023/02/barcode-qrcode-pdf417-scanner.gif)