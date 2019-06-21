//
//  CameraView.swift
//  Roma Chat
//
//  Created by Drasko Vucenovic on 2019-03-11.
//  Copyright © 2019 Barrett Breshears. All rights reserved.
//

import UIKit
import AVFoundation

protocol CameraViewDelegate: AnyObject {
    func imageTaken(image: UIImage)
}

class CameraView: UIView, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    
    var captureDevice:AVCaptureDevice!
    
    weak var delegate: CameraViewDelegate?
    
    var takeNextPhoto = false

    // Our custom view from the XIB file
    var view: UIView!

    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        
        // use bounds not frame or it'll be offset
        view.frame = bounds
        
        // Make the view stretch with containing view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // Adding custom subview on top of our view (over any custom drawing > see note below)
        addSubview(view)
    }
    
    func loadViewFromNib() -> UIView {
        
        let nib = UINib.init(nibName: String(describing: CameraView.self), bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        #if targetEnvironment(simulator)
        // your simulator code
        #else
            prepareCamera()
        #endif
        
    }
    
    func prepareCamera() {
//        captureSession.sessionPreset = .photo
        captureSession.sessionPreset = .hd1920x1080
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        captureDevice = availableDevices.first
        beginSession()
        
    }
    
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.previewLayer = previewLayer
        self.previewLayer.frame = UIScreen.main.bounds
        
        self.view.layer.addSublayer(self.previewLayer)
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        //Capture stream
        
        let queue = DispatchQueue(label: "com.romachat.captureQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
        
        
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //get image from sample buffer
        
        if takeNextPhoto {
            takeNextPhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {

                //if front facing camera, flip image
                if captureDevice.position == .front {
                    let flippedImage = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
                    
                    self.delegate?.imageTaken(image: flippedImage)
                    return
                }

                //show image
                self.delegate?.imageTaken(image: image)
            }
        }
        

    }
    
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
                
            }
            
        }
        return nil
    }
    
    func takePhoto() {
        takeNextPhoto = true
    }
    
    func swapCamera() {
        
            //Indicate that some changes will be made to the session
            captureSession.beginConfiguration()
            
            //Remove existing input
            guard let currentCameraInput: AVCaptureInput = captureSession.inputs.first else {
                return
            }
            
            captureSession.removeInput(currentCameraInput)
            
            //Get new input
            var newCamera: AVCaptureDevice! = nil
            if let input = currentCameraInput as? AVCaptureDeviceInput {
                if (input.device.position == .back) {
                    newCamera = cameraWithPosition(position: .front)
                } else {
                    newCamera = cameraWithPosition(position: .back)
                }
            }
            
            //Add input to session
            var err: NSError?
            var newVideoInput: AVCaptureDeviceInput!
            do {
                newVideoInput = try AVCaptureDeviceInput(device: newCamera)
            } catch let err1 as NSError {
                err = err1
                newVideoInput = nil
            }
            
            if newVideoInput == nil || err != nil {
                print("Error creating capture device input: \(String(describing: err?.localizedDescription))")
            } else {
                captureSession.addInput(newVideoInput)
            }
            
            //Commit all the configuration changes at once
            captureSession.commitConfiguration()
        
        
    }

    // Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
    func cameraWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
        for device in discoverySession.devices {
            if device.position == position {
                return device
            }
        }
        
        return nil
    }
    
}
