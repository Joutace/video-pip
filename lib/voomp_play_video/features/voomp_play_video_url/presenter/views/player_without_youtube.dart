import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/data/models/enums/video_type_source.dart';

class PlayerWithoutYoutube extends StatefulWidget {
  const PlayerWithoutYoutube({
    super.key,
    required this.play,
    required this.source,
    required this.typeSource,
  });

  final bool play;
  final String source;
  final VideoTypeSourceEnum typeSource;

  @override
  State<PlayerWithoutYoutube> createState() => _PlayerWithoutYoutubeState();
}

class _PlayerWithoutYoutubeState extends State<PlayerWithoutYoutube> {
  late VideoPlayerController _videoPlayerController;

  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : Column(
              spacing: 20,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(), Text('Carregando')],
            ),
    );
  }

  Future<void> initializePlayer() async {
    if (widget.typeSource == VideoTypeSourceEnum.remote) {
      _videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(widget.source),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    } else if (widget.typeSource == VideoTypeSourceEnum.local) {
      _videoPlayerController = VideoPlayerController.file(
        File(widget.source),
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );
    }

    await Future.wait([_videoPlayerController.initialize()]);

    _createChewieController();
    setState(() {});
  }

  Future<void> toggleVideo(BuildContext context) async {
    await _videoPlayerController.pause();

    await initializePlayer();
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: widget.play,
      looping: true,
      additionalOptions: (context) {
        return <OptionItem>[
          OptionItem(
            onTap: toggleVideo,
            iconData: Icons.live_tv_sharp,
            title: 'Toggle Video Src',
          ),
        ];
      },
      hideControlsTimer: const Duration(seconds: 1),
    );
  }
}
