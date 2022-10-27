import 'dart:convert';

import 'package:apiconflutter/models/Gif.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Gif>> _listadoGifs;

  Future<List<Gif>> _getGifs() async {
    final response = await http.get(Uri.parse(
        "https://api.giphy.com/v1/gifs/trending?api_key=ZgrwEHU3FjyVgTWV8c5VUfTsugsGexTJ&limit=10&rating=g"));

    List<Gif> gifs = [];

    if (response.statusCode == 200) {
      //me aseguro que lo de codifico en UTF8, sólo para asegurar que todo este en castellano
      String body = utf8.decode(response.bodyBytes);
      //convertimos el body en un objeto Json
      final jsonData = jsonDecode(body);
      // print(jsonData["data"][0]["type"]);

      for (var item in jsonData["data"]) {
        gifs.add(Gif(item["title"], item["images"]["downsized"]["url"]));
      }

      return gifs;
    } else {
      throw Exception("Falló la conexión");
    }
  }

  @override
  void initState() {
    super.initState();
    _listadoGifs = _getGifs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              //return Text("data");

              // --return ListView(
              return GridView.count(
                  crossAxisCount: 4, // sólo con gridview
                  //permite eliminar restricciones en lista
                  // https://www.fluttercampus.com/guide/228/renderbox-was-not-laid-out-error/
                  shrinkWrap: true,
                  children: _listaGifs(snapshot.data));
            } else if (snapshot.hasError) {
              print(snapshot.error);
              return Text("error");
            }
            // retorno por defecto - circulito que carga algo
            return Center(child: CircularProgressIndicator());
          },
          future: _listadoGifs,
        ));
  }

  List<Widget> _listaGifs(data) {
    List<Widget> gifs = [];

    for (var gif in data) {
      gifs.add(Card(
          child: Column(
        children: [
          Expanded(child: Image.network(gif.url, fit: BoxFit.fill)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(gif.nombre),
          ),
        ],
      )));
    }
    return gifs;
  }
}
