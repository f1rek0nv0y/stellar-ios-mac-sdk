//
//  OperationFactory.swift
//  stellarsdk
//
//  Created by Razvan Chelemen on 06/02/2018.
//  Copyright © 2018 Soneso. All rights reserved.
//

import UIKit

class OperationsFactory: NSObject {
    let jsonDecoder = JSONDecoder()
    
    override init() {
        jsonDecoder.dateDecodingStrategy = .formatted(DateFormatter.iso8601)
    }
    
    func operationsFromResponseData(data: Data) throws -> AllOperationsResponse {
        var operationsList = [OperationResponse]()
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
            
            for record in json["_embedded"]!["records"] as! [[String:AnyObject]] {
                let jsonRecord = try JSONSerialization.data(withJSONObject: record, options: .prettyPrinted)
                let operation = try operationFromData(data: jsonRecord)
                operationsList.append(operation)
            }
            
        } catch {
            throw OperationsError.parsingFailed(response: error.localizedDescription)
        }
        
        return AllOperationsResponse(operations: operationsList)
    }
    
    func operationFromData(data: Data) throws -> OperationResponse {
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:AnyObject]
        if let type = OperationType(rawValue: json["type_i"] as! Int) {
            switch type {
            case .accountCreated:
                return try jsonDecoder.decode(AccountCreatedOperationResponse.self, from: data)
            case .payment:
                return try jsonDecoder.decode(PaymentOperationResponse.self, from: data)
            case .pathPayment:
                return try jsonDecoder.decode(PathPaymentOperationResponse.self, from: data)
            case .manageOffer:
                return try jsonDecoder.decode(ManageOfferOperationResponse.self, from: data)
            case .createPassiveOffer:
                return try jsonDecoder.decode(CreatePassiveOfferOperationResponse.self, from: data)
            case .setOptions:
                return try jsonDecoder.decode(SetOptionsOperationResponse.self, from: data)
            case .changeTrust:
                return try jsonDecoder.decode(ChangeTrustOperationResponse.self, from: data)
            case .allowTrust:
                return try jsonDecoder.decode(AllowTrustOperationResponse.self, from: data)
            case .accountMerge:
                return try jsonDecoder.decode(AccountMergeOperationResponse.self, from: data)
            case .inflation:
                return try jsonDecoder.decode(InflationOperationResponse.self, from: data)
            case .manageData:
                return try jsonDecoder.decode(ManageDataOperationResponse.self, from: data)
            }
        } else {
            throw OperationsError.parsingFailed(response: "Unknown operation type")
        }
    }
    
}