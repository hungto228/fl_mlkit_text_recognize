package fl.mlkit.text.recognize

import android.annotation.SuppressLint
import android.graphics.BitmapFactory
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import fl.camera.FlCameraMethodCall
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class FlMlKitTextRecognizeMethodCall(
    activityPlugin: ActivityPluginBinding,
    plugin: FlutterPlugin.FlutterPluginBinding
) :
    FlCameraMethodCall(activityPlugin, plugin) {

    private var scan = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "startPreview" -> startPreview(imageAnalyzer, call, result)
            "setBarcodeFormat" -> {
                result.success(true)
            }
            "scanImageByte" -> scanImageByte(call, result)
            "scan" -> {
                val argument = call.arguments as Boolean
                if (argument != scan) {
                    scan = argument
                }
                result.success(true)
            }
            else -> {
                super.onMethodCall(call, result)
            }
        }
    }

    private fun scanImageByte(call: MethodCall, result: MethodChannel.Result) {
        val useEvent = call.argument<Boolean>("useEvent")!!
        val byteArray = call.argument<ByteArray>("byte")!!
        var rotationDegrees = call.argument<Int>("rotationDegrees")
        val bitmap = BitmapFactory.decodeByteArray(byteArray, 0, byteArray.size)
        if (bitmap == null) {
            result.success(null)
            return
        }
        if (rotationDegrees == null) rotationDegrees = 0
        val inputImage = InputImage.fromBitmap(bitmap, rotationDegrees)
        analysis(inputImage, if (useEvent) null else result, null)
    }

    @SuppressLint("UnsafeOptInUsageError")
    private val imageAnalyzer = ImageAnalysis.Analyzer { imageProxy ->
        val mediaImage = imageProxy.image
        if (mediaImage != null && scan) {
            val inputImage =
                InputImage.fromMediaImage(mediaImage, imageProxy.imageInfo.rotationDegrees)
            analysis(inputImage, null, imageProxy)
        } else {
            imageProxy.close()
        }
    }


    private fun analysis(
        inputImage: InputImage,
        result: MethodChannel.Result?,
        imageProxy: ImageProxy?
    ) {
        val barcodeList: ArrayList<Map<String, Any?>> = ArrayList()

    }


}
