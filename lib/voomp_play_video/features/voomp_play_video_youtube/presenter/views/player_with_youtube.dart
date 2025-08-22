import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlayerWithYoutube extends StatefulWidget {
  const PlayerWithYoutube({
    super.key,
    required this.play,
    required this.source,
    this.barrierFullScreen = false,
    this.isLive = false,
  });

  final bool play;
  final bool isLive;
  final bool barrierFullScreen;
  final String source;

  @override
  State<PlayerWithYoutube> createState() => _PlayerWithYoutubeState();
}

class _PlayerWithYoutubeState extends State<PlayerWithYoutube> {
  late YoutubePlayerController _controller;
  bool isRunning = false;

  @override
  void initState() {
    _initializePlayer();
    super.initState();
  }

  void _initializePlayer() {
    _controller = YoutubePlayerController(
      initialVideoId: widget.source,
      flags: YoutubePlayerFlags(
        loop: widget.barrierFullScreen,
        autoPlay: widget.play,
        mute: false,
        isLive: widget.isLive,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isRunning = !isRunning;
          isRunning ? _controller.pause() : _controller.play();
        });
      },
      child: AbsorbPointer(
        absorbing: widget.barrierFullScreen,
        child: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.amber,
          progressColors: const ProgressBarColors(
            playedColor: Colors.amber,
            handleColor: Colors.amberAccent,
          ),
          onReady: () {},
        ),
      ),
    );
  }
}
