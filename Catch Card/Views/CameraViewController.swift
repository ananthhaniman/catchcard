//
//  ViewController.swift
//  Catch Card
//
//  Created by Ananthamoorthy Haniman on 2022-04-24.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa

class CameraViewController: UIViewController {
    
    private var cameraView:AVCaptureVideoPreviewLayer  = {
        let cameraView = AVCaptureVideoPreviewLayer()
        return cameraView
    }()
    
    private var cameraViewFrame:UIView = {
        let cameraViewFrame = UIView()
        cameraViewFrame.backgroundColor = .black
        return cameraViewFrame
    }()
    
    private let logoImageView: UIImageView = {
        let logoImageView = UIImageView(image: UIImage(named: "Logo"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }()
    
    private let messageLabel:UILabel = {
        let messageLabel = UILabel()
        messageLabel.textColor = .blue
        return messageLabel
    }()
    
    private var cameraViewModel:CameraViewModel = CameraViewModel(
        captureSession: AVCaptureSession(),
        dataOutput: AVCaptureVideoDataOutput()
    )
    
    private var flashLightBtn:UIButton = {
        let flashBtn = UIButton()
        flashBtn.setImage(UIImage(named: "FlashIconOff"), for: .normal)
        flashBtn.setImage(UIImage(named: "FlashIconOn"), for: .selected)
        flashBtn.layer.cornerRadius = 20
        flashBtn.backgroundColor = .black
        flashBtn.translatesAutoresizingMaskIntoConstraints = false
        
        return flashBtn
    }()
    
    private let disposeBag = DisposeBag()
    
    private var errorMessage:CameraErrors?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for: .video, position: .back) {
            cameraViewModel.requestCamera(captureDevice: cameraDevice)
        }
        
        
        
    }
    
    private func setupBindings(){
        cameraViewModel
            .cameraSession
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { session in
                self.cameraView.session = session
            })
            .disposed(by: disposeBag)
        
        cameraViewModel
            .error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:{ errors in
                print(errors)
            })
            .disposed(by: disposeBag)
        
        cameraViewModel
            .hasFlashLight
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { status in
                if status {
                    self.flashLightBtn.alpha = 1
                }else{
                    self.flashLightBtn.alpha = 0
                }
            }).disposed(by: disposeBag)
        
        cameraViewModel
            .flashLightStatus
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { status in
                if status {
                    self.flashLightBtn.isSelected = true
                }else{
                    self.flashLightBtn.isSelected = false
                }
            }).disposed(by: disposeBag)
        
        
        
        flashLightBtn.rx.tap.subscribe(onNext:{
            self.cameraViewModel.flashLightToggle()
        }).disposed(by: disposeBag)
        
        
    }
    
    
    private func setupUI() {
        view.backgroundColor = .black
        
        cameraViewFrame.frame = view.frame
        cameraView.frame = cameraViewFrame.layer.bounds
        cameraView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraViewFrame.layer.addSublayer(cameraView.self)
        messageLabel.center = view.center
        
        view.addSubview(cameraViewFrame)
        view.addSubview(logoImageView)
        view.addSubview(messageLabel)
        view.addSubview(flashLightBtn)
        
        applyConstraints()
    }
    
    private func applyConstraints(){
        
        let logoImageViewConstrains = [
            logoImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant:20),
            logoImageView.widthAnchor.constraint(equalToConstant: 140),
            logoImageView.heightAnchor.constraint(equalToConstant: 45)
        ]
        
        let flashLightBtnConstrains = [
            flashLightBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -20),
            flashLightBtn.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant:20),
            flashLightBtn.widthAnchor.constraint(equalToConstant: 39),
            flashLightBtn.heightAnchor.constraint(equalToConstant: 39)
        ]
        
        NSLayoutConstraint.activate(logoImageViewConstrains)
        NSLayoutConstraint.activate(flashLightBtnConstrains)
        
        
    }
    
    
    
    
}

