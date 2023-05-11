import 'dart:convert';
import "package:clipboard/clipboard.dart";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController = TextEditingController();
  bool _visible = false;
  String shortenUrl = "Text";
  final FocusNode _focusNode = FocusNode();
  final formkey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Text("URL Shortener"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              Form(
                  key: formkey,
                  child: Column(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "URL:",
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color: Colors.grey[300],
                                border: Border.all()),
                            child: TextFormField(
                              focusNode: _focusNode,
                              style: TextStyle(fontSize: 20),
                              keyboardType: TextInputType.url,
                              controller: textEditingController,
                              decoration: InputDecoration(
                                  hintText: "Enter URL",
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      if (formkey.currentState!.validate()) {
                                        String urlField =
                                            textEditingController.text;
                                        _shorten(urlField);
                                      }
                                    },
                                    icon: Icon(
                                      CupertinoIcons.arrow_right_circle_fill,
                                      color: Colors.green[600],
                                      size: 35,
                                    ),
                                  ),
                                  icon: Icon(
                                    CupertinoIcons.link,
                                    color: Colors.black,
                                  )),
                              cursorColor: Colors.black,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "Enter a URL";
                                } else if (!RegExp(
                                        r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})')
                                    .hasMatch(value)) {
                                  return "Please enter a valid URL";
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 100,
                      ),
                      Visibility(
                        visible: _visible,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Container(
                            width: 400,
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.white54),
                            child: Column(
                              children: [
                                Text(
                                  "Link Generated",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(shortenUrl,
                                        style: TextStyle(
                                            fontSize: 30,
                                            color: Colors.green.shade500)),
                                    IconButton(
                                        onPressed: () {
                                          FlutterClipboard.controlC(shortenUrl);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                                  content: Text("Url Copied")));
                                        },
                                        icon: Icon(Icons.copy)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }

  void _shorten(String urlField) async {
    final url = "https://api.shrtco.de/v2/shorten?url=$urlField";
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    final body = response.body;
    final json = jsonDecode(body)['result'];
    setState(() {
      _visible = true;
    });
    shortenUrl = json["short_link"];
    print(shortenUrl);
  }
}
