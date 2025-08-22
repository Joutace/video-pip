import '../../data/models/enums/video_type_source_remote.dart';
import '../../data/models/video_source_model.dart';

abstract class IVideoPlayerRepository {
  Future<(VideoSourceModel, Exception?)> getSource({
    required String fileUrl,
    required VideoTypeSourceRemoteEnum typeSourceRemote,
    Duration startPosition = Duration.zero,
  });

  String? getVideoIdFromYoutube(String text);
}
