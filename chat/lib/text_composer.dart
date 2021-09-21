import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TextComposer extends StatefulWidget {
  TextComposer(this.sendMessage);

  Function(String) sendMessage;

  @override
  _TextComposerState createState() => _TextComposerState();
}

class _TextComposerState extends State<TextComposer> {

  final TextEditingController _controller = TextEditingController();
  final _picker = ImagePicker();

  bool _isComposing = false;

  void _reset() {
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: <Widget>[
        IconButton(
          icon: Icon(Icons.photo_camera),
          onPressed: () async {
            final PickedFile imgFile =
            await _picker.getImage(source: ImageSource.camera);
            if(imgFile == null) return;
          },
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration.collapsed(hintText:'Enviar uma mensagem'),
            onChanged: (text) {
              setState((){
              _isComposing = text.isNotEmpty;
              });

            },
          onSubmitted: (text) {
            widget.sendMessage(text);
            _reset();
          }
          )
        ),
        IconButton(
          icon: Icon(Icons.send, color: Colors.orange),
          onPressed: _isComposing ? () {
            widget.sendMessage(_controller.text);
            _reset();
          } : null,
        ),
        ],
      ),
    );
  }
}