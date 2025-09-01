import 'package:flutter/material.dart';
import 'package:video_rotate/voomp_play_video/features/voomp_play_video/presenter/views/voomp_play_video.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class LessonContent extends StatelessWidget {
  const LessonContent({
    super.key,
    required this.content,
    this.barrierFullScreen = true,
  });

  final String content;
  final bool barrierFullScreen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: HtmlWidget(
        (barrierFullScreen) ? _modifyIframe(content) : content,
        // textStyle: TextStyle(
        //   color: AppColors.getColorByTheme(
        //     dark: AppColors().colors.white,
        //     light: AppColors().colors.black,
        //   ),
        // ),
        customWidgetBuilder: (element) {
          if (element.localName == 'iframe') {
            final src = element.attributes['src'];

            if (src != null) {
              return SizedBox(
                height: 212,
                child: Center(
                  child: VoompPlayVideo(
                    url: src,
                    barrierFullScreen: barrierFullScreen,
                    autoPlay: false,
                  ),
                ),
              );
            }
          }
          return null;
        },
        onLoadingBuilder: (context, element, loadingProgress) =>
            const CircularProgressIndicator(),
        onErrorBuilder: (context, element, error) =>
            Text('erro ao carregar', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  String _modifyIframe(String content) {
    final modifiedContent = content.replaceAll(
      'allowfullscreen="true"',
      'allowfullscreen="false"',
    );
    return modifiedContent;
  }
}
