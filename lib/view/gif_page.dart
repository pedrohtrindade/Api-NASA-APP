import 'package:flutter/material.dart';

class GifPage extends StatelessWidget {
  final Map _gifData;
  GifPage(this._gifData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GIF do espaço")),
      body: Center(
        child: Image.network(_gifData["images"]["original"]["url"]),
      ),
    );
  }
}
