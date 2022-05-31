import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Barcodes {
  Future<List<dynamic>> findBarcode(String scanQr) async {
    final String response = await rootBundle.loadString('assets/barcodes.json');
    Map data = await json.decode(response);

    List<dynamic> findQrCode = data['barcodes'];
    final object =
        findQrCode.where((element) => element['_ipcean'] == scanQr).toList();
    return object;
  }
}

class Barcode {
  late int _id;
  late String _ipcean;
  late String _name;
  late String _brandName;

  Barcode(this._id, this._ipcean, this._name, this._brandName);

  Map<dynamic, dynamic> getFrom() {
    return {
      _id: this._id,
      _ipcean: this._name,
      _name: this._name,
      _brandName: this._brandName,
    };
  }
}

class AddItemAction {
  final Barcode item;

  AddItemAction(this.item);
}
