import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:camera/camera.dart';

class Mpage3 extends StatefulWidget {
  const Mpage3({Key? key}) : super(key: key);

  @override
  State<Mpage3> createState() => _Mpage3State();
}
class _Mpage3State extends State<Mpage3> {
  late Timer _timer;
  double _progressValue = 1.0;
  int _timerDurationInSeconds = 15;
  int _currentTimeInSeconds = 15;
  late stt.SpeechToText _speech;
  late CameraController _cameraController;
  bool _isListening = false;
  bool _isCameraOpen = false;
  String _text = '';
  Timer? _listeningTimer;
  bool _questionsCompleted = false;

  List<String> questions = [
    "Introduce yourself in three words.",
    "What is your favorite hobby?",
    "Describe your dream vacation.",
    "What are your career aspirations?",
    "Share a memorable moment from your childhood."
  ];
  int currentQuestionIndex = 0;
  List<String> answers = [];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _speech = stt.SpeechToText();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[1], ResolutionPreset.medium);
    await _cameraController.initialize();
    setState(() {
      _isCameraOpen = true;
    });
  }

  void _startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        _currentTimeInSeconds--;
        _progressValue = _currentTimeInSeconds / _timerDurationInSeconds;
        if (_currentTimeInSeconds <= 0) {
          _timer.cancel();
          _stopListening();
          _text = '';
          _showNextQuestion();
          _startTimer();
        } else if (_currentTimeInSeconds == 10) {
          _listen();
        }
      });
    });
  }


  void _showNextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
      } else {
        _questionsCompleted = true;
        _navigateToNextPage();
      }
      _currentTimeInSeconds = _timerDurationInSeconds;
      _progressValue = 1.0;
    });
  }

  void _navigateToNextPage() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultPage(questions: questions, answers: answers),),
    );
  }

  @override
  Widget build(BuildContext context) {
    double wi = MediaQuery.of(context).size.width;
    double hi = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: hi * 0.040),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _toggleCamera,
                  child: Stack(
                    children: [
                      Container(
                        height: hi * 0.14,
                        width: wi * 0.28,
                        color: Colors.black45,
                      ),
                      if (_isCameraOpen)
                        Positioned.fill(
                          child: AspectRatio(
                            aspectRatio: _cameraController.value.aspectRatio,
                            child: CameraPreview(_cameraController),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  child: _isListening && !_questionsCompleted
                      ? CircularProgressIndicator()
                      : Icon(Icons.mic),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        margin: EdgeInsets.only(right: wi * 0.04, top: hi * 0.03),
                        height: hi * 0.10,
                        width: wi * 0.10,
                        child: Text(
                          _currentTimeInSeconds.toString(),
                          style: TextStyle(fontSize: 18),
                        ),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: hi * 0.03,
                      child: SizedBox(
                        width: wi * 0.1,
                        height: hi * 0.05,
                        child: CircularProgressIndicator(value: _progressValue,
                          strokeWidth: 8,
                          semanticsValue: '30',
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black45,
                      width: 3,
                    ),
                    color: Colors.blueGrey),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Text(
                          "Question ${currentQuestionIndex + 1}: ${questions[currentQuestionIndex]}",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      Container(
                        child: Text(
                          _text,
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOpen = !_isCameraOpen;
      if (_isCameraOpen) {
        _startCameraPreview();
      } else {
        _stopCameraPreview();
      }
    });
  }

  void _startCameraPreview() async {
    await _cameraController.startImageStream((CameraImage image) async {
      final FirebaseVisionImage visionImage = FirebaseVisionImage.fromBytes(
        concatenatePlanes(image.planes),
        buildMetaData(image),
      );

      final FaceDetector faceDetector = FirebaseVision.instance.faceDetector(
        const FaceDetectorOptions(
          enableClassification: false,
          enableTracking: false,
          minFaceSize: 0.1,
        ),
      );

      final List<Face> faces = await faceDetector.processImage(visionImage);

      if (faces.length > 1) {
        // Show warning dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Multiple Faces Detected'),
              content: const Text('Please make sure only one person is in the frame.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _navigateToNextPage();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
      await faceDetector.close();
    });
  }

  Uint8List concatenatePlanes(List<Plane> planes) {
    final WriteBuffer allBytes = WriteBuffer();
    planes.forEach((plane) => allBytes.putUint8List(plane.bytes));
    return allBytes.done().buffer.asUint8List();
  }
  FirebaseVisionImageMetadata buildMetaData(CameraImage image) {
    return FirebaseVisionImageMetadata(
      rawFormat: image.format.raw,
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: ImageRotation.rotation0,
      planeData: image.planes.map(
            (Plane plane) {
          return FirebaseVisionImagePlaneMetadata(
            bytesPerRow: plane.bytesPerRow,
            height: plane.height,
            width: plane.width,
          );
        },
      ).toList(),
    );
  }

  void _stopCameraPreview() async {
    await _cameraController.stopImageStream();
  }

  void _listen() async {
    if (!_isListening && !_questionsCompleted) {
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
        _startListeningTimer();
      }
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
      answers.add(_text);
    }
    _listeningTimer?.cancel();
  }

  @override
  void dispose() {
    _speech.stop();
    _cameraController.dispose();
    _listeningTimer?.cancel();
    _timer.cancel();
    super.dispose();
  }
}

class ResultPage extends StatelessWidget {
  final List<String> questions;
  final List<String> answers;

  const ResultPage({super.key, required this.questions, required this.answers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(questions[index]),
            subtitle: Text(answers[index]),
          );
        },
      ),
    );
  }
}
