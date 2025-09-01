import 'package:flutter/material.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';
import 'package:video_rotate/views/simple_pip_mode_view.dart';
import 'package:video_rotate/views/video_player_view.dart';
import 'package:video_rotate/views/video_audio_background_view.dart';

class LessonsListView extends StatelessWidget {
  const LessonsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lessons'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView.builder(
        itemCount: allLessonsMock.length,
        itemBuilder: (context, index) {
          final lesson = allLessonsMock[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: _getMediaTypeIcon(lesson.mediaType),
              title: Text(
                lesson.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Course ID: ${lesson.courseId}'),
                  Text('Module ID: ${lesson.moduleId}'),
                  Text('Lesson ID: ${lesson.lessonId}'),
                  Text('Media Type: ${lesson.mediaType}'),
                ],
              ),
              trailing: Wrap(spacing: 8, children: [
                IconButton(
                  tooltip: 'Play audio in background',
                  icon: const Icon(Icons.headphones),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoAudioPlayerPage(lesson: lesson),
                      ),
                    );
                  },
                ),
                const Icon(Icons.arrow_forward_ios),
              ]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerPage(lesson: lesson),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getMediaTypeIcon(String mediaType) {
    IconData iconData;
    Color iconColor;

    switch (mediaType.toLowerCase()) {
      case 'youtube':
        iconData = Icons.play_circle_filled;
        iconColor = Colors.red;
        break;
      case 'vimeo':
        iconData = Icons.play_circle_filled;
        iconColor = Colors.blue;
        break;
      case 'panda':
        iconData = Icons.video_library;
        iconColor = Colors.green;
        break;
      case 'voomptube':
        iconData = Icons.video_camera_front;
        iconColor = Colors.purple;
        break;
      case 'iframe':
        iconData = Icons.web;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.video_file;
        iconColor = Colors.grey;
    }

    return CircleAvatar(
      backgroundColor: iconColor.withAlpha(20),
      child: Icon(iconData, color: iconColor, size: 24),
    );
  }
}
