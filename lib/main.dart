import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:avatar_glow/avatar_glow.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

/*====================SPEECH TO TEXT==========================*/

class SpeechToText extends StatefulWidget {
  @override
  SpeechToTextState createState() => SpeechToTextState();
}

class SpeechToTextState extends State<SpeechToText> {
  stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speech to text'),
      ),
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Colors.blue,
        endRadius: 75.0,
        duration: const Duration(milliseconds: 2000),
        repeatPauseDuration: const Duration(milliseconds: 100),
        repeat: true,
        child: FloatingActionButton(
          onPressed: _listen,
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            _text,
            style: TextStyle(
              fontSize: 32.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

/*=====================BUSINESS LOGIC==========================*/
  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'listening') {
            setState(() {
              _isListening = true;
            });
          } else {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
          }),
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }
/*=============================================================*/
}
/*=============================================================*/

/*=======================LISTVIEW CLASS========================*/
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  var data;

  // Loading the data from the local .json file
  loadData() async {
    var jsonString = await rootBundle.loadString('lib/data/mock_data.json');
    setState(() => data = json.decode(jsonString));
  }

  @override
  void initState() {
    this.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("Curus Health"),
        ),
      ),
      body: ListView.builder(
        // Build the ListView
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.red],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: Offset(3, 1),
                )
              ],
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 10.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child:
                            Center(child: Image.network(data[index]['image'])),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            data[index]['gender'] == 'Male'
                                ? "Mr " +
                                    data[index]['first_name'] +
                                    " " +
                                    data[index]['last_name']
                                : "Ms " +
                                    data[index]['first_name'] +
                                    " " +
                                    data[index]['last_name'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.7,
                            child: Text(
                              data[index]['description'],
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: data == null ? 0 : data.length,
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 10.0,
        child: Icon(Icons.mic),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SpeechToText()),
          );
        },
      ),
    );
  }
}
/*============================================================*/
