import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_avplayer_plugin/flutter_avplayer_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:video_rotate/mocks/lessons.mock.dart';

class LessonViewIOS extends StatefulWidget {
  const LessonViewIOS({super.key, required this.lesson});
  final LessonMock lesson;

  @override
  State<LessonViewIOS> createState() => _LessonViewIOSState();
}

class _LessonViewIOSState extends State<LessonViewIOS> {
  final controller = AvPlayerController();

  String? _resolvedUrl;
  String? _error;
  bool _resolving = true;

  @override
  void initState() {
    super.initState();
    _resolveAndLoad();
  }

  Future<void> _resolveAndLoad() async {
    final original = widget.lesson.source?.trim() ?? '';
    setState(() {
      _resolving = true;
      _error = null;
    });

    try {
      final resolved = await _resolveHlsUrl(original);
      setState(() {
        _resolvedUrl = resolved;
      });
    } catch (e) {
      setState(() {
        _error = 'Falha ao resolver URL: $e';
        _resolvedUrl = original; // fallback
      });
    } finally {
      setState(() {
        _resolving = false;
      });
    }
  }

  /// Tenta obter uma URL HLS (.m3u8) a partir de um link de página/embed.
  /// - Mantém o original se já for .m3u8 ou MP4.
  /// - Faz GET no HTML e procura por qualquer .m3u8.
  /// - Políticas:
  ///   * YouTube: não extrai.
  ///   * Vimeo (free): não extrai sem API paga.
  Future<String> _resolveHlsUrl(String url) async {
    if (url.isEmpty) throw 'URL vazia';

    final uri = Uri.parse(url);

    // 1) Se já for .m3u8, usa direto
    if (_looksLikeHls(url)) return url;

    // 2) Se for MP4 / arquivo direto suportado, usa direto
    if (_looksLikeDirectMedia(url)) return url;

    // 3) Políticas por domínio — não extrair:
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
    // aceita querystring depois de .m3u8
    return RegExp(r'\.m3u8($|\?)', caseSensitive: false).hasMatch(url);
  }

  bool _looksLikeDirectMedia(String url) {
    // formatos comuns servidos direto (AVPlayer toca)
    return RegExp(r'\.(mp4|mov|m4v)($|\?)', caseSensitive: false).hasMatch(url);
  }

  /// Baixa HTML (ou JSON) e procura por uma URL .m3u8 usando regex.
  /// Também tenta resolver URLs relativas.
  Future<String?> _findM3u8InHtml(String pageUrl) async {
    final uri = Uri.parse(pageUrl);

    try {
      final resp = await http
          .get(
            uri,
            headers: {
              // alguns players servem conteúdo com user-agents específicos;
              // um UA genérico ajuda a evitar bloqueios simples
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

      // Regex genérica para capturar .m3u8
      final re = RegExp(
        r'''(https?:\/\/[^\s'"]+?\.m3u8[^\s'"]*)''',
        multiLine: true,
        caseSensitive: false,
      );

      final match = re.firstMatch(body);
      if (match != null) {
        return match.group(1);
      }

      // Tentar URLs relativas contendo .m3u8
      final reRel = RegExp(
        r'''["\']([^"\']+?\.m3u8[^"\']*)["\']''',
        multiLine: true,
        caseSensitive: false,
      );
      final matchRel = reRel.firstMatch(body);
      if (matchRel != null) {
        final rel = matchRel.group(1)!;
        // Resolve relativo com base na página
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AVPlayer + PiP (iOS)')),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _resolving
                ? const Center(child: CircularProgressIndicator())
                : _resolvedUrl == null
                ? _ErrorBox(message: _error ?? 'URL inválida')
                : AvPlayerView(
                    url: _resolvedUrl!,
                    autoPlay: true,
                    controller: controller,
                  ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.red),
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
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _resolvedUrl = null;
                    _resolving = true;
                    _error = null;
                  });
                  // exemplo: trocar para outra página/URL
                  final next = 'https://example.com/outro_stream_page.html';
                  try {
                    final resolved = await _resolveHlsUrl(next);
                    setState(() {
                      _resolvedUrl = resolved;
                    });
                    // já carregue no player em execução
                    await controller.loadUrl(resolved, autoPlay: true);
                  } catch (e) {
                    setState(() {
                      _error = 'Falha ao resolver nova URL: $e';
                      _resolvedUrl = next;
                    });
                    await controller.loadUrl(next, autoPlay: true);
                  } finally {
                    setState(() {
                      _resolving = false;
                    });
                  }
                },
                child: const Text('Trocar URL (resolver HLS)'),
              ),
            ],
          ),
        ],
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
