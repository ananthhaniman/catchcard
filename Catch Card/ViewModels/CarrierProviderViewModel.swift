//
//  CarrierProviderViewModel.swift
//  Catch Card
//
//  Created by Ananthamoorthy Haniman on 2022-05-08.
//

import Foundation
import RxSwift
import RxCocoa
import CoreTelephony

class CarrierProviderViewModel{
    
    private var networkInfo:CTTelephonyNetworkInfo?
    private var carriers:[CTCarrier] = []
    private var selectedCarrierIndex = 0
    
    public let selectedCarrier:PublishSubject<CarrierModel> = PublishSubject()
    
    init(telephonyNetworkInfo:CTTelephonyNetworkInfo) {
        self.networkInfo = telephonyNetworkInfo
    }
    
    
    func requestCarrierInfo() {
        var carrierList = Array<CTCarrier>([])
        if let carrier = networkInfo?.serviceSubscriberCellularProviders {
            carrier.forEach { (arg0) in
                let (_, value) = arg0
                carrierList.append(value)
            }
            
            if let firstCarrier = carrier.first {
                selectedCarrier.onNext(CarrierModel(selectedCarrierModel: firstCarrier.value, isDualCarrier: carrier.count > 1))
                selectedCarrierIndex = 0
            }
            carriers = carrierList
        }
        
    }
    
    
    func switchCarrier() {
        if !carriers.isEmpty && carriers.count > 1 {
            if selectedCarrierIndex == 0 {
                selectedCarrier.onNext(CarrierModel(selectedCarrierModel: carriers[1], isDualCarrier: carriers.count > 1))
                selectedCarrierIndex = 1
            }else{
                selectedCarrier.onNext(CarrierModel(selectedCarrierModel: carriers[0], isDualCarrier: carriers.count > 1))
                selectedCarrierIndex = 0
            }
            
        }
    }
    
}
