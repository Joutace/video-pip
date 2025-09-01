import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'avplayer_controller.dart';

/// Widget que renderiza o AVPlayerViewController (iOS) como Platform View
class AvPlayerView extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final AvPlayerController controller;

  const AvPlayerView({
    super.key,
    required this.url,
    required this.controller,
    this.autoPlay = true,
  });

  @override
  State<AvPlayerView> createState() => _AvPlayerViewState();
}

class _AvPlayerViewState extends State<AvPlayerView> {
  static const _viewType = 'flutter_avplayer_plugin/view';
  late final MethodChannel _channel;

  Future<void> _onPlatformViewCreated(int id) async {
    _channel = MethodChannel('flutter_avplayer_plugin/methods_$id');

    // Vincula o controller ao canal nativo
    widget.controller.bind(_channel);

    // Carrega URL inicial
    await _channel.invokeMethod('loadUrl', {
      'url': widget.url,
      'autoPlay': widget.autoPlay,
    });
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      // Plugin é específico do iOS neste exemplo
      return const SizedBox.shrink();
    }

    return UiKitView(
      viewType: _viewType,
      creationParams: {
        'url': widget.url,
        'autoPlay': widget.autoPlay,
      },
      onPlatformViewCreated: _onPlatformViewCreated,
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
