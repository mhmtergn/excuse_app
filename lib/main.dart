import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:translator/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Excuses App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Excuses Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map> _excuses = [];

  final translator = GoogleTranslator();

  String _translatedString = '';

  Future<void> _veriGetir() async {
    //daha detayli kullanim icin https://excuser.herokuapp.com/

    _translatedString = '';
    _excuses = [];
    setState(() {});

    final answer = await get(Uri(
      host: 'excuser.herokuapp.com',
      scheme: 'https',
      pathSegments: ['v1', 'excuse'],
    ));

    // JSON =>

    _excuses = (jsonDecode(answer.body) as List).cast();
    setState(() {});
  }

  @override
  void initState() {
    _veriGetir();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: [
          IconButton(onPressed: _veriGetir, icon: const Icon(Icons.refresh))
        ],
        backgroundColor: Colors.black,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: _excuses.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: <Widget>[
                  for (final excuse in _excuses)
                    Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Category: ${excuse['category']}"
                                .toUpperCase()),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              excuse['excuse']!,
                              style: Theme.of(context).textTheme.headline5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(
                    height: 50,
                  ),
                  if (_translatedString.isNotEmpty)
                    Card(
                      elevation: 10,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          _translatedString,
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_excuses != null) {
            final excuse = _excuses.first;
            translator.translate(excuse['excuse'], to: 'tr').then((translate) {
              _translatedString = translate.text;
              setState(() {});
            });
          }
        },
        tooltip: 'Translate',
        child: const Icon(Icons.translate),
      ),
    );
  }
}
