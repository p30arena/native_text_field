package ir.yabco.native_text_field;

import android.content.Context;
import android.content.res.AssetManager;
import android.graphics.Color;
import android.graphics.Typeface;
import android.text.Editable;
import android.text.TextWatcher;
import android.view.View;
import android.widget.EditText;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.view.FlutterMain;

public class NativeTextField implements PlatformView, MethodCallHandler, EventChannel.StreamHandler {
  private final Context context;
  private final EditText editText;
  private final MethodChannel methodChannel;
  final EventChannel textChangeEventChannel;
  TextWatcher textWatcher;

  NativeTextField(Context _context, BinaryMessenger messenger, int id) {
    context = _context;
    methodChannel = new MethodChannel(messenger, "native_text_field_" + id);
    methodChannel.setMethodCallHandler(this);
    textChangeEventChannel = new EventChannel(messenger, "native_text_field_" + id + "/text_change");
    textChangeEventChannel.setStreamHandler(this);

    editText = new EditText(context);
    editText.setTextColor(Color.BLACK);
  }

  @Override
  public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
    switch (methodCall.method) {
      case "setText":
        setText(methodCall, result);
        break;
      case "setFont":
        setFont(methodCall, result);
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public View getView() {
    return editText;
  }

  @Override
  public void dispose() {

  }

  private void setText(MethodCall methodCall, MethodChannel.Result result) {
    String text = (String) methodCall.arguments;
    editText.setText(text);
    result.success(true);
  }

  private void setFont(MethodCall methodCall, MethodChannel.Result result) {
    String asset = (String) methodCall.arguments;
    final Typeface t = Typeface.createFromAsset(context.getAssets(), FlutterMain.getLookupKeyForAsset(asset));
    editText.setTypeface(t);
    result.success(true);
  }

  @Override
  public void onListen(Object o, final EventChannel.EventSink eventSink) {
    textWatcher = new TextWatcher() {
      @Override
      public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

      }

      @Override
      public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
        eventSink.success(charSequence.toString());
      }

      @Override
      public void afterTextChanged(Editable editable) {

      }
    };

    editText.addTextChangedListener(textWatcher);
  }

  @Override
  public void onCancel(Object o) {
    editText.removeTextChangedListener(textWatcher);
    textWatcher = null;
  }
}
