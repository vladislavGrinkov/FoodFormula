import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scan_food/main.dart';
import 'package:scan_food/services/generate_stars.dart';
import 'package:scan_food/store/actions.dart';
import 'package:scan_food/store/store.dart';

class ShoopingCard extends StatefulWidget {
  @override
  _ShoopingCardState createState() => _ShoopingCardState();
}

class _ShoopingCardState extends State<ShoopingCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) =>
            ListView(children: generateReceiptsSaves(state.saveList)),
      ),
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
                                  onPressed: () {},
                                ),
                                TextButton(
                                  child: Icon(Icons.remove_shopping_cart),
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
}
