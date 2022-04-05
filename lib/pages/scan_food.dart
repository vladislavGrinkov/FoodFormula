import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scan_food/common/barcodes.dart';
import 'package:scan_food/common/theme.dart';
import 'package:scan_food/main.dart';
import 'package:scan_food/pages/store_scans.dart';
import 'package:scan_food/store/actions.dart';
import 'package:scan_food/store/store.dart';

class ScanQr extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<ScanQr> {
  String _scanBarcode = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;

    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Cancel',
        true,
        ScanMode.BARCODE,
      );
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Возникла ошибка.';
    }

    if (!mounted) return;

    setState(() async {
      _scanBarcode = barcodeScanRes;
      store.dispatch(
        AddItem(
          await Barcodes().findBarcode(_scanBarcode),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Flex(
        direction: Axis.vertical,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => scanBarcodeNormal(),
            child: Text('Сканировать'),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Результат сканирования: $_scanBarcode\n',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
