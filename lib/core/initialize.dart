import 'package:get_it/get_it.dart';
import 'package:video_rotate/voomp_play_video/voomp_play_video_module_injector.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/services/player_controller_registry.dart';

final rootLocator = GetIt.instance;


initializeDependencies(){
    VoompPlayVideoModuleInjector.setup();
    rootLocator.registerLazySingleton<PlayerControllerCubit>(() => PlayerControllerCubit());

}