import 'package:scan_food/pages/home.dart';
import 'package:scan_food/services/unique_ingredients.dart';
import 'package:scan_food/services/unique_list.dart';
import 'package:scan_food/store/actions.dart';
import 'package:scan_food/store/store.dart';

AppState reducer(AppState state, dynamic action) {
  if (action is AddItem) {
    var arr = [...state.list, ...action.payload];
    return AppState([...uniqueList(arr)], state.saveList);
  } else if (action is RemoveItem) {
    return AppState(action.payload, state.saveList);
  } else if (action is AddFavorite) {
    var arr = [...state.saveList, ...action.payload];
    return AppState(state.list, [...uniqueIngredients(arr)]);
  } else if (action is RemoveFavorite) {
    return AppState(state.list, action.payload);
  }

  return state;
}
