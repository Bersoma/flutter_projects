import 'dart:async';
import 'dart:convert';

import 'package:redux/redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:todo/model/model.dart';
import 'package:todo/redux/actions.dart';

List<Middleware<AppState>> appStateMiddleware([
  AppState state = const AppState(items: []),
]) {
  final loadItems = _loadFromPrefs(state);
  final saveItems = _saveToPrefs(state);

  return [
    TypedMiddleware<AppState, AddItemAction>(saveItems).call,
    TypedMiddleware<AppState, RemoveItemAction>(saveItems).call,
    TypedMiddleware<AppState, RemoveItemsAction>(saveItems).call,
    TypedMiddleware<AppState, GetItemsAction>(loadItems).call,
  ];
}

Middleware<AppState> _loadFromPrefs(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    loadFromPrefs().then(
      (state) => store.dispatch(LoadedItemsAction(state.items)),
    );
  };
}

Middleware<AppState> _saveToPrefs(AppState state) {
  return (Store<AppState> store, action, NextDispatcher next) {
    next(action);

    saveToPrefs(store.state);
  };
}

void savetoPrefs(AppState state) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var String = json.encode(state.tojson());
  await preferences.setString('itemsState', String);
}

Future<AppState> loadFromPrefs() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  var String = preferences.getString('itemsState');
  if (String != null) {
    Map map = json.decode(String);
    return AppState.fromJson(map);
  }
  return AppState.initialState();
}

void appStateMiddleware(
  Store<AppState> store,
  action,
  NextDispatcher next,
) async {
  if (action is AddItemAction ||
      action is RemoveItemAction ||
      action is RemoveItemsAction) {
    savetoPrefs(store.state);
  }

  if (action is GetItemsAction) {
    await loadFromPrefs().then(
      (state) => store.dispatch(LoadedItemsAction(state.items)),
    );
  }
}
