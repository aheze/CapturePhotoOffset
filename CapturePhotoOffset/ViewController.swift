//
//  ViewController.swift
//  CapturePhotoOffset
//
//  Created by Zheng on 6/13/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var outputImageView: UIImageView!
    
    var captured = false
    @IBAction func capturePressed(_ sender: Any) {
        captured.toggle()
        
        if captured {
            let photoSettings = AVCapturePhotoSettings()
            if let photoPreviewType = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoPreviewType]
                photoOutput.capturePhoto(with: photoSettings, delegate: self)
            }
        } else {
            outputImageView.alpha = 0
        }
    }
    
    let avSession = AVCaptureSession()
    let videoDataOutput = AVCaptureVideoDataOutput()
    let photoOutput = AVCapturePhotoOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: cameraDevice)
            if avSession.canAddInput(captureDeviceInput) {
                avSession.addInput(captureDeviceInput)
                avSession.sessionPreset = .photo
            }
        } catch {
            print("Error: \(error)")
        }
        
        if avSession.canAddOutput(photoOutput) {
            avSession.addOutput(photoOutput)
        }
        
        previewView.videoPreviewLayer.frame = view.layer.bounds
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.session = self.avSession
        
        avSession.startRunning()
        outputImageView.alpha = 0
    }
}

extension ViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            let previewImage = UIImage(data: imageData)
            outputImageView.image = previewImage
            outputImageView.alpha = 1
        }
    }
}

/// photo preview
class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
    var session: AVCaptureSession? {
        get { return videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
}
