import 'package:flutter/material.dart';

class EditAudio extends StatefulWidget {
  String image, name;

  EditAudio({this.image, this.name});

  @override
  _EditAudioState createState() => _EditAudioState();
}

class _EditAudioState extends State<EditAudio> {
  @override
  Widget build(BuildContext context) {
    Widget decoratedBox = DecoratedBox(
      // child: Image.asset(
      //   widget.image,
      //   // height: 100.0,
      // ),
      decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(widget.image))),
    );

    var hero = new Hero(
      tag: 'hero-tag-llama',
      child: decoratedBox,
    );

    return Scaffold(
        body: Container(
      child: Center(
        child: SizedBox(
          height: 200.0,
          child: Hero(
            tag: 'hero-tag',
            child: Image.asset(widget.image),
          ),
        ),
      ),
    ));
  }
}
