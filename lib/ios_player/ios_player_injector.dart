import 'package:video_rotate/core/initialize.dart';
import 'package:video_rotate/ios_player/cubit/ios_lesson_cubit.dart';

class IosPlayerInjector {
  static void setup() {
    _cubit();
  }

  static void _cubit() {
    rootLocator.registerFactory<IosLessonCubit>(() => IosLessonCubit());
  }
}
