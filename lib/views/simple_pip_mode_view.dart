import 'package:flutter/material.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';
import 'package:video_rotate/core/voomp_tube.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/views/voomp_play_video.dart';

class SimplePipModePage extends StatefulWidget {
  final LessonMock lesson;

  const SimplePipModePage({super.key, required this.lesson});

  @override
  State<SimplePipModePage> createState() => _SimplePipModePageState();
}

class _SimplePipModePageState extends State<SimplePipModePage> {
  final SimplePip _simplePipInstance = SimplePip();

  bool _pipAvailable = false;
  bool _pipActive = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSupport();
    _simplePipInstance.onPipEntered = () => setState(() => _pipActive = true);
    _simplePipInstance.onPipExited = () => setState(() => _pipActive = false);
  }

  Future<void> _checkSupport() async {
    try {
      final available = await SimplePip.isPipAvailable;
      setState(() => _pipAvailable = available);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _enterPip() async {
    try {
      await _simplePipInstance.enterPipMode();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.lesson.mediaType == 'voomptube'
        ? decodeVsl(widget.lesson.source)['url']
        : widget.lesson.source;

    return Scaffold(
      appBar: AppBar(
        title: Text('Simple PiP - ${widget.lesson.title}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text('PiP disponível:'),
                const SizedBox(width: 8),
                Icon(
                  _pipAvailable ? Icons.check_circle : Icons.cancel,
                  color: _pipAvailable ? Colors.green : Colors.red,
                ),
                const Spacer(),
                Text(_pipActive ? 'Em PiP' : 'Normal'),
              ],
            ),
          ),
          Expanded(
            child: Center(child: VoompPlayVideo(url: url)),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _pipAvailable ? _enterPip : null,
                  icon: const Icon(Icons.picture_in_picture),
                  label: const Text('Entrar em Picture-in-Picture'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
