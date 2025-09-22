class Item {
  final int id;
  final String body;
  final bool completed;

  Item({required this.id, required this.body, this.completed = false});

  Item copyWith({int? id, String? body, bool? completed}) {
    return Item(
      id: id ?? this.id,
      body: body ?? this.body,
      completed: completed ?? this.completed,
    );
  }

  Item.fromjson(Map json)
    : body = json['body'],
      id = json['id'],
      completed = json['completed'];

  Map tojson() => {'id': id, 'body': body, 'completed': completed};
}

class AppState {
  final List<Item> items;

  AppState({required this.items});

  AppState.initialState() : items = List.unmodifiable(<Item>[]);

  AppState.fromJson(Map json)
    : items = (json['items'] as List).map((i) => Item.fromjson(i)).toList();

  Map tojson() => {'items': items};

  @override
  String toString() {
    return tojson().toString();
  }
}
