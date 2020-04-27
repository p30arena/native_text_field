package ir.yabco.native_text_field;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * NativeTextFieldPlugin
 */
public class NativeTextFieldPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    flutterPluginBinding
        .getPlatformViewRegistry()
        .registerViewFactory(
            "native_text_field", new NativeTextFieldFactory(flutterPluginBinding.getBinaryMessenger()));
  }

  public static void registerWith(Registrar registrar) {
    registrar
        .platformViewRegistry()
        .registerViewFactory(
            "native_text_field", new NativeTextFieldFactory(registrar.messenger()));
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }
}
