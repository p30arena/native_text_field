import Flutter
import UIKit

public class SwiftNativeTextFieldPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    registrar.register(NativeTextFieldFactory(with: registrar), withId: "native_text_field")
  }
}

public class NativeTextFieldFactory: NSObject, FlutterPlatformViewFactory {
    let registrar: FlutterPluginRegistrar
    
    init(with registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
    }
    
    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeTextField(frame, viewId: viewId, args: args, registrar: registrar)
    }
}

public class NativeTextField: NSObject, FlutterPlatformView, FlutterStreamHandler {
    let registrar: FlutterPluginRegistrar
    let frame: CGRect
    let viewId: Int64
    let textField: UITextField
    var eventSink: FlutterEventSink?
    
    init(_ frame: CGRect, viewId: Int64, args: Any?, registrar: FlutterPluginRegistrar) {
        self.frame = frame
        self.viewId = viewId
        self.registrar = registrar
        self.textField = UITextField(frame: frame)
        
        super.init()
        
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)),
        for: .editingChanged)
        
        let channel = FlutterMethodChannel(name: "native_text_field_" + String(viewId), binaryMessenger: registrar.messenger())
        let eventChannel = FlutterEventChannel(name: "native_text_field_" + String(viewId) + "/text_change", binaryMessenger: registrar.messenger())
        channel.setMethodCallHandler(self.handle)
        eventChannel.setStreamHandler(self)
    }
    
    public func view() -> UIView {
        return textField
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "setText" {
            let text = call.arguments as? String
            textField.text = text!
            result(true)
            return
        } else if call.method == "setFont" {
            let asset = call.arguments as? String
            let bundle = Bundle.main
            let fontKey = registrar.lookupKey(forAsset: asset!)
            let path = bundle.path(forResource: fontKey, ofType: nil)
            let fontData = NSData(contentsOfFile: path ?? "")
            let dataProvider = CGDataProvider(data: fontData!)
            let fontRef = CGFont(dataProvider!)
            var errorRef: Unmanaged<CFError>? = nil
            if let fr = fontRef {
                let fontName = fr.fullName as? String
                CTFontManagerRegisterGraphicsFont(fr, &errorRef)
//                CGFontRelease(fr)
                textField.font = UIFont(name: fontName!, size: textField.font!.pointSize)
            }
        }
      result("iOS " + UIDevice.current.systemVersion)
    }
    
    public func onListen(withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        return nil
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if let events = eventSink {
            events(textField.text)
        }
    }
}
