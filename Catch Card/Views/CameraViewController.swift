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
import CoreTelephony

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
        let logoImageView = UIImageView(image: UIImage(named: "LogoLight"))
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit
        return logoImageView
    }()
    
    private let messageLabel:UILabel = {
        let messageLabel = UILabel()
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 100
        return messageLabel
    }()
    
    private let cameraViewModel:CameraViewModel = CameraViewModel(
        captureSession: AVCaptureSession(),
        dataOutput: AVCaptureVideoDataOutput()
    )
    
    private let carrierProviderViewModel:CarrierProviderViewModel = CarrierProviderViewModel(
        telephonyNetworkInfo: CTTelephonyNetworkInfo()
    )
    
    private var flashLightBtn:UIButton = {
        let flashBtn = UIButton()
        flashBtn.setImage(UIImage(named: "FlashIconOff"), for: .normal)
        flashBtn.setImage(UIImage(named: "FlashIconOn"), for: .selected)
        flashBtn.layer.cornerRadius = 20
        flashBtn.backgroundColor = .black
        flashBtn.alpha = 0
        flashBtn.translatesAutoresizingMaskIntoConstraints = false
        
        return flashBtn
    }()
    
    
    private var simSwitchBtn:UIButton = {
        let simSwitchBtn = UIButton()
        simSwitchBtn.layer.cornerRadius = 20
        simSwitchBtn.backgroundColor = .systemBlue
        simSwitchBtn.translatesAutoresizingMaskIntoConstraints = false
        simSwitchBtn.setImage(UIImage(named: "SwitchSim")?.resizedImage(Size: CGSize(width: 20, height: 20)), for: .normal)
        simSwitchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        simSwitchBtn.alpha = 0
        
        
        return simSwitchBtn
    }()
    
    private let disposeBag = DisposeBag()
    
    private var errorMessage:CameraErrors?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
        if let cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera,for: .video, position: .back) {
            cameraViewModel.requestCamera(captureDevice: cameraDevice)
        }else{
            self.messageLabel.text = "We can't find your device camera. In order to continue, camera access required"
        }
        
    }
    
    private func setupBindings(){
        cameraViewModel
            .cameraSession
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { session in
                self.cameraView.session = session
                self.flashLightBtn.alpha = 1
                self.carrierProviderViewModel.requestCarrierInfo()
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
        
        cameraViewModel
            .error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:{ error in
                switch error{
                case .premissionError(let message):
                    self.messageLabel.text = message
                case .DeviceError(message: let message):
                    self.messageLabel.text = message
                case .torchError(message: let message):
                    self.messageLabel.text = message
                }
            })
            .disposed(by: disposeBag)
        
        carrierProviderViewModel
            .carriers
            .observe(on: MainScheduler.instance)
            .subscribe(onNext:{ carriers in
                print(carriers)
                if !carriers.isEmpty {
                    self.simSwitchBtn.alpha = 1
                    
                    if carriers.count > 1 {
                        self.simSwitchBtn.setTitle("   \(String(describing: carriers[0].carrierName!))", for: .normal)
                        self.simSwitchBtn.setTitle("   \(String(describing: carriers[1].carrierName!))", for: .selected)
                    }
                    
                }
                
                
            }).disposed(by: disposeBag)
        
        
    }
    
    
    private func setupUI() {
        view.backgroundColor = .black
        
        cameraViewFrame.frame = view.frame
        cameraView.frame = cameraViewFrame.layer.bounds
        cameraView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraViewFrame.layer.addSublayer(cameraView.self)
        
        view.addSubview(cameraViewFrame)
        view.addSubview(logoImageView)
        view.addSubview(flashLightBtn)
        view.addSubview(messageLabel)
        view.addSubview(simSwitchBtn)
        
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
        
        let messageLabelConstrains = [
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            messageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        
        let simSwicthBtnConstrains = [
            simSwitchBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            simSwitchBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            simSwitchBtn.widthAnchor.constraint(equalToConstant: 105),
            simSwitchBtn.heightAnchor.constraint(equalToConstant: 39)
        ]
        
        NSLayoutConstraint.activate(logoImageViewConstrains)
        NSLayoutConstraint.activate(flashLightBtnConstrains)
        NSLayoutConstraint.activate(messageLabelConstrains)
        NSLayoutConstraint.activate(simSwicthBtnConstrains)
        
        
    }
    
    
    
    
}

