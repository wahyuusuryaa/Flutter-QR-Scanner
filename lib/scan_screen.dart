import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const ScanScreen({super.key, required this.toggleTheme});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Point the camera at the QR Code!', style: TextStyle(fontSize: 18),),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      await controller.pauseCamera();
      if (scanData.code != null) {
        _launchURL(scanData.code!);
      }
    });
  }

  void _launchURL(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (uri.scheme.isEmpty) {
        // Tambahkan skema jika tidak ada
        final newUri = Uri.parse('https://$url');
        if (await canLaunchUrl(newUri)) {
          await launchUrl(newUri, mode: LaunchMode.externalApplication);
          controller?.resumeCamera();
        } else {
          throw 'Could not launch $newUri';
        }
      } else {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          controller?.resumeCamera();
        } else {
          throw 'Could not launch $uri';
        }
      }
    } else {
      throw 'Could not parse URL: $url';
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}