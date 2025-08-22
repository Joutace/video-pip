enum BaseLoadingState {
  initial,
  loading,
  loadingMore,
  loaded,
  success,
  validationSuccess,
  empty,
  error,
  validationError,
}

class BaseState {
  BaseState({
    required this.loading,
    required this.errorMessage,
  });

  final BaseLoadingState loading;
  final String? errorMessage;
}
