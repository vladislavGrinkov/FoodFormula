import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechWidget extends StatefulWidget {
  @override
  _SpeechWidgetState createState() => _SpeechWidgetState();
}

class _SpeechWidgetState extends State<SpeechWidget> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press the button';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
