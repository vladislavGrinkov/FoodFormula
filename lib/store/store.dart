import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:scan_food/store/reducer.dart';

@immutable
class AppState {
  final List<dynamic> list;
  final List<dynamic> saveList;

  AppState(this.list, this.saveList);

  AppState.initialState()
      : list = [],
        saveList = [];
}

final Store<AppState> store = Store<AppState>(
  reducer,
  initialState: AppState.initialState(),
);
