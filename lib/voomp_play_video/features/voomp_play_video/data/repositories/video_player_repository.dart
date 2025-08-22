import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../domain/repositories/video_player_repository.dart';
import '../models/enums/video_type_source.dart';
import '../models/enums/video_type_source_remote.dart';
import '../models/video_source_model.dart';

class VideoPlayerRepository implements IVideoPlayerRepository {
  @override
  Future<(VideoSourceModel, Exception?)> getSource({
    required String fileUrl,
    required VideoTypeSourceRemoteEnum typeSourceRemote,
    Duration startPosition = Duration.zero,
  }) async {
    try {
      var hasConnection = true;
      // await CheckInternetConnectionManager().hasConnection();

      if (hasConnection) {
        return (
          _withInternetGetSource(fileUrl, typeSourceRemote, startPosition),
          null,
        );
      }

      var localResult = await _withoutInternetGetSource(
        fileUrl,
        typeSourceRemote,
        startPosition,
      );

      return (localResult, null);
    } catch (e) {
      return (
        VideoSourceModel(
          videoTypeSource: VideoTypeSourceEnum.none,
          source: '',
          videoTypeSourceRemote: VideoTypeSourceRemoteEnum.none,
          startPosition: Duration.zero,
        ),
        Exception('Error while getting video source: $e'),
      );
    }
  }

  @override
  String? getVideoIdFromYoutube(String text) {
    if (text.contains('live/')) {
      return text.split('live/').last;
    }
    return YoutubePlayer.convertUrlToId(text);
  }

  Future<VideoSourceModel> _withoutInternetGetSource(
    String fileUrl,
    VideoTypeSourceRemoteEnum typeSourceRemote,
    Duration startPosition,
  ) async {
    return VideoSourceModel(
      videoTypeSource: VideoTypeSourceEnum.local,
      videoTypeSourceRemote: typeSourceRemote,
      source: fileUrl,
      startPosition: startPosition,
    );
  }

  VideoSourceModel _withInternetGetSource(
    String fileUrl,
    VideoTypeSourceRemoteEnum typeSourceRemote,
    Duration startPosition,
  ) {
    if (typeSourceRemote == VideoTypeSourceRemoteEnum.url) {
      return VideoSourceModel(
        videoTypeSource: VideoTypeSourceEnum.remote,
        videoTypeSourceRemote: typeSourceRemote,
        source: fileUrl,
        startPosition: startPosition,
      );
    } else if (typeSourceRemote == VideoTypeSourceRemoteEnum.youtube) {
      return VideoSourceModel(
        videoTypeSource: VideoTypeSourceEnum.remote,
        videoTypeSourceRemote: typeSourceRemote,
        source: getVideoIdFromYoutube(fileUrl),
        startPosition: startPosition,
      );
    }

    return VideoSourceModel(
      videoTypeSource: VideoTypeSourceEnum.local,
      videoTypeSourceRemote: VideoTypeSourceRemoteEnum.none,
      source: fileUrl,
      startPosition: startPosition,
    );
  }
}
