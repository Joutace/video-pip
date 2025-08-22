import 'features/voomp_play_video/di/voomp_play_video_injector.dart';
import 'features/voomp_play_video_url/di/voomp_play_video_url_injector.dart';
import 'features/voomp_play_video_youtube/di/voomp_play_video_youtube_injector.dart';

class VoompPlayVideoModuleInjector {
  static void setup() {
    VoompPlayVideoInjector.setup();
    VoompPlayVideoURLInjector.setup();
    VoompPlayVideoYoutubeInjector.setup();
  }
}
