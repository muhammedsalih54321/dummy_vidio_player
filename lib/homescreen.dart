import 'package:dummy_player/vidiolist.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    _initializePlay();
    super.initState();
  }

  void _nextVideoPlay(String videoPath) {
  
    _startPlay(videoPath);
  }

  Future<void> _startPlay(String videoPath) async {
    await _clearPrevious().then((_) {
      _initializePlay(videoPath: videoPath);
    });
  }

  Future<bool> _clearPrevious() async {
    await _videoController.pause();

    _videoController.dispose();
    return true;
  }

  Future<void> _initializePlay({String? videoPath}) async {
    _videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoPath ?? Vidiolist.vidios.first))
      ..initialize().then((_) {
        _videoController.play();
        setState(() {});
      });
  }

  int videoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Container(
          height: 300,
          width: double.infinity,
          child: _videoController.value.isInitialized
              ? VideoPlayer(_videoController)
              : Container(),
        ),
        SizedBox(
          height: 20,
        ),
        GestureDetector(
            onTap: () => setState(() {
                  _videoController.value.isPlaying
                      ? _videoController.pause()
                      : _videoController.play();
                }),
            child: CircleAvatar(
              backgroundColor: Colors.black,
              child: Center(
                child: Icon(
                  _videoController.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                  color: Colors.white,
                ),
              ),
            )),
        ElevatedButton(
            style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Colors.black)),
            onPressed: () {
              print('clicked');
              setState(() {
                videoIndex += 1;
                _nextVideoPlay(
                    Vidiolist.vidios[videoIndex % Vidiolist.vidios.length]);
              });
            },
            child: Text(
              'Next',
              style: TextStyle(color: Colors.white),
            ))
      ],
    ));
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }
}
