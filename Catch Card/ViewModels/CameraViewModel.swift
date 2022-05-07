//
//  CameraViewModel.swift
//  Catch Card
//
//  Created by Ananthamoorthy Haniman on 2022-04-29.
//

import Foundation
import AVFoundation
import RxSwift
import RxCocoa

class CameraViewModel{
    
    private var captureSession:AVCaptureSession?
    private var captureOutput:AVCaptureOutput?
    private var output:AVCaptureVideoDataOutput?
    private var device:AVCaptureDevice?
    
    public let cameraSession: PublishSubject<AVCaptureSession> = PublishSubject()
    public let error: PublishSubject<CameraErrors> = PublishSubject()
    public let flashLightStatus: PublishSubject<Bool> = PublishSubject()
    public let hasFlashLight: PublishSubject<Bool> = PublishSubject()
    
    
    init(captureSession: AVCaptureSession,
         dataOutput:AVCaptureVideoDataOutput
    ) {
        
        self.captureSession = captureSession
        self.output = dataOutput
        
    }
    
    
    func requestCamera(captureDevice: AVCaptureDevice){
        self.device = captureDevice
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if !granted {
                self.error.onNext(CameraErrors.premissionError(message: "Camera Premisson not given"))
            }
        }
        
        guard
            let captureDeviceInput = try? AVCaptureDeviceInput(device: device!),
            captureSession!.canAddInput(captureDeviceInput)
        else {
            return
        }
        
        output?.videoSettings = [String(kCVPixelBufferPixelFormatTypeKey):
                                    NSNumber(value: kCVPixelFormatType_32BGRA)]
        output?.connection(with: AVMediaType.video)?.videoOrientation = .portrait
        output?.alwaysDiscardsLateVideoFrames = true
        captureSession?.addOutput(output!)
        captureSession?.addInput(captureDeviceInput)
        cameraSession.onNext(captureSession!)
        
        captureSession?.startRunning()
        
        
        if((device?.hasTorch) != nil && (device?.isTorchAvailable) != nil){
            do {
                _ = try device?.lockForConfiguration()
            } catch {
                self.error.onNext(CameraErrors.torchError(message: "Unable to access camera property "))
            }
            hasFlashLight.onNext(true)
            let torchStatus = device?.isTorchActive
            flashLightStatus.onNext(torchStatus!)
            device?.unlockForConfiguration()
        }else{
            hasFlashLight.onNext(false)
        }
        
    }
    
    
    
    func flashLightToggle() {
        if let cameraDevice = device {
            if(cameraDevice.hasTorch && cameraDevice.isTorchAvailable){
                do {
                    _ = try cameraDevice.lockForConfiguration()
                } catch {
                    self.error.onNext(CameraErrors.torchError(message: "Unable to access camera property "))
                }
                // check if your torchMode is on or off. If on turns it off otherwise turns it on
                if cameraDevice.isTorchActive {
                    cameraDevice.torchMode = AVCaptureDevice.TorchMode.off
                    self.flashLightStatus.onNext(false)
                } else {
                    // sets the torch intensity to 100%
                    do {
                        _ = try cameraDevice.setTorchModeOn(level: 0.7)
                        self.flashLightStatus.onNext(true)
                    } catch {
                        self.error.onNext(CameraErrors.torchError(message: "Unable to turn on the flash light"))
                    }
                }
                cameraDevice.unlockForConfiguration()
                
                
            }else{
                hasFlashLight.onNext(false)
            }
        }
    }
    
    
    
    
    
    
    
    
    
}
