import Flutter
import UIKit

public class FlutterAvplayerPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let factory = AvPlayerViewFactory(messenger: registrar.messenger())
    registrar.register(factory, withId: "flutter_avplayer_plugin/view")
  }
}
