import AVFoundation
import fl_camera
import Flutter
import Foundation
import MLKitTextRecognition
import MLKitTextRecognitionChinese
import MLKitTextRecognitionJapanese
import MLKitVision

class FlMlKitTextRecognizeMethodCall: FlCameraMethodCall {
    var options: CommonTextRecognizerOptions = TextRecognizerOptions()
    var analyzing: Bool = false
    var scan: Bool = false

    override init(_ _registrar: FlutterPluginRegistrar) {
        super.init(_registrar)
    }

    override func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startPreview":
            startPreview({ [self] sampleBuffer in
                if !analyzing, scan {
                    analyzing = true
                    let buffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                    self.analysis(buffer!.image, nil)
                }
            }, call: call, result)
        case "setRecognizedLanguage":
            setRecognizedLanguage(call)
            result(true)
        case "scanImageByte":
            let arguments = call.arguments as! [AnyHashable: Any?]
            let useEvent = arguments["useEvent"] as! Bool
            let uint8list = arguments["byte"] as! FlutterStandardTypedData?
            if uint8list != nil {
                let image = UIImage(data: uint8list!.data)
                if image != nil {
                    analysis(image!, useEvent ? nil : result)
                    return
                }
            }
            result([])
        case "getScanState":
            result(scan)
        case "scan":
            let argument = call.arguments as! Bool
            if argument != scan {
                scan = argument
            }
            result(true)
        default:
            super.handle(call: call, result: result)
        }
    }

    func setRecognizedLanguage(_ call: FlutterMethodCall) {
        let type = call.arguments as! String
        switch type {
        case "pattern":
            options = TextRecognizerOptions()
        case "chinese":
            options = ChineseTextRecognizerOptions()
        case "japanese":
            options = JapaneseTextRecognizerOptions()
        default:
            options = TextRecognizerOptions()
        }
    }

    func analysis(_ image: UIImage, _ result: FlutterResult?) {
        let visionImage = VisionImage(image: image)
        if flCamera == nil {
            visionImage.orientation = .up
        } else {
            visionImage.orientation = flCamera!.imageOrientation()
        }
        let textRecognizer = TextRecognizer.textRecognizer(options: options)
        textRecognizer.process(visionImage) { [self] visionText, error in
            if error == nil, visionText != nil {
                var map = visionText!.data
                map.updateValue(image.size.height, forKey: "height")
                map.updateValue(image.size.width, forKey: "width")
                if result == nil {
                    flCameraEvent?.sendEvent(map)
                } else {
                    result!(map)
                }
            }
            analyzing = false
        }
    }
}

extension CVBuffer {
    var image: UIImage {
        let ciImage = CIImage(cvPixelBuffer: self)
        let cgImage = CIContext().createCGImage(ciImage, from: ciImage.extent)
        return UIImage(cgImage: cgImage!)
    }

    var image1: UIImage {
        // Lock the base address of the pixel buffer
        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
        // Get the number of bytes per row for the pixel buffer
        let baseAddress = CVPixelBufferGetBaseAddress(self)
        // Get the number of bytes per row for the pixel buffer
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        // Get the pixel buffer width and height
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        // Create a device-dependent RGB color space
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        // Create a bitmap graphics context with the sample buffer data
        var bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue
        bitmapInfo |= CGImageAlphaInfo.premultipliedFirst.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        // let bitmapInfo: UInt32 = CGBitmapInfo.alphaInfoMask.rawValue
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        // Create a Quartz image from the pixel data in the bitmap graphics context
        let quartzImage = context?.makeImage()
        // Unlock the pixel buffer
        CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags.readOnly)
        // Create an image object from the Quartz image
        return UIImage(cgImage: quartzImage!)
    }
}

extension CGRect {
    var data: [String: Any?] {
        return [
            "x": origin.x,
            "y": origin.y,
            "width": width,
            "height": height,
        ]
    }
}

extension Text {
    var data: [String: Any?] {
        ["text": text,
         "textBlocks": blocks.map { $0.data }]
    }
}

extension TextBlock {
    var data: [String: Any?] {
        ["text": text,
         "recognizedLanguages": recognizedLanguages.map { $0.languageCode },
         "boundingBox": frame.data,
         "lines": lines.map { $0.data },
         "corners": cornerPoints.map { $0.cgPointValue.data }]
    }
}

extension TextLine {
    var data: [String: Any?] {
        ["text": text,
         "recognizedLanguages": recognizedLanguages.map { $0.languageCode },
         "elements": elements.map { $0.data },
         "boundingBox": frame.data,
         "corners": cornerPoints.map { $0.cgPointValue.data }]
    }
}

extension TextElement {
    var data: [String: Any?] {
        ["text": text,
         "boundingBox": frame.data,
         "corners": cornerPoints.map { $0.cgPointValue.data }]
    }
}

extension CGPoint {
    var data: [String: Any?] {
        ["x": NSNumber(value: x.native), "y": NSNumber(value: y.native)]
    }
}
