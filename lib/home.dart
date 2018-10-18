import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_sound/item.dart';
import 'package:test_sound/play_widget_onlile.dart';

import 'player_widget.dart';

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  AudioCache audioCache = new AudioCache();
  AudioPlayer advancedPlayer = new AudioPlayer();
  AudioPlayer fixedPlayer = AudioPlayer();
  List<String> listAudio = [
    'audioCafe.mp3',
    'audioMua.mp3',
    'audioNight.mp3',
    'audioSea.mp3',
    'audioThunder.mp3',
    'audioWind.mp3'
  ];
  List<String> listImage = [
    'images/cafe.jpg',
    'images/rain.jpg',
    'images/night.png',
    'images/sea.jpg',
    'images/thunder.jpg',
    'images/wind.jpg'
  ];
  List<String> listName = ['Cafe', 'Rain', 'Night', 'Sea', 'Thunder', 'Wind'];
  List<Item> items = List();
  Item item;

  String link, name;
  double volume = 0.2;
  int i = 0;
  var fileLocal;
  DatabaseReference itemRef;
  Directory directory;
  List<List<int>> listSave;
  bool addButton;
  SharedPreferences prefs;

  _loadCounter() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      i = (prefs.getInt('counter') ?? 0);
    });
    listDownload();
  }

  _onEntryAdded(Event event) {
    setState(() {
      items.add(Item.fromSnapshot(event.snapshot));
    });
  }


  Future<String> get _localPath async {
    directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFileName(int index) async {
    final path = await _localPath;
    return File('$path/name$index.txt');
  }

  Future _loadFile(String linkIn, String nameIn) async {
    // final bytes = await readBytes(linkIn);
    // final File fileAudio = await _localFile;
    // final File fileName = await _localFileName(i);
    // i++;
    // _file = await fileAudio.writeAsBytes(bytes);
    // _saveName = await fileName.writeAsString(nameIn);
    // _saveName = await fileName.readAsString().then((v) {
    // });
    if (linkIn != null) {
      setState(() {
        listAudio.add(linkIn);
        listImage.add('images/noImage.jpg');
        listName.add(nameIn);
      });
    }
  }

  listDownload() async {
    String name;
    File fileName;
    for (int j = 1; j <= i; j++) {
      await _localFileName(j).then((v) {
        fileName = v;
      });
      await fileName.readAsString().then((v) {
        name = v;
      });
      _localPath.then((String p) {
        setState(() {
          listAudio.add('$p/audio$j.mp3');
          listImage.add('images/noImage.jpg');
          listName.add(name);
        });
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _localPath;
    _loadCounter();
    item = Item("", "");
    final FirebaseDatabase database = FirebaseDatabase.instance;
    itemRef = database.reference().child('audio');
    itemRef.onChildAdded.listen(_onEntryAdded);
    // itemRef.onChildChanged.listen(_onEntryChanged);
    addButton = false;
  }

  @override
  Widget build(BuildContext context) {
    int leng = items.length;
    int lengAudio = listAudio.length;

    Widget addAudioURL = SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Card(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 15.0),
                child: Center(
                  child: Text('Add audio'),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20.0, left: 20.0),
                child: TextField(
                  onChanged: (String str) {
                    name = str;
                  },
                  decoration: InputDecoration(hintText: "Name"),
                ),
              ),
              Container(
                padding: EdgeInsets.only(right: 20.0, left: 20.0),
                child: TextField(
                  onChanged: (String str) {
                    link = str;
                  },
                  decoration: InputDecoration(hintText: "Link"),
                ),
              ),
              RaisedButton(
                padding: EdgeInsets.only(top: 15.0),
                child: Text('Add'),
                onPressed: () {
                  _loadFile(link, name);
                  // _incrementCounter();
                },
              )
            ],
          ),
        ),
      ),
    );

    Widget listCardAudio = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index < lengAudio)
          return listAudio[index].contains('http')
              ? PlayerWidgetOnline(
                  url: listAudio[index],
                  image: listImage[index],
                  name: listName[index],
                  prefs: prefs,
                )
              : PlayerWidget(
                  url: listAudio[index],
                  image: listImage[index],
                  name: listName[index],
                );
      }),
    );

    Widget listCardFirebase = SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index < leng)
          return PlayerWidgetOnline(
              url: items[index].link,
              image: 'images/noImage.jpg',
              name: items[index].name,
              prefs: prefs);
      }),
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text('Add'),
        onPressed: () {
          setState(() {
            addButton ? addButton = false : addButton = true;
          });
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(''),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          addButton ? addAudioURL : SliverToBoxAdapter(),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: 20.0),
              child: Center(
                child: Text('Audio from Firebase:'),
              ),
            ),
          ),
          listCardFirebase,
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(top: 10.0),
              child: Center(
                child: Text('Audio from App and add link:'),
              ),
            ),
          ),
          listCardAudio
        ],
      ),
    );
  }
}

// Widget grid = SliverGrid.count(
//   crossAxisCount: 1,
//   childAspectRatio: 2.0,
//   children: <Widget>[
//     GridView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: leng,
//       gridDelegate:
//           SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
//       itemBuilder: (context, int index) {
//         return PlayerWidgetOnline(
//             url: items[index].link, image: 'images/noImage.PNG');
//       },
//     ),
//   ],
// );

// Widget grid2 = SliverGrid.count(
//   crossAxisCount: 1,
//   childAspectRatio: 1.0,
//   children: <Widget>[
//     GridView.builder(
//       scrollDirection: Axis.horizontal,
//       itemCount: listAudio.length,
//       gridDelegate:
//           SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
//       itemBuilder: (context, int index) {
//         return listAudio[index].contains('http')
//             ? PlayerWidgetOnline(
//                 url: listAudio[index], image: listImage[index])
//             : PlayerWidget(url: listAudio[index], image: listImage[index]);
//       },
//     ),
//   ],
// );

// Future<dynamic> readAudio(int index) async {
//   final file = await _localFile;
//   try {
//     // Read the file
//     var contents = await file.readAsBytes();

//     return contents;
//   } catch (e) {
//     return 'errorrrrrrr:${e}';
//   }
// }

// _incrementCounter() async {
//   prefs = await SharedPreferences.getInstance();
//   setState(() {
//     i = (prefs.getInt('counter') ?? 0);
//     prefs.setInt('counter', i);
//   }); //incre i when add a link
// }

  // _onEntryChanged(Event event) {
  //   var old = items.singleWhere((entry) {
  //     return entry.key == event.snapshot.key;
  //   });
  //   setState(() {
  //     items[items.indexOf(old)] = Item.fromSnapshot(event.snapshot);
  //   });
  // }
  
  // Future<File> get _localFile async {
  //   final path = await _localPath;
  //   return File('$path/audio$i.mp3');
  // }
