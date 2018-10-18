import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

enum PlayerState { stopped, playing, paused }

class PlayAudio extends StatefulWidget {
  final String url;
  String image, name;

  PlayAudio({this.url, this.image, this.name});
  @override
  _PlayAudioState createState() => _PlayAudioState();
}

class _PlayAudioState extends State<PlayAudio> {
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
    // if(widget.url.contains('http')||widget.url.contains('/data/data'))
    //   isAudioDown = true;
    // else isAudioDown = false;
    widget.url.contains('/data/')
        ? isAudioDown = true
        : isAudioDown = false;
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

    return WillPopScope(
      onWillPop: _popDataBack,
      child: Scaffold(
        // appBar: AppBar(
        //   leading: IconButton(
        //       icon: Icon(Icons.arrow_back),
        //       onPressed: () {
        //         Navigator.pop(context, true);
        //       }),
        // ),
        body: CustomScrollView(
          slivers: <Widget>[
            //appbar
            SliverAppBar(
              expandedHeight: 200.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.name),
                background: Image.asset(
                  widget.image,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            //body
            SliverToBoxAdapter(
              child: Container(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: isAudioDown ? _play : loop,
                          iconSize: 50.0,
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.pause),
                          onPressed: isAudioDown ? _pause : pause,
                          iconSize: 50.0,
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: Icon(Icons.stop),
                          onPressed: isAudioDown ? _stop : stop,
                          iconSize: 50.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                    isAudioDown ? setVolDown : setVolAd(advancedPlayer)
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future loop() async {
    File file = await audioCache.load(widget.url);
    AudioPlayer player = _player();
    player.setReleaseMode(ReleaseMode.LOOP);
    player.play(file.path, isLocal: true, volume: volume).then((s) {
      print('hungaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: $s');
    });
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

  Future<bool> _popDataBack() {
    Navigator.of(context).pop('abc');
  }

  Future pause() async {
    await advancedPlayer.pause();
    setState(() => isPlaying = false);
  }

  AudioPlayer _player() => fixedPlayer ?? new AudioPlayer();

  Future _play() async {
    final result = await _audioPlayer.play(widget.url, isLocal: true).then((s) {
      print('hungaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa: $s');
    });
    if (result == 1)
      setState(() {
        _playerState = PlayerState.playing;
        isPlaying = true;
      });
  }

  Future _stop() async {
    final result = await _audioPlayer.stop().then((s) {
      print('hungaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaSTOP: $s');
    });
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
