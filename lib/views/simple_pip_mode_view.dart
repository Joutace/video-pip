import 'package:flutter/material.dart';
import 'package:simple_pip_mode/actions/pip_action.dart';
import 'package:simple_pip_mode/actions/pip_actions_layout.dart';
import 'package:simple_pip_mode/pip_widget.dart';
import 'package:simple_pip_mode/simple_pip.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';
import 'package:video_rotate/core/voomp_tube.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/views/voomp_play_video.dart';
import 'package:video_rotate/core/initialize.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/services/player_controller_registry.dart';

class SimplePipModePage extends StatefulWidget {
  final LessonMock lesson;

  const SimplePipModePage({super.key, required this.lesson});

  @override
  State<SimplePipModePage> createState() => _SimplePipModePageState();
}

class _SimplePipModePageState extends State<SimplePipModePage> {
  late SimplePip _simplePipInstance;
  bool _pipAvailable = false;
  bool _pipActive = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _simplePipInstance = SimplePip(
      onPipEntered: () => setState(() => _pipActive = true),
      onPipExited: () => setState(() => _pipActive = false),
    );
    _checkSupport();
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
      setState(() => _pipActive = true);
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final videoUrl = widget.lesson.mediaType == 'voomptube'
        ? decodeVsl(widget.lesson.source)['url']
        : widget.lesson.source;

    return PipWidget(
      pipLayout: PipActionsLayout.media,
      onPipAction: (action) {
        switch (action) {
          case PipAction.play:
            rootLocator<PlayerControllerCubit>().play();
            break;
          case PipAction.pause:
            rootLocator<PlayerControllerCubit>().pause();
            break;
          default:
            break;
        }
      },

      pipChild: SizedBox(
        height: 212,
        child: VoompPlayVideo(url: videoUrl, autoPlay: true),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Simple PiP - ${widget.lesson.title}'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Title: ${widget.lesson.title}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    'Course ID: ${widget.lesson.courseId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Site ID: ${widget.lesson.siteId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Module ID: ${widget.lesson.moduleId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Lesson ID: ${widget.lesson.lessonId}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Media Type: ${widget.lesson.mediaType}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 212, child: VoompPlayVideo(url: videoUrl)),
            Center(
              child: ElevatedButton.icon(
                onPressed: _pipAvailable ? _enterPip : null,
                icon: const Icon(Icons.picture_in_picture),
                label: const Text('Ativar PiP'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
