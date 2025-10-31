import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MaterialApp(home: StarWarsData()));
}

class StarWarsData extends StatefulWidget {
  const StarWarsData({super.key});

  @override
  State<StarWarsData> createState() => _StarWarsDataState();
}

class _StarWarsDataState extends State<StarWarsData> {
  final String url = "https://swapi.dev/api/starships";
  late List data;

  Future<String> getSWData() async {
    var res = await http.get(
      Uri.encodeFull(url) as Uri,
      headers: {"Accept": "application/json"},
    );

    setState(() {
      var resBody = jsonDecode(res.body);
      data = resBody["results"];
    });

    return "Success!";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Star Wars Starship"),
        backgroundColor: Colors.amberAccent,
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text('Name:'),
                          Text(
                            data[index]["name"],
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text("Model:"),
                          Text(
                            data[index]["model"],
                            style: TextStyle(fontSize: 18.0, color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: <Widget>[
                          Text("Cargo Capacity:"),
                          Text(
                            data[index]["cargo_capacity"],
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getSWData();
  }
}
