import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scan_food/common/barcodes.dart';
import 'package:scan_food/main.dart';
import 'package:scan_food/pages/receipts.dart';
import 'package:scan_food/pages/scan_food.dart';
import 'package:scan_food/pages/shooping_cart.dart';
import 'package:scan_food/pages/store_scans.dart';
import 'package:scan_food/services/generate_stars.dart';
import 'package:scan_food/store/actions.dart';
import 'package:scan_food/store/store.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  Widget _scanQr = ScanQr();
  Widget _storeScans = StoreScans();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  double _confidence = 1.0;
  bool _isOpenStore = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void didUpdateWidget(covariant Home oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("FoodFormula"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              showBarModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 800,
                    color: Colors.white,
                    child: Center(
                      child: StoreConnector<AppState, AppState>(
                        converter: (store) => store.state,
                        builder: (context, state) => ListView(
                          children: [
                            const Center(
                              child: Padding(
                                child: Text(
                                  'Избранное',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Corben',
                                  ),
                                ),
                                padding: EdgeInsets.only(top: 20, bottom: 20),
                              ),
                            ),
                            ...generateReceiptsSaves(state.saveList),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.favorite_rounded),
            ),
          )
        ],
      ),
      floatingActionButton: AvatarGlow(
        animate: _isListening, // true
        glowColor: Theme.of(context).primaryColor,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      bottomNavigationBar: SizedBox(
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: this._selectedIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: "Рецепты",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: "Сканирование",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_sharp),
              label: "Мои продукты",
            ),
          ],
          onTap: (int index) {
            this.onTapHandler(index);
          },
        ),
      ),
      body: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) => getBody(state.list, _isOpenStore),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) => print('on status: ${val}'),
        onError: (err) => print('on Error: ${err}'),
        debugLogging: true,
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          localeId: 'ru_RU',
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            store.dispatch(
              AddItem(
                getArrFromString(_text),
              ),
            );
            _text = '';
            if (val.hasConfidenceRating && val.confidence > 0) {
              _confidence = val.confidence;
            }
          }),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _text = '';
      });
      _speech.stop();
    }
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
      store.dispatch(
        AddItem(
          await Barcodes().findBarcode(barcodeScanRes),
        ),
      );
    });
  }

  List<dynamic> getArrFromString(String text) {
    return text
        .split(' ')
        .toSet()
        .toList()
        .map(
          (val) => {
            "id": 20,
            "_upcean": "none",
            "_name": val.characters.first.toUpperCase() + val.substring(1),
            "_brandName": 'none',
          },
        )
        .toList();
  }

  Widget getBody(List<dynamic> listScans, bool isOpenStore) {
    if (isOpenStore) {
      return ShoopingCard();
    }
    if (_selectedIndex == 0) {
      return Receipts(listScans);
    } else if (_selectedIndex == 1) {
      return Container();
    } else {
      return StoreScans();
    }
  }

  void onTapHandler(int index) {
    this.setState(
      () {
        _selectedIndex = index;
        _isOpenStore = false;
        if (index == 1) {
          scanBarcodeNormal();
        }
      },
    );
  }

  List<Widget> generateReceiptsSaves(List<dynamic> saveList) {
    return saveList
        .map(
          (item) => Card(
            semanticContainer: true,
            margin: EdgeInsets.all(10),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: Container(
              height: 120,
              child: Row(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(0),
                      child: Image.network(
                        item['recipe']['img'],
                        height: 150,
                        width: MediaQuery.of(context).size.width / 2.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: ListTile(
                              title: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item['recipe']['label']}',
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 10),
                                child: Row(
                                  children:
                                      generateStars(item['recipe']['raiting']),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                TextButton(
                                  child: const Text(
                                    'Подробнее',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  onPressed: () {
                                    openModal(
                                      item['recipe']['ingredientLines'],
                                    );
                                  },
                                ),
                                TextButton(
                                  child: Icon(Icons.remove_sharp),
                                  onPressed: () {
                                    deleteFavorite(
                                        item['recipe']['label'], saveList);
                                  }, // add item in store
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        )
        .toList();
  }

  void deleteFavorite(dynamic name, List<dynamic> list) {
    var findItem =
        list.where((item) => !(item['recipe']['label'] == name)).toList();
    store.dispatch(RemoveFavorite(findItem));
  }

  void openModal(List<dynamic> ingredients) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          title: Text("Рецепт"),
          content: Container(
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: getIngredientLines(ingredients),
            ),
          ),
        );
      },
    );
  }

  List<Widget> getIngredientLines(List<dynamic> ingredients) {
    return ingredients
        .map(
          (name) => Column(
            children: [
              Text(name),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        )
        .toList();
  }
}
