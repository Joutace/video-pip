import 'enums/video_type_source.dart';
import 'enums/video_type_source_remote.dart';

class VideoSourceModel {
  VideoSourceModel({
    required this.videoTypeSource,
    required this.videoTypeSourceRemote,
    this.source,
    this.startPosition =
        Duration.zero, // Define a posição inicial com valor padrão zero
  });

  final VideoTypeSourceRemoteEnum videoTypeSourceRemote;
  final VideoTypeSourceEnum videoTypeSource;
  final String? source;
  final Duration startPosition; // Posição inicial do vídeo
}
