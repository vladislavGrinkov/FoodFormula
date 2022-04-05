import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:scan_food/common/theme.dart';
import 'package:scan_food/main.dart';
import 'package:scan_food/pages/receipts.dart';
import 'package:scan_food/store/actions.dart';
import 'package:scan_food/store/store.dart';

class StoreScans extends StatefulWidget {
  @override
  _StoreScansState createState() => _StoreScansState();
}

class _StoreScansState extends State<StoreScans> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (context, state) {
          return ListView(
            children: generatedScans(state.list),
          );
        },
      ),
    );
  }

  List<Widget> generatedScans(List<dynamic> listScans) {
    return listScans
        .map(
          (item) => Card(
            elevation: 5,
            semanticContainer: true,
            margin: const EdgeInsets.all(10),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.fastfood,
                color: Colors.blueGrey,
              ),
              trailing: IconButton(
                onPressed: () => _removeItem(item['_name'], listScans),
                icon: const Icon(Icons.delete),
              ),
              title: Text('${item['_name']}'),
            ),
          ),
        )
        .toList();
  }

  void _removeItem(String name, List<dynamic> list) {
    var findItem = list.where((item) => !(item['_name'] == name)).toList();
    store.dispatch(RemoveItem(findItem));
  }
}
