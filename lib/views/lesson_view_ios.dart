import 'package:flutter/material.dart';
import 'package:flutter_avplayer_plugin/flutter_avplayer_plugin.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';

// avplayer_controller.dart
import 'dart:async';
import 'package:flutter/services.dart';

class AvPlayerController {
  MethodChannel? _channel;
  final _ready = Completer<void>();

  void _bind(MethodChannel ch) {
    _channel = ch;
    if (!_ready.isCompleted) _ready.complete();
  }

  Future<void> _ensureReady() async {
    if (!_ready.isCompleted) await _ready.future;
  }

  Future<void> play() async {
    await _ensureReady();
    await _channel!.invokeMethod('play');
  }

  Future<void> pause() async {
    await _ensureReady();
    await _channel!.invokeMethod('pause');
  }

  Future<void> startPiP() async {
    await _ensureReady();
    await _channel!.invokeMethod('startPiP');
  }

  Future<void> stopPiP() async {
    await _ensureReady();
    await _channel!.invokeMethod('stopPiP');
  }

  Future<void> loadUrl(String url, {bool autoPlay = true}) async {
    await _ensureReady();
    await _channel!.invokeMethod('loadUrl', {'url': url, 'autoPlay': autoPlay});
  }
}





class LessonViewIOS extends StatefulWidget {
  const LessonViewIOS({super.key, required this.lesson});
  final LessonMock lesson;

  @override
  State<LessonViewIOS> createState() => _LessonViewIOSState();
}

class _LessonViewIOSState extends State<LessonViewIOS> {
  final _key = GlobalKey<_PlayerHolderState>();

  @override
  Widget build(BuildContext context) {
    // Exemplo com HLS .m3u8 (sem DRM)
    const url = "https://example.com/stream.m3u8";

    return Scaffold(
      appBar: AppBar(title: const Text('AVPlayer PiP Demo')),
      body: Column(
        children: [
          Expanded(
            child: PlayerHolder(key: _key, url: url),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => _key.currentState?.play(),
                child: const Text('Play'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _key.currentState?.pause(),
                child: const Text('Pause'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _key.currentState?.startPiP(),
                child: const Text('Start PiP'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _key.currentState?.stopPiP(),
                child: const Text('Stop PiP'),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class PlayerHolder extends StatefulWidget {
  final String url;
  const PlayerHolder({super.key, required this.url});

  @override
  State<PlayerHolder> createState() => _PlayerHolderState();
}

class _PlayerHolderState extends State<PlayerHolder> {
  late AvPlayerView _view;

  @override
  void initState() {
    super.initState();
    _view = AvPlayerView(url: widget.url, autoPlay: true);
  }

  Future<void> play() => _view.createState().play();
  Future<void> pause() => _view.createState().pause();
  Future<void> startPiP() => _view.createState().startPiP();
  Future<void> stopPiP() => _view.createState().stopPiP();

  @override
  Widget build(BuildContext context) {
    return _view;
  }
}
