import AVFoundation
import fl_camera
import Flutter
import Foundation
import MLKitTextRecognition

class FlMlKitTextRecognizeMethodCall: FlCameraMethodCall {
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
//                    let image = VisionImage(image: buffer!.image)
//                    self.analysis(image, nil)
                }
            }, call: call, result)
        case "setBarcodeFormat":
//            setBarcodeFormat(call)
            result(true)
        case "scanImageByte":
            let arguments = call.arguments as! [AnyHashable: Any?]
            let useEvent = arguments["useEvent"] as! Bool
            let uint8list = arguments["byte"] as! FlutterStandardTypedData?
            if uint8list != nil {
                let image = UIImage(data: uint8list!.data)
                if image != nil {
//                    analysis(VisionImage(image: image!), useEvent ? nil : result)
                    return
                }
            }
            result([])
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

//    func analysis(_ image: VisionImage, _ result: FlutterResult?) {
//        if flCamera == nil {
//            image.orientation = .up
//        } else {
//            image.orientation = flCamera!.imageOrientation()
//        }
//        let scanner = BarcodeScanner.barcodeScanner(options: options)
//        scanner.process(image) { [self] barcodes, error in
//            if error == nil, barcodes != nil {
//                var list = [[String: Any?]]()
//                for barcode in barcodes! {
//                    list.append(barcode.data)
//                }
//                if result == nil {
//                    flCameraEvent?.sendEvent(list)
//                } else {
//                    result!(list)
//                }
//            }
//            analyzing = false
//        }
//    }
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
