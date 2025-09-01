import 'package:video_rotate/core/base_state.dart';

class IosLessonState extends BaseState {
  IosLessonState({
    required super.loading,
    required super.errorMessage,
    this.source,
  });

  final String? source;

  factory IosLessonState.initial() {
    return IosLessonState(
      loading: BaseLoadingState.initial,
      errorMessage: null,
    );
  }

  IosLessonState copyWith({
    String? errorMessage,
    BaseLoadingState? loading,
    String? source,
  }) {
    return IosLessonState(
      loading: loading ?? this.loading,
      source: source ?? this.source,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
