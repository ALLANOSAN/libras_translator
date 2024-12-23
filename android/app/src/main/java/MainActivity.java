import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import java.io.ByteArrayOutputStream;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "com.example.libras/opencv";

  @Override
  public void configureFlutterEngine(FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("processFrame")) {
            byte[] frameData = call.argument("frame");
            Bitmap bitmap = BitmapFactory.decodeByteArray(frameData, 0, frameData.length);
            Bitmap processedBitmap = VideoProcessor.processFrame(bitmap);

            ByteArrayOutputStream stream = new ByteArrayOutputStream();
            processedBitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
            byte[] processedFrame = stream.toByteArray();

            result.success(processedFrame);
          } else {
            result.notImplemented();
          }
        }
      );
  }
}
