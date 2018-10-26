import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class PlayerWidget extends StatefulWidget {
  final String url;
  String image, name;

  PlayerWidget({this.url, this.image, this.name});

  @override
  State<StatefulWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  AudioCache audioCache = new AudioCache();
  AudioPlayer advancedPlayer = new AudioPlayer();
  AudioPlayer fixedPlayer = AudioPlayer();
  double volume = 0.2;
  bool isAudioDown, isPlaying;
  bool moreButton;
  Directory dic;

  @override
  void initState() {
    super.initState();
    moreButton = false;
    _localPath.then((p) =>
        widget.url.contains(p) ? isAudioDown = true : isAudioDown = false);
    isPlaying = false;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    directory.list().forEach((action) => print('abcdef: $action'));
    setState(() => dic = directory);
    return directory.path;
  }

  Future editDialog(BuildContext context) async{
    String name;
    await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Rename Audio'),
            content: TextField(
              onChanged: (String str) => name = str,
              autofocus: true,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Edit'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
    return name;
  }

  @override
  Widget build(BuildContext context) {
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

    return Container(
      padding: EdgeInsets.only(right: 10.0, left: 10.0),
      child: Card(
          child: Column(
        children: <Widget>[
          GestureDetector(
            onDoubleTap: () {
              print('kaka');
              editDialog(context).then((a){
                dic.list().forEach((action){
                  if(action.path.contains(widget.name+'.txt')){
                    action.rename(dic.path+'/'+a+'.txt');
                  }
                  if(action.path.contains(widget.name+'.mp3')){
                    action.rename(dic.path+'/'+a+'.mp3');
                  }
                });
                // print(dic.path+'/'+a+'.mp3');
              });
              dic.list().forEach((action) => print('abcdef: $action'));
            },
            onLongPress: () {
              dic.list().forEach((action) {
                if (action.path == widget.url)
                  // print('haaaaaaaaaaaaa...you ...$action');
                  // Scaffold.of(context)
                  //   .showSnackBar(SnackBar(content: Text('Sắp có xóa rồi nha :)',style: TextStyle(fontSize: 20.0),)));
                  action.delete();
                if (action.path.contains(widget.name + '.txt')) {
                  action.delete();
                  Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text(
                    'Xóa thành công ${widget.name}, khởi động lại app để hoàn tất',
                    style: TextStyle(fontSize: 16.0),
                  )));
                }
              });
            },
            child: RaisedButton(
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
                      isPlaying
                          ? Container(
                              child: Center(
                                child: Text('playing',
                                    style: TextStyle(fontSize: 20.0)),
                              ),
                              color: Colors.white30,
                              width: 80.0,
                            )
                          : SizedBox()
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
          ),
          moreButton == false
              ? SizedBox(
                  height: 0.0,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.play_arrow),
                      onPressed: loop,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: pause,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: stop,
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

  Future loop() async {
    var file;
    isAudioDown
        ? file = widget.url
        : await audioCache.load(widget.url).then((f) => file = f.path);
    advancedPlayer.setReleaseMode(ReleaseMode.LOOP);
    advancedPlayer.play(file, isLocal: true, volume: volume);
    setState(() {
      isPlaying = true;
    });
  }

  Future stop() async {
    await advancedPlayer.stop();
    setState(() {
      advancedPlayer.setReleaseMode(ReleaseMode.STOP);
      isPlaying = false;
    });
  }

  Future pause() async {
    await advancedPlayer.pause();
    setState(() => isPlaying = false);
  }

  // AudioPlayer _player() => fixedPlayer ?? new AudioPlayer();

  // Future _play() async {
  //   final result = await _audioPlayer.play(widget.url, isLocal: false);
  //   _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
  //   if (result == 1)
  //     setState(() {
  //       _playerState = PlayerState.playing;
  //       isPlaying = true;
  //     });
  // }

  // Future _stop() async {
  //   final result = await _audioPlayer.stop();
  //   if (result == 1) {
  //     setState(() {
  //       _playerState = PlayerState.stopped;
  //       isPlaying = false;
  //     });
  //   }
  // }

  // Future _pause() async {
  //   final result = await _audioPlayer.pause();
  //   if (result == 1) {
  //     setState(() {
  //       _playerState = PlayerState.paused;
  //       isPlaying = false;
  //     });
  //   }
  // }
}

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
//               isAudioDown ? _stop() : stop(advancedPlayer);
//               setState(() {
//                 elevation = 0.0;
//                 isStop = false;
//               });
//             } else {
//               isAudioDown ? _play() : loop(widget.url);
//               setState(() {
//                 elevation = 10.0;
//                 isStop = true;
//               });
//             }
//           },
//         ),
//       ),
//       isAudioDown?setVolDown:setVolAd(advancedPlayer)
//     ],
//   ),
// );

// void choiceAction(String choice) {
//   if (choice == 'Delete') {
//     print('asdasdnmbsdsdfsdfdDELLLLLLLLLLLLLLLLLLLL');
//   }
//   if (choice == 'Edit name') {
//     Navigator.of(context).push(MaterialPageRoute(
//         builder: (_) => EditAudio(
//               image: widget.image,
//               name: widget.name,
//             )));
//   }
// }

// Future editDialog(BuildContext context) {
//   return showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Edit Name Audio'),
//           actions: <Widget>[
//             TextFormField(),
//             FlatButton(
//               child: Text('Edit'),
//               onPressed: () {},
//             ),
//             FlatButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//             )
//           ],
//         );
//       });
// }

// List<String> choice = <String>["Edit name", "Delete"];

// var decoratedBox = Image.asset(
//   widget.image,
//   height: 100.0,
// );

// var hero = new Hero(
//   tag: 'hero-tag',
//   child: decoratedBox,
// );
// Widget setVolDown = Container(
//   child: Slider(
//     min: 0.0,
//     max: 1.0,
//     value: volume,
//     onChanged: (value) => setState(() {
//           volume = value;
//           _audioPlayer.setVolume(volume);
//           print(volume);
//         }),
//   ),
// );
// enum PlayerState { stopped, playing, paused }
