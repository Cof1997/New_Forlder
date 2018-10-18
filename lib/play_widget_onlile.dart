import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlayerState { stopped, playing, paused }

class PlayerWidgetOnline extends StatefulWidget {
  final String url;
  String image, name;
  SharedPreferences prefs;

  PlayerWidgetOnline({this.url, this.image, this.name, this.prefs});
  @override
  _PlayerWidgetOnlineState createState() => _PlayerWidgetOnlineState();
}

class _PlayerWidgetOnlineState extends State<PlayerWidgetOnline> {
  PlayerState _playerState = PlayerState.stopped;
  AudioPlayer _audioPlayer = new AudioPlayer();
  AudioPlayer advancedPlayer = new AudioPlayer();
  double volume = 0.2;
  bool moreButton;
  Color color;
  int i = 0;
  var _file, _saveName;
  SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    moreButton = false;
    color = Colors.grey[300];
    _loadCounter();
    sharedPreferences = widget.prefs;
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    print('locallllllllllllllllll$directory');
    return directory.path;
  }

  _loadCounter() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      i = (sharedPreferences.getInt('counter') ?? 0);
    });
    // listDownload();
  }

  _incrementCounter() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // i = (sharedPreferences.getInt('counter') ?? 0) ;
      sharedPreferences.setInt('counter', i);
    }); //incre i when add a link
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/audio$i.mp3');
  }

  Future<File> _localFileName(int index) async {
    final path = await _localPath;
    return File('$path/name$index.txt');
  }

  Future _loadFile(String linkIn, String nameIn) async {
    final bytes = await readBytes(linkIn);
    setState(() {
      i++;
    });
    final File fileAudio = await _localFile;
    final File fileName = await _localFileName(i);
    
    _incrementCounter();

    _file = await fileAudio.writeAsBytes(bytes);
    // fileAudio.readAsString().then((v) {
    // });
    _saveName = await fileName.writeAsString(nameIn);
    fileName.readAsString().then((v) {
    });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10.0, left: 10.0),
      child: Card(
          child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Image.asset(
                widget.image,
                height: 100.0,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: Text(widget.name),
                  ),
                  RaisedButton(
                      child: Text('Play'),
                      onPressed: () {
                        moreButton
                            ? setState(() {
                                moreButton = false;
                              })
                            : setState(() {
                                moreButton = true;
                              });
                      }),
                ],
              ),
            ],
          ),
          moreButton == false
              ? SizedBox(
                  height: 0.0,
                )
              : Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: _play,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: _pause,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: _stop,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    setVolAd(advancedPlayer)
                  ],
                ),
        ],
      )),
    );
  }

  Future<int> _play() async {
    print('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~playOnline:${widget.url}');
    _loadFile(widget.url, widget.name);
    final result = await _audioPlayer.play(widget.url);
    if (result == 1)
      setState(() {
        _playerState = PlayerState.playing;
        color = Colors.blue[300];
      });

    return result;
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        color = Colors.grey[300];
      });
    }
    print('iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii~i~$i');
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.paused;
        color = Colors.grey[300];
      });
    }
    return result;
  }

  Widget setVolAd(AudioPlayer ap) => Container(
        child: Slider(
          min: 0.0,
          max: 1.0,
          value: volume,
          onChanged: (value) => setState(() {
                volume = value;
                ap.setVolume(volume);
                print(volume);
              }),
        ),
      );
}

// double elevation = 0.0;
// bool isPlaying = false, isStop = false;

// return Container(
//   child: Column(
//     children: <Widget>[
//       Card(
//         elevation: elevation,
//         child: FlatButton(
//           child: Image.asset(
//             widget.image,
//             height: 100.0,
//           ),
//           onPressed: () {
//             isStop ? isPlaying = true : isPlaying = false;
//             if (isPlaying) {
//               _stop();
//               setState(() {
//                 elevation = 0.0;
//                 isStop = false;
//               });
//             } else {
//               _play();
//               setState(() {
//                 elevation = 10.0;
//                 isStop = true;
//               });
//             }
//           },
//         ),
//       ),
//       Container(
//         child: Slider(
//           min: 0.0,
//           max: 2.0,
//           value: volume,
//           onChanged: (value) => setState(() {
//                 volume = value;
//                 advancedPlayer.setVolume(volume);
//                 print(volume);
//               }),
//         ),
//       )
//     ],
//   ),
// );
    // setState(() {
    //   i++;
    // });
    // if (linkIn != null) {
    //   print("aaaaaaaaaaaaaaaaaaIS FILE");
    //   setState(() {
    //     listAudio.add(linkIn);
    //     listImage.add('images/noImage.png');
    //     listName.add(nameIn);
    //   });
    // }