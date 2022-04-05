import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:html/parser.dart';
import 'package:redux/redux.dart';
import 'package:scan_food/common/theme.dart';
import 'package:http/http.dart' as http;
import 'package:scan_food/main.dart';
import 'package:scan_food/pages/home.dart';
import 'package:scan_food/services/compareTwoArr.dart';
import 'package:scan_food/services/generate_stars.dart';
import 'package:scan_food/services/unique_ingredients.dart';
import 'package:scan_food/store/actions.dart';
import 'package:scan_food/store/store.dart';

class Receipts extends StatefulWidget {
  List<dynamic> params = [];

  Receipts(this.params);

  List<dynamic> getParamsOfList() {
    if (params.isEmpty) return [];
    return params.map((item) => item['_name'] ?? '').toList();
  }

  @override
  _ReceiptsState createState() => _ReceiptsState(getParamsOfList());
}

class _ReceiptsState extends State<Receipts> {
  var _store = [];
  var queryP = '';
  var variants = [];

  _ReceiptsState(this.variants);

  @override
  void initState() {
    super.initState();
    getReceipts();
  }

  @override
  Widget build(BuildContext context) {
    print("STORE BUILD ${queryP}");
    return Center(
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: generateReceipts(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> generateReceipts() {
    return _store
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
                                  children: generateStars(
                                    item['recipe']['raiting'],
                                  ),
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
                                  child: Icon(Icons.add_box),
                                  onPressed: () {
                                    addReceiptInStore(item);
                                  }, // add item in store
                                ),
                                const SizedBox(
                                  width: 8,
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

  void addReceiptInStore(dynamic receipt) {
    store.dispatch(AddFavorite([receipt]));
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

  void getReceipts() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/receipts.json',
      );

      Map data = await json.decode(response);
      List<dynamic> receipts = data['hints'];

      final indredients = receipts
          .where(
            (rec) => compareTwoArr(rec['recipe']['ingredientLines'], variants),
          )
          .toList();

      print("indredients: ${indredients}");

      setState(() {
        _store = uniqueIngredients(indredients);
      });
    } catch (e) {
      print(e);
    }
  }
}
