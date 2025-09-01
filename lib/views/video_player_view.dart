import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_rotate/core/voomp_tube.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';
import 'package:video_rotate/views/lesson_content.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/views/voomp_play_video.dart';
import 'package:floating/floating.dart';
import 'dart:math';

class VideoPlayerPage extends StatefulWidget {
  final LessonMock lesson;

  const VideoPlayerPage({super.key, required this.lesson});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late Floating _floating;

  @override
  void initState() {
    super.initState();
    _floating = Floating();
  }

  enablePip(BuildContext context, {bool autoEnable = false}) async {
    final rational = Rational.landscape();
    final screenSize =
        MediaQuery.of(context).size * MediaQuery.of(context).devicePixelRatio;
    final height = screenSize.width ~/ rational.aspectRatio;

    final arguments = autoEnable
        ? OnLeavePiP(
            aspectRatio: rational,
            sourceRectHint: Rectangle<int>(
              0,
              (screenSize.height ~/ 2) - (height ~/ 2),
              screenSize.width.toInt(),
              height,
            ),
          )
        : ImmediatePiP(
            aspectRatio: rational,
            sourceRectHint: Rectangle<int>(
              0,
              (screenSize.height ~/ 2) - (height ~/ 2),
              screenSize.width.toInt(),
              height,
            ),
          );

    final status = await _floating.enable(arguments);
    debugPrint('====================== PiP enabled? $status ============');
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    var videUrl = widget.lesson.mediaType == 'voomptube'
        ? decodeVsl(widget.lesson.source)['url']
        : widget.lesson.source;

    if (orientation == Orientation.landscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return PiPSwitcher(
      childWhenDisabled: Scaffold(
        appBar: AppBar(
          title: Text(widget.lesson.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
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
            widget.lesson.source.contains('iframe')
                ? LessonContent(content: widget.lesson.source)
                : SizedBox(height: 212, child: VoompPlayVideo(url: videUrl)),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => enablePip(context),
                icon: const Icon(Icons.picture_in_picture),
                label: const Text('Ativar PiP'),
              ),
            ),
          ],
        ),
      ),
      childWhenEnabled:            widget.lesson.source.contains('iframe')
                ? LessonContent(content: widget.lesson.source)
                : SizedBox(height: 212, child: VoompPlayVideo(url: videUrl, autoPlay: true,)),
    );
  }
}
