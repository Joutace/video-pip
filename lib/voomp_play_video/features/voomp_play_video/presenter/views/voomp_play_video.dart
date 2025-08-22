import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_rotate/core/base_state.dart';
import 'package:video_rotate/core/initialize.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/data/models/enums/video_type_source.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/data/models/enums/video_type_source_remote.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/cubits/voomp_play_video_cubit.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/cubits/voomp_play_video_state.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video_url/presenter/views/player_without_youtube.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video_youtube/presenter/views/player_with_youtube.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VoompPlayVideo extends StatefulWidget {
  const VoompPlayVideo({
    super.key,
    required this.url,
    this.barrierFullScreen = false,
    this.autoPlay = false,
    this.isLive = false,
  });

  final String url;
  final bool barrierFullScreen;
  final bool isLive;
  final bool autoPlay;

  @override
  State<VoompPlayVideo> createState() => _VoompPlayVideoState();
}

class _VoompPlayVideoState extends State<VoompPlayVideo> {
  late VoompPlayVideoCubit _cubit;
  WebViewController? _controller;

  @override
  void initState() {
    _cubit = rootLocator.get<VoompPlayVideoCubit>();
    _cubit.initial(widget.url);

    if (widget.url.contains('http')) _initializeWebViewController();
    super.initState();
  }

  void _initializeWebViewController() {
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final url = widget.url.contains('vimeo') ? _getVimeoUrl() : widget.url;

    _controller = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
       ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
          "AppleWebKit/537.36 (KHTML, like Gecko) "
          "Chrome/119.0.0.0 Safari/537.36")
      ..loadRequest(Uri.parse(url));
  }

  String _getVimeoUrl() {
    //Examples
    //https://vimeo.com/991822712/bcc3816136
    //https://vimeo.com/991826386?share=copy
    //https://vimeo.com/991824092/4ce1ec7b0a?share=copy

    var url = widget.url;
    var urlSplited = widget.url.split('.com/');

    if (urlSplited.length > 1) {
      var values = urlSplited[1].split('/');

      if (values.isNotEmpty) {
        var videoId = values[0];

        if (values.length > 1) {
          var args = values[1].split('?');
          var arg = args[0];

          return 'https://player.vimeo.com/video/$videoId?h=$arg';
        }
        return 'https://player.vimeo.com/video/$videoId';
      }
    }

    return url;
  }

  @override
  void deactivate() {
    _controller?.clearCache();
    _controller?.runJavaScript("document.querySelector('video').pause();");
    super.deactivate();
  }

  @override
  void dispose() {
    _controller?.clearCache();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoompPlayVideoCubit, VoompPlayVideoState>(
      bloc: _cubit,
      listener: (BuildContext context, VoompPlayVideoState state) {
        if (state.loading == BaseLoadingState.error) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return _builderPlayer(state);
      },
    );
  }

  Widget _builderPlayer(VoompPlayVideoState state) {
    if (state.loading == BaseLoadingState.loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20),
          Text(
            'Carregando'
          ),
        ],
      );
    }

    if (state.source == null ||
        state.videoTypeSource == VideoTypeSourceEnum.none) {
      return const SizedBox.shrink();
    }

    if (state.videoTypeSource == VideoTypeSourceEnum.local) {
      return PlayerWithoutYoutube(
        play: widget.autoPlay,
        source: state.source!,
        typeSource: state.videoTypeSource,
      );
    }

    if (state.videoTypeSource == VideoTypeSourceEnum.remote) {
      if (state.videoTypeSourceRemote == VideoTypeSourceRemoteEnum.url) {
        if (_controller != null) {
          return WebViewWidget(key: UniqueKey(), controller: _controller!);
        }
      } else if (state.videoTypeSourceRemote ==
          VideoTypeSourceRemoteEnum.youtube) {
        return PlayerWithYoutube(
          isLive: widget.isLive,
          barrierFullScreen: widget.barrierFullScreen,
          play: widget.autoPlay,
          source: state.source!,
        );
      }
    }

    return const SizedBox.shrink();
  }
}
