import 'dart:async';
import 'package:flutter/services.dart';

/// Controller que encapsula o MethodChannel do Platform View (iOS)
class AvPlayerController {
  MethodChannel? _channel;
  final _ready = Completer<void>();

  /// Vincula o channel interno quando o PlatformView termina de criar.
  void bind(MethodChannel ch) {
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
    await _channel!.invokeMethod('loadUrl', {
      'url': url,
      'autoPlay': autoPlay,
    });
  }
}
