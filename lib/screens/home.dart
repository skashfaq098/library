import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:library_app/screens/books.dart';
import 'package:library_app/main.dart';
import 'package:library_app/searchservice.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var queryResultSet = [];
  var tempSearchStore = [];

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }

    var capitalizedValue =
        value.substring(0, 1).toUpperCase() + value.substring(1);

    if (queryResultSet.length == 0 && value.length == 1) {
      SearchService().searchByName(value).then(( QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; ++i) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['title'].startsWith(capitalizedValue)) {
          setState(() {
            tempSearchStore.add(element);
          });
        }
      });
    }
  }

  bool _hasSpeech = false;
  String lastWords = "";
  String lastError = "";
  String lastStatus = "";
  final SpeechToText speech = SpeechToText();
  final _formkey = GlobalKey<FormState>();
  String email = "";
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    initSpeechState();
  }

  Future<void> initSpeechState() async {
    bool hasSpeech = await speech.initialize(
        onError: errorListener, onStatus: statusListener);

    if (!mounted) return;
    setState(() {
      _hasSpeech = hasSpeech;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Library'),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text("Arfaz"),
              accountEmail: Text("chougulearfaz@gmail.com"),
            ),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Home"),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/');
              },
            ),
            Divider(),
            ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Books"),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/books');
                  // Navigator.of(context).pop();
                  // Navigator.push(context, MaterialPageRoute(builder: (context) {
                  //   return BookScreen();
                  // }));
                }),
            Divider(),
            ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Transaction"),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/transaction');
                }),
            Divider(),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Notification"),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/notification');
              },
            ),
            Divider(),
            ListTile(
              title: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Profile"),
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/profile');
              },
            ),
            Divider(),
            FlatButton(
              //icon: Icon(Icons.cloud_off),
              child: Text(
                "Logout",
              ),
              onPressed: () {
                null;
              },
            )
          ],
        ),
      ),
      body: _hasSpeech
          ? Column(children: [
              Form(
                key: _formkey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 180,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          //initialValue: 'hello world',
                          controller: _controller,
                          onChanged: (val) {
                initiateSearch(val);
              },
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                          readOnly: false,
                          decoration: InputDecoration(
                            hintText: 'Search Book',
                            suffixIcon: GestureDetector(
                              child: Icon(Icons.mic),
                              onTap: startListening,
                            ),
                          ),
                        ),
                      ),
                    ),
                    RaisedButton(
                        child: Text("Search"),
                        onPressed: () {
                          null;
                        }),
                    Text(lastWords),
                    
                    GridView.count(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              crossAxisCount: 2,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
              primary: false,
              shrinkWrap: true,
              children: tempSearchStore.map((element) {
                return buildResultCard(element);
              }).toList())
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: speech.isListening
                      ? Text("I'm listening...")
                      : Text('Not listening'),
                ),
              ),
            ])
          : Center(
              child: Text('Speech recognition unavailable',
                  style:
                      TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold))),
                      
    );
  }

  void startListening() {
    lastWords = "";
    lastError = "";
    speech.listen(onResult: resultListener);
    setState(() {});
  }

  void stopListening() {
    speech.stop();
    setState(() {});
  }

  void cancelListening() {
    speech.cancel();
    setState(() {});
  }

  void resultListener(SpeechRecognitionResult result) {
    setState(() {
      lastWords = "${result.recognizedWords} - ${result.finalResult}";
    });
  }

  void errorListener(SpeechRecognitionError error) {
    setState(() {
      lastError = "${error.errorMsg} - ${error.permanent}";
    });
  }

  void statusListener(String status) {
    setState(() {
      lastStatus = "$status";
    });
  }
}
Widget buildResultCard(data) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    elevation: 2.0,
    child: Container(
      child: Center(
        child: Text(data['title'],
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20.0,
        ),
        )
      )
    )
  );
}
