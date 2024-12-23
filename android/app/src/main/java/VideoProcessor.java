import org.opencv.android.OpenCVLoader;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.imgproc.Imgproc;
import org.opencv.android.Utils;
import android.graphics.Bitmap;

public class VideoProcessor {

    static {
        if (!OpenCVLoader.initDebug()) {
            // Handle initialization error
        }
    }

    public static Bitmap processFrame(Bitmap bitmap) {
        Mat mat = new Mat(bitmap.getHeight(), bitmap.getWidth(), CvType.CV_8UC4);
        Utils.bitmapToMat(bitmap, mat);
        Imgproc.cvtColor(mat, mat, Imgproc.COLOR_RGBA2GRAY);
        Utils.matToBitmap(mat, bitmap);
        return bitmap;
    }
}
