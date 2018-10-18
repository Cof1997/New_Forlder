import 'package:flutter/material.dart';

class AddAudio extends StatefulWidget {
  @override
  _AddAudioState createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  String link;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add audio from a link'),),
      body: Container(
        child: Center(
          child: Container(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(labelText: "Link"),
                  onChanged: (String str) {
                    setState(() {
                      link = str;
                    });
                  }
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}