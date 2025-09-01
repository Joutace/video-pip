import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_rotate/core/voomp_tube.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/views/voomp_play_video.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoAudioPlayerPage extends StatefulWidget {
  final LessonMock lesson;

  const VideoAudioPlayerPage({super.key, required this.lesson});

  @override
  State<VideoAudioPlayerPage> createState() => _VideoAudioPlayerPageState();
}

class _VideoAudioPlayerPageState extends State<VideoAudioPlayerPage> {
  final _player = AudioPlayer();
  final _yt = YoutubeExplode();

  @override
  initState() {
    _configureAudioSession();
    super.initState();
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  @override
  void dispose() {
    _player.dispose();
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var videUrl = widget.lesson.mediaType == 'voomptube'
        ? decodeVsl(widget.lesson.source)['url']
        : widget.lesson.source;

    return Scaffold(
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 212, child: VoompPlayVideo(url: videUrl)),
        ],
      ),
    );
  }
}
