import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceToTextScreen extends StatefulWidget {
  @override
  _VoiceToTextScreenState createState() => _VoiceToTextScreenState();
}
class _VoiceToTextScreenState extends State<VoiceToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  Timer? _listeningTimer; // Timer to handle timeout

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Voice to Text Example'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _isListening ? CircularProgressIndicator() : IconButton(icon: Icon(Icons.mic), onPressed: _listen,),
            SizedBox(height: 20.0),
            Text(_text),
          ],
        ),
      ),
    );
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('onStatus: $status'),
        onError: (error) => print('onError: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) => setState(() {
            _text = result.recognizedWords;
          }),
        );
        _startListeningTimer(); // Start the listening timer
      }
    } else {
      _stopListening();
    }
  }

  void _startListeningTimer() {
    _listeningTimer = Timer(Duration(seconds: 20), () {
      _stopListening();
    });
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
    }
    _listeningTimer?.cancel();
  }

  @override
  void dispose() {
    _listeningTimer?.cancel();
    super.dispose();
  }
}
