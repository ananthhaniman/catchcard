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

struct CarrierProviderViewModel{
    
    private var networkInfo:CTTelephonyNetworkInfo?
    
    public let carriers:PublishSubject<[CTCarrier]> = PublishSubject()
    public let selectedCarrier:PublishSubject<CTCarrier> = PublishSubject()
    
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
        }
        
        carriers.onNext(carrierList)
    }
    
}
