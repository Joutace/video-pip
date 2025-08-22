import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_rotate/core/base_state.dart';

import '../../data/models/enums/video_type_source.dart';
import '../../data/models/enums/video_type_source_remote.dart';
import '../../domain/repositories/video_player_repository.dart';
import 'voomp_play_video_state.dart';

class VoompPlayVideoCubit extends Cubit<VoompPlayVideoState> {
  VoompPlayVideoCubit({required IVideoPlayerRepository videoPlayerRepository})
    : _videoPlayerRepository = videoPlayerRepository,
      super(VoompPlayVideoState.initial());

  final IVideoPlayerRepository _videoPlayerRepository;

  void initial(String url) async {
    if (!url.contains('http')) {
      emit(
        state.copyWith(
          loading: BaseLoadingState.loading,
          videoTypeSource: VideoTypeSourceEnum.local,
        ),
      );
      _playLocalVideo(url);
    } else {
      final typeOfRemoteURL = _typeOfRemoteURL(url);

      if (typeOfRemoteURL == null) {
        return;
      }

      emit(
        state.copyWith(
          loading: BaseLoadingState.loading,
          videoTypeSource: VideoTypeSourceEnum.remote,
          videoTypeSourceRemote: typeOfRemoteURL,
        ),
      );

      if (state.videoTypeSourceRemote == VideoTypeSourceRemoteEnum.url) {
        _playURLVideo(url);
      } else if (state.videoTypeSourceRemote ==
          VideoTypeSourceRemoteEnum.youtube) {
        _playYoutubeVideo(url);
      }
    }
  }

  void updateCurrentPosition(Duration position) {
    emit(state.copyWith(currentPosition: position));
  }

  void _playLocalVideo(String url) async {
    final startPosition = state.currentPosition;
    final (model, error) = await _videoPlayerRepository.getSource(
      fileUrl: url,
      typeSourceRemote: VideoTypeSourceRemoteEnum.none,
      startPosition: startPosition,
    );

    if (error != null) {
      emit(
        state.copyWith(
          loading: BaseLoadingState.error,
          errorMessage: error.toString(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          loading: BaseLoadingState.loaded,
          play: false,
          source: model.source,
          videoTypeSource: model.videoTypeSource,
          currentPosition: startPosition,
        ),
      );
    }
  }

  void _playYoutubeVideo(String url) async {
    final startPosition = state.currentPosition;
    final (model, error) = await _videoPlayerRepository.getSource(
      fileUrl: url,
      typeSourceRemote: VideoTypeSourceRemoteEnum.youtube,
      startPosition: startPosition,
    );

    if (error != null) {
      emit(
        state.copyWith(
          loading: BaseLoadingState.error,
          errorMessage: error.toString(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          loading: BaseLoadingState.loaded,
          play: false,
          source: model.source,
          videoTypeSource: model.videoTypeSource,
          videoTypeSourceRemote: model.videoTypeSourceRemote,
          currentPosition: startPosition,
        ),
      );
    }
  }

  void _playURLVideo(String url) async {
    final startPosition = state.currentPosition;
    final (model, error) = await _videoPlayerRepository.getSource(
      fileUrl: url,
      typeSourceRemote: VideoTypeSourceRemoteEnum.url,
      startPosition: startPosition,
    );

    if (error != null) {
      emit(
        state.copyWith(
          loading: BaseLoadingState.error,
          errorMessage: error.toString(),
        ),
      );
    } else {
      emit(
        state.copyWith(
          loading: BaseLoadingState.loaded,
          play: false,
          source: model.source,
          videoTypeSource: model.videoTypeSource,
          videoTypeSourceRemote: model.videoTypeSourceRemote,
          currentPosition: startPosition,
        ),
      );
    }
  }

  VideoTypeSourceRemoteEnum? _typeOfRemoteURL(String url) {
    if (url.isEmpty) {
      emit(
        state.copyWith(
          loading: BaseLoadingState.error,
          errorMessage:
              'modules.voomp_play_video.features.voomp_play_video.presenter.views.inesert_link_error',
        ),
      );
      return null;
    }

    var urlYouTubeIsValid = _videoPlayerRepository.getVideoIdFromYoutube(url);

    if (urlYouTubeIsValid != null) {
      return VideoTypeSourceRemoteEnum.youtube;
    }

    return VideoTypeSourceRemoteEnum.url;
  }
}
