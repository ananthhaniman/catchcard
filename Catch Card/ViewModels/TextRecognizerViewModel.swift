//
//  TextRecognizerViewModel.swift
//  Catch Card
//
//  Created by Ananthamoorthy Haniman on 2022-05-09.
//

import Foundation
import MLKit
import RxSwift
import RxCocoa
import AVFoundation

class TextRecognizerViewModel {
    
    public let activeState:PublishSubject<Bool> = PublishSubject()
    private var visionImage:VisionImage?
    private var textRecognizer:TextRecognizer?
    
    public let result:BehaviorRelay<ResultModel> = BehaviorRelay(value:ResultModel(number: nil, carrier: nil, ussdStart: nil, ussdEnd: nil))
    
    init(textRecognizer:TextRecognizer) {
        self.textRecognizer = textRecognizer
    }
    
    private func imageOrientation(
        deviceOrientation: UIDeviceOrientation,
        cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return .right
        case .landscapeLeft:
            return .up
        case .portraitUpsideDown:
            return .left
        case .landscapeRight:
            return .down
        default:
            return .right
        }
    }
    
    private func isMatchPattern(for value: String,with pattern:String) -> Bool {
        let regEx = pattern
        
        let keywordPred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return keywordPred.evaluate(with: value)
    }
    
    func startListen() {
        self.activeState.onNext(true)
    }
    
    func listen(pattern:String,visionImage:VisionImage,carrier: String) {
        self.visionImage = visionImage
        if self.visionImage == nil {
            return
        }
        self.visionImage?.orientation = self.imageOrientation(
            deviceOrientation: UIDevice.current.orientation,
            cameraPosition: .back)
        
        textRecognizer?.process(self.visionImage!) { result, error in
            guard error == nil, let result = result else {
                // Error handling
                return
            }
            for block in result.blocks {
                for line in block.lines {
                    let lineText = line.text
                    if(self.isMatchPattern(for: lineText, with: pattern)){
                        self.result.accept(ResultModel(number: lineText, carrier: carrier, ussdStart: "#123*", ussdEnd: "#", isFound: true))
                    }
                }
            }
        }
    }
    
    func stopListen() {
        self.activeState.onNext(false)
    }
    
    func reset() {
        self.result.accept(ResultModel(number: nil, carrier: nil, ussdStart: nil, ussdEnd: nil, isFound: false))
    }
    
    
    
}
