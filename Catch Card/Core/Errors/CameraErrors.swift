//
//  CameraErrors.swift
//  Catch Card
//
//  Created by Ananthamoorthy Haniman on 2022-05-07.
//

import Foundation

enum CameraErrors: Error{
    case premissionError(message:String)
    case DeviceError(message:String)
    case torchError(message:String)
}
