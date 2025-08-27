import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

abstract class PlayableController {
  Future<void> play();
  Future<void> pause();
}

class PlayerControllerState {
  const PlayerControllerState({this.current});
  final PlayableController? current;

  PlayerControllerState copyWith({PlayableController? current}) =>
      PlayerControllerState(current: current);
}

class PlayerControllerCubit extends Cubit<PlayerControllerState> {
  PlayerControllerCubit() : super(const PlayerControllerState());

  void setCurrent(PlayableController controller) {
    emit(state.copyWith(current: controller));
  }

  void clear() {
    emit(const PlayerControllerState());
  }

  Future<void> play() async {
    await state.current?.play();
  }

  Future<void> pause() async {
    await state.current?.pause();
  }
}

class WebViewPlayableController implements PlayableController {
  WebViewPlayableController(this._controller);
  final WebViewController _controller;

  @override
  Future<void> pause() async {
    try {
      await _controller.runJavaScript("document.querySelector('video')?.pause();");
    } catch (e) {
      debugPrint('WebViewPlayableController.pause error: $e');
    }
  }

  @override
  Future<void> play() async {
    try {
      await _controller.runJavaScript("document.querySelector('video')?.play();");
    } catch (e) {
      debugPrint('WebViewPlayableController.play error: $e');
    }
  }
}

class YoutubePlayableController implements PlayableController {
  YoutubePlayableController(this._controller);
  final YoutubePlayerController _controller;

  @override
  Future<void> pause() async {
    _controller.pause();
  }

  @override
  Future<void> play() async {
    _controller.play();
  }
}

class VideoPlayerPlayableController implements PlayableController {
  VideoPlayerPlayableController(this._controller);
  final VideoPlayerController _controller;

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> play() => _controller.play();
}
