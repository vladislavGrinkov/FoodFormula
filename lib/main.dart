import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:scan_food/common/barcodes.dart';
import 'package:scan_food/common/base_barcodes.dart';
import 'package:scan_food/common/theme.dart';
import 'package:scan_food/pages/home.dart';
import 'package:scan_food/pages/store_scans.dart';
import 'package:scan_food/store/store.dart';

void main() {
  runApp(
    Main(
      store: store,
    ),
  );
}

class Main extends StatelessWidget {
  final Store<AppState> store;

  Main({Key? key, required this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppState>(
      store: store,
      child: MaterialApp(
        theme: appTheme,
        home: Home(),
      ),
    );
  }
}
