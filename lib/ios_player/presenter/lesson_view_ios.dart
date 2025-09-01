import 'package:flutter/material.dart';
import 'package:flutter_avplayer_plugin/flutter_avplayer_plugin.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_rotate/core/base_state.dart';
import 'package:video_rotate/core/initialize.dart';
import 'package:video_rotate/ios_player/cubit/ios_lesson_cubit.dart';
import 'package:video_rotate/ios_player/cubit/ios_lesson_state.dart';
import 'package:video_rotate/mocks/lessons.mock.dart';

class LessonViewIOS extends StatefulWidget {
  const LessonViewIOS({super.key, required this.lesson});
  final LessonMock lesson;

  @override
  State<LessonViewIOS> createState() => _LessonViewIOSState();
}

class _LessonViewIOSState extends State<LessonViewIOS> {
  final controller = AvPlayerController();
  late IosLessonCubit cubit;

  @override
  void initState() {
    cubit = rootLocator.get<IosLessonCubit>();
    cubit.resolveAndLoad(widget.lesson.source);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AVPlayer + PiP (iOS)')),
      body: BlocBuilder<IosLessonCubit, IosLessonState>(
        bloc: cubit,
        builder: (context, state) {
          return Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: state.loading == BaseLoadingState.loading
                    ? const Center(child: CircularProgressIndicator())
                    : state.source == null
                    ? _ErrorBox(message: state.errorMessage ?? 'URL inválida')
                    : AvPlayerView(
                        url: state.source!,
                        autoPlay: true,
                        controller: controller,
                      ),
              ),
              const SizedBox(height: 16),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
                  ),
                ),
              Wrap(
                spacing: 12,
                children: [
                  ElevatedButton(
                    onPressed: () => controller.play(),
                    child: const Text('Play'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.pause(),
                    child: const Text('Pause'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.startPiP(),
                    child: const Text('Start PiP'),
                  ),
                  ElevatedButton(
                    onPressed: () => controller.stopPiP(),
                    child: const Text('Stop PiP'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black12,
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      ),
    );
  }
}
