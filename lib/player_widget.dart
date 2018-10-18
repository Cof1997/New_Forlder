import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

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
  AudioPlayer _audioPlayer = new AudioPlayer();
  AudioPlayer fixedPlayer = AudioPlayer();
  double volume = 0.2;
  PlayerState _playerState = PlayerState.stopped;
  bool isAudioDown, isPlaying;
  bool moreButton;

  @override
  void initState() {
    super.initState();
    moreButton = false;
    widget.url.contains('/data')? isAudioDown = true: isAudioDown = false;
    isPlaying = false;
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

    Widget setVolDown = Container(
      child: Slider(
        min: 0.0,
        max: 1.0,
        value: volume,
        onChanged: (value) => setState(() {
              volume = value;
              _audioPlayer.setVolume(volume);
              print(volume);
            }),
      ),
    );

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
                // Navigator.of(context)
                //     .push(MaterialPageRoute(
                //         builder: (_) => PlayAudio(
                //               image: widget.image,
                //               name: widget.name,
                //               url: widget.url,
                //             )))
                //     .then((s) {
                //   print('hjhjjjjjjjjjjjjjj$s');
                // });
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
                      onPressed: isAudioDown ? _play : loop,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(Icons.pause),
                      onPressed: isAudioDown ? _pause : pause,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    IconButton(
                      icon: Icon(Icons.stop),
                      onPressed: isAudioDown ? _stop : stop,
                      iconSize: 35.0,
                      color: Colors.blue,
                    ),
                    isAudioDown ? setVolDown : setVolAd(advancedPlayer)
                  ],
                )
        ],
      )),
    );
  }

  Future loop() async {
    File file = await audioCache.load(widget.url);
    AudioPlayer player = _player();
    player.setReleaseMode(ReleaseMode.LOOP);
    player.play(file.path, isLocal: true, volume: volume);
    advancedPlayer = player;
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

  AudioPlayer _player() => fixedPlayer ?? new AudioPlayer();

  Future _play() async {
    final result = await _audioPlayer.play(widget.url, isLocal: true);
    if (result == 1)
      setState(() {
        _playerState = PlayerState.playing;
        isPlaying = true;
      });
  }

  Future _stop() async {
    final result = await _audioPlayer.stop();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.stopped;
        isPlaying = false;
      });
    }
  }

  Future _pause() async {
    final result = await _audioPlayer.pause();
    if (result == 1) {
      setState(() {
        _playerState = PlayerState.paused;
        isPlaying = false;
      });
    }
  }
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
