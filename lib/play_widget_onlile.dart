import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

class PlayerWidgetOnline extends StatefulWidget {
  String url;
  String image, name;

  PlayerWidgetOnline({this.url, this.image, this.name});
  @override
  _PlayerWidgetOnlineState createState() => _PlayerWidgetOnlineState();
}

class _PlayerWidgetOnlineState extends State<PlayerWidgetOnline> {
  AudioPlayer _audioPlayer = new AudioPlayer();
  AudioPlayer advancedPlayer = new AudioPlayer();
  double volume = 0.2;
  bool moreButton, isPlaying;
  String path;
  Color color;
  int i = 0;

  @override
  void initState() {
    super.initState();
    moreButton = false;
    isPlaying = false;
    _localPath.then((v) {
      path = v;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _audioPlayer.stop();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/${widget.name}.mp3');
  }

  Future<File> _localFileName(int index) async {
    final path = await _localPath;
    return File('$path/${widget.name}.txt');
  }

  Future _loadFile(String linkIn, String nameIn) async {
    final bytes = await readBytes(linkIn);
    setState(() {
      i++;
    });
    final File fileAudio = await _localFile;
    final File fileName = await _localFileName(i);

    await fileAudio.writeAsBytes(bytes);
    await fileName.writeAsString(nameIn);
    fileName.readAsString().then((v) {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 10.0, left: 10.0),
      child: Card(
          child: Column(
        children: <Widget>[
          RaisedButton(
              padding: EdgeInsets.only(right: 0.0, left: 0.0),
              child: Container(
                alignment: Alignment.center,
                constraints: BoxConstraints.expand(height: 100.0),
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(widget.image), fit: BoxFit.cover)),
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 20.0),
                    Text(widget.name,
                        style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 40.0,
                        )),
                    isPlaying ? Text('playing') : SizedBox()
                  ],
                ),
              ),
              onPressed: () {
                moreButton
                    ? setState(() {
                        moreButton = false;
                      })
                    : setState(() {
                        moreButton = true;
                      });
              }),
          moreButton == false
              ? SizedBox(
                  height: 0.0,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: saveAndPlay,
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
                )
        ],
      )),
    );
  }

  Future _play() async {
    _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    await _audioPlayer.play(widget.url, isLocal: true, volume: volume);
    setState(() => isPlaying = true);
  }

  Future saveAndPlay() async {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('Downloading audio'),
    ));
    _loadFile(widget.url, widget.name).then((_) {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text('Download success')));
      setState(() => widget.url = '$path/${widget.name}.mp3');
      _play();
    });
  }

  Future<int> _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() => isPlaying = false);
    }
    return result;
  }

  Future<int> _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() => isPlaying = false);
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
// _loadCounter() async {
//   SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
//   setState(() {
//     i = (sharedPreferences.getInt('counter') ?? 0);
//   });
// }

// _incrementCounter() async {
//   setState(() {
//     sharedPreferences.setInt('counter', i);
//   });
// }
