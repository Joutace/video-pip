 import 'package:video_rotate/core/base_state.dart';

import '../../data/models/enums/video_type_source.dart';
import '../../data/models/enums/video_type_source_remote.dart';

class VoompPlayVideoState extends BaseState {
  VoompPlayVideoState({
    required super.loading,
    required super.errorMessage,
    required this.videoTypeSource,
    required this.videoTypeSourceRemote,
    required this.play,
    this.source,
    this.currentPosition = Duration.zero,
  });

  final VideoTypeSourceRemoteEnum videoTypeSourceRemote;
  final VideoTypeSourceEnum videoTypeSource;
  final bool play;
  final String? source;
  final Duration currentPosition;

  factory VoompPlayVideoState.initial() {
    return VoompPlayVideoState(
      loading: BaseLoadingState.initial,
      errorMessage: null,
      videoTypeSource: VideoTypeSourceEnum.none,
      videoTypeSourceRemote: VideoTypeSourceRemoteEnum.none,
      play: false,
      currentPosition: Duration.zero,
    );
  }

  VoompPlayVideoState copyWith({
    String? errorMessage,
    BaseLoadingState? loading,
    VideoTypeSourceRemoteEnum? videoTypeSourceRemote,
    VideoTypeSourceEnum? videoTypeSource,
    bool? play,
    String? source,
    Duration? currentPosition,
  }) {
    return VoompPlayVideoState(
      loading: loading ?? this.loading,
      videoTypeSourceRemote:
          videoTypeSourceRemote ?? this.videoTypeSourceRemote,
      videoTypeSource: videoTypeSource ?? this.videoTypeSource,
      play: play ?? this.play,
      source: source ?? this.source,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPosition: currentPosition ?? this.currentPosition,
    );
  }
}
