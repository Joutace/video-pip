 import 'package:video_rotate/core/initialize.dart';

import '../data/repositories/video_player_repository.dart';
import '../domain/repositories/video_player_repository.dart';
import '../presenter/cubits/voomp_play_video_cubit.dart';

class VoompPlayVideoInjector {
  static void setup() {
    _repository();
    _cubit();
  }

  static void _repository() {
    rootLocator.registerFactory<IVideoPlayerRepository>(
      () => VideoPlayerRepository(),
    );
  }

  static void _cubit() {
    rootLocator.registerFactory<VoompPlayVideoCubit>(
      () => VoompPlayVideoCubit(
        videoPlayerRepository: rootLocator<IVideoPlayerRepository>(),
      ),
    );
  }
}
