import 'package:firebase_database/firebase_database.dart';

class Item {
  String key;
  String link;
  String name;

  Item(this.link, this.name);

  Item.fromSnapshot(DataSnapshot snapshot)
      : key = snapshot.key,
        link = snapshot.value["link"],
        name = snapshot.value["name"];
        
  toJson() {
    return {
      "link": link,
      "name": name,
    };
  }
}