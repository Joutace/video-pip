import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'package:video_rotate/core/base_state.dart';
import 'package:video_rotate/ios_player/cubit/ios_lesson_state.dart';

class IosLessonCubit extends Cubit<IosLessonState> {
  IosLessonCubit() : super(IosLessonState.initial());
  Future<void> resolveAndLoad(String? source) async {
    final original = source?.trim() ?? '';

    emit(state.copyWith(loading: BaseLoadingState.loading));

    try {
      final resolved = await _resolveHlsUrl(original);
      emit(state.copyWith(source: resolved));
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Falha ao resolver URL: $e',
          loading: BaseLoadingState.error,
        ),
      );
    }
  }

  Future<String> _resolveHlsUrl(String url) async {
    if (url.isEmpty) throw 'URL vazia';

    final uri = Uri.parse(url);

    if (_looksLikeHls(url)) return url;

    if (_looksLikeDirectMedia(url)) return url;

    final host = (uri.host).toLowerCase();

    // YouTube: NÃO extrair (ToS)
    if (host.contains('youtube.com') || host.contains('youtu.be')) {
      throw 'YouTube não permite extração de HLS via link público.';
    }

    // Vimeo (free): sem API paga, NÃO extrair
    if (host.contains('vimeo.com')) {
      throw 'Vimeo (plano gratuito) não expõe HLS via link público.';
    }

    // Para os demais (ex.: MediaStream, Panda embed, páginas próprias),
    // tentamos buscar qualquer .m3u8 no HTML.
    final hlsFromHtml = await _findM3u8InHtml(url);
    if (hlsFromHtml != null) {
      return hlsFromHtml;
    }

    // Se não encontrou .m3u8, devolve o original (AVPlayer ainda pode tocar MP4)
    return url;
  }

  bool _looksLikeHls(String url) {
    return RegExp(r'\.m3u8($|\?)', caseSensitive: false).hasMatch(url);
  }

  bool _looksLikeDirectMedia(String url) {
    return RegExp(r'\.(mp4|mov|m4v)($|\?)', caseSensitive: false).hasMatch(url);
  }

  Future<String?> _findM3u8InHtml(String pageUrl) async {
    final uri = Uri.parse(pageUrl);

    try {
      final resp = await http
          .get(
            uri,
            headers: {
              HttpHeaders.userAgentHeader:
                  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
              HttpHeaders.acceptHeader:
                  'text/html,application/json;q=0.9,*/*;q=0.8',
            },
          )
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        return null;
      }

      final body = resp.body;

      final re = RegExp(
        r'''(https?:\/\/[^\s\'"]+?\.m3u8[^\s\'"]*)''',
        multiLine: true,
        caseSensitive: false,
      );

      final match = re.firstMatch(body);
      if (match != null) {
        return match.group(1);
      }

      final reRel = RegExp(
        r'''["\']([^"\']+?\.m3u8[^"\']*)["\']''',
        multiLine: true,
        caseSensitive: false,
      );

      final matchRel = reRel.firstMatch(body);
      if (matchRel != null) {
        final rel = matchRel.group(1)!;
        final abs = Uri.parse(rel).isAbsolute
            ? Uri.parse(rel)
            : uri.resolve(rel);
        return abs.toString();
      }

      return null;
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
