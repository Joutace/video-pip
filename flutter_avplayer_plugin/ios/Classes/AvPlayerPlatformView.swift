import Flutter
import UIKit
import AVKit

final class AvPlayerPlatformView: NSObject, FlutterPlatformView {
  private let container = UIView()
  private let channel: FlutterMethodChannel

  private let playerVC = AVPlayerViewController()
  private var player: AVPlayer?
  private var pipController: AVPictureInPictureController?

  init(frame: CGRect, viewId: Int64, args: [String: Any]?, messenger: FlutterBinaryMessenger) {
    self.channel = FlutterMethodChannel(
      name: "flutter_avplayer_plugin/methods_\(viewId)",
      binaryMessenger: messenger
    )
    super.init()

    container.backgroundColor = .black

    // Registrar handlers de métodos
    channel.setMethodCallHandler { [weak self] call, result in
      guard let self = self else { return }
      switch call.method {
      case "loadUrl":
        guard
          let params = call.arguments as? [String: Any],
          let urlStr = params["url"] as? String,
          let url = URL(string: urlStr)
        else {
          result(FlutterError(code: "bad_args", message: "url missing/invalid", details: nil))
          return
        }
        let autoPlay = (params["autoPlay"] as? Bool) ?? true
        self.loadUrl(url: url, autoPlay: autoPlay)
        result(nil)

      case "play":
        self.player?.play()
        result(nil)

      case "pause":
        self.player?.pause()
        result(nil)

      case "startPiP":
        self.startPiP()
        result(nil)

      case "stopPiP":
        self.pipController?.stopPictureInPicture()
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Carrega se vier creationParams
    if let urlStr = (args?["url"] as? String), let url = URL(string: urlStr) {
      let autoPlay = (args?["autoPlay"] as? Bool) ?? true
      loadUrl(url: url, autoPlay: autoPlay)
    }

    embedPlayerViewController()
  }

  func view() -> UIView {
    return container
  }

  private func embedPlayerViewController() {
    // Tenta fazer containment correto no rootViewController
    if let rootVC = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .flatMap({ $0.windows })
      .first(where: { $0.isKeyWindow })?
      .rootViewController {

      rootVC.addChild(playerVC)
      playerVC.view.frame = container.bounds
      playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(playerVC.view)
      playerVC.didMove(toParent: rootVC)
    } else {
      // Fallback: adiciona a view diretamente
      playerVC.view.frame = container.bounds
      playerVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      container.addSubview(playerVC.view)
    }
  }

  private func loadUrl(url: URL, autoPlay: Bool) {
    let item = AVPlayerItem(url: url)
    let player = AVPlayer(playerItem: item)
    self.player = player

    playerVC.player = player
    playerVC.allowsPictureInPicturePlayback = true
    if #available(iOS 14.2, *) {
      playerVC.canStartPictureInPictureAutomaticallyFromInline = true
    }

    // Cria um playerLayer para o PiP manual (mesmo AVPlayer do playerVC)
    let layer = AVPlayerLayer(player: player)
    layer.frame = .zero

    if AVPictureInPictureController.isPictureInPictureSupported() {
      if #available(iOS 15.0, *) {
        let contentSource = AVPictureInPictureController.ContentSource(playerLayer: layer)
        pipController = AVPictureInPictureController(contentSource: contentSource)
      } else {
        pipController = AVPictureInPictureController(playerLayer: layer)
      }
    }

    if autoPlay { player.play() }
  }

  private func startPiP() {
    guard let pip = pipController else { return }
    if !pip.isPictureInPictureActive {
      pip.startPictureInPicture()
    }
  }
}
