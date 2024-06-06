import 'package:chewie/chewie.dart';
import 'package:dummy_player/vidiolist.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoApp extends StatefulWidget {
  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController videoController;
  ChewieController? chewieController;
  Duration? videoDuration;

  @override
  void initState() {
    _initializePlay();
    super.initState();
  }

  Future<void> _initializePlay({String? videoPath}) async {
    videoController = VideoPlayerController.networkUrl(
        Uri.parse(videoPath ?? Vidiolist.vidios.first))
      ..initialize().then((_) {
        videoDuration =
            videoController.value.duration; // Get duration after initialization
        videoController.play();
        setState(() {});
      });
    chewieController = ChewieController(
        showControlsOnInitialize: true,
        aspectRatio: 16 / 9,
        showControls: true,
        showOptions: true,
        autoInitialize: true,
        autoPlay: true,
        looping: true,
        videoPlayerController: videoController);
  }

  Future<void> _startPlay(String videoPath) async {
    await _clearPrevious().then((_) {
      _initializePlay(videoPath: videoPath);
    });
  }

  Future<bool> _clearPrevious() async {
    await videoController.pause();
    videoController.dispose();
    return true;
  }

  int currentIndex = 0;
  List vidionames = [
    'vidio 1',
    'vidio 2',
    'vidio 3',
    'vidio 4',
    'vidio 5',
    'vidio 6'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: chewieController != null
                    ? Chewie(controller: chewieController!)
                    : Container(),
              ),
              SizedBox(
                height: 40,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () async {
                        Duration? value = await videoController.position;
                        var d = value! - Duration(seconds: 10);
                        videoController.seekTo(Duration(seconds: d.inSeconds));
                      },
                      child: Text(
                        '<<',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () {
                        setState(() {
                          currentIndex =
                              (currentIndex + 1) % Vidiolist.vidios.length;
                        });
                        _startPlay(Vidiolist.vidios[currentIndex]);
                      },
                      child: Text(
                        'Next',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                      ),
                      onPressed: () async {
                        Duration? value = await videoController.position;
                        var d = Duration(seconds: 10) + value!;
                        videoController.seekTo(Duration(seconds: d.inSeconds));
                      },
                      child: Text(
                        '>>',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: Vidiolist.vidios.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        _startPlay(Vidiolist.vidios[index]);
                      },
                      child: ListTile(
                        title: Text(
                          vidionames[index],
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          ),
          // Add GestureDetector for seeking
          GestureDetector(
            onDoubleTapDown: (details) {
              setState(() {
                // Handle double-tap based on current playback position and tap location
                var currentPosition = videoController.value.position;
                var screenSize = MediaQuery.of(context).size;
                if (details.localPosition.dx < screenSize.width / 2) {
                  Duration? value = currentPosition;
                  var d = value - Duration(seconds: 10);
                  videoController.seekTo(Duration(seconds: d.inSeconds));
                }
                if (details.localPosition.dy < screenSize.width / 2) {
                  Duration? value = videoController.value.position;
                  var d = Duration(seconds: 10) + value;
                  videoController.seekTo(Duration(seconds: d.inSeconds));
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    videoController.dispose();
    chewieController?.dispose();
    super.dispose();
  }
}
