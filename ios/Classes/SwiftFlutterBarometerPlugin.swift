import Flutter
import UIKit
import CoreMotion

public class SwiftFlutterBarometerPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    init(_ messenger: FlutterBinaryMessenger) {
        eventChannel = FlutterEventChannel(name: "flutter_barometer/event", binaryMessenger: messenger)
        super.init()
        eventChannel.setStreamHandler(self)
    }

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_barometer/method", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterBarometerPlugin(registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    private lazy var altimeter = CMAltimeter.init()

    private let eventChannel: FlutterEventChannel

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "isValid" {
            result(CMAltimeter.isRelativeAltitudeAvailable())
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        altimeter.startRelativeAltitudeUpdates(to: OperationQueue.main) { data, error in
            if let data = data {
                events(["pressure": data.pressure, "altitude": data.relativeAltitude])
            }
        }
        return nil
    }


    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        altimeter.stopRelativeAltitudeUpdates()
        return nil
    }
}
