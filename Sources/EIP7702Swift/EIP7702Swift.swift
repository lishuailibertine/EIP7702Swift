// The Swift Programming Language
// https://docs.swift.org/swift-book
import BigInt
import web3swift
import Secp256k1Swift
import Foundation
import RLP
public let EOA_CODE_7702_AUTHORITY_SIGNING_MAGIC = Data([0x05])
public let EOACodeEIP7702Type = Data([0x04])
public struct EOACode7702AuthorizationListItemUnsigned{
    var chainId: BigUInt
    var logicAddress: Address
    var nonce: BigUInt
    public init(chainId: BigUInt, logicAddress: Address, nonce: BigUInt) {
        self.chainId = chainId
        self.logicAddress = logicAddress
        self.nonce = nonce
    }
    func rawData() -> [Any?] {
        return [
            self.chainId, self.logicAddress, self.nonce
        ]
    }
}

public struct EOACode7702AuthorizationListBytesItem{
    var chainId: BigUInt
    var logicAddress: Address
    var nonce: BigUInt
    var y_parity: Data
    var r: Data
    var s: Data
    func rawData() -> [Any?] {
        return [
            self.chainId, self.logicAddress, self.nonce, self.y_parity, self.r, self.s
        ]
    }
}

public struct EoaCode7702SignAuthorization{
    public static func signAuth(privateKey: Data, input: EOACode7702AuthorizationListItemUnsigned) throws -> EOACode7702AuthorizationListBytesItem {
        let encodeData =  EOA_CODE_7702_AUTHORITY_SIGNING_MAGIC + (RLP.encode(input.rawData()) ?? Data())
        let hashed = encodeData.sha3(.keccak256)
        let (serializedSignature, _) = SECP256K1.signForRecovery(hash: hashed, privateKey: privateKey, useExtraVer: false)
        guard let _serializedSignature = serializedSignature else {
            throw Eoa7702TxError.invalidAuthSignature
        }
        let unmarshalSignature = SECP256K1.unmarshalSignature(signatureData: _serializedSignature)
        guard let _unmarshalSignature = unmarshalSignature else {
            throw Eoa7702TxError.invalidAuthSignature
        }
        return EOACode7702AuthorizationListBytesItem(chainId: input.chainId, logicAddress: input.logicAddress, nonce: input.nonce, y_parity: Data([_unmarshalSignature.v]), r: _unmarshalSignature.r, s: _unmarshalSignature.s)
    }
}
public struct AccessListBytesItem {
    let address: Data
    let storageKeys: [Data]
    public init(address: Data, storageKeys: [Data]) {
        self.address = address
        self.storageKeys = storageKeys
    }
    
    func rawData() -> [Any?] {
        return [
            self.address, self.storageKeys
        ]
    }
}
public enum Eoa7702TxError: LocalizedError {
    case invalidSignature
    case invalidAuthSignature
    public var errorDescription: String? {
        switch self {
        case .invalidSignature:
            return "Invalid Signature"
        case .invalidAuthSignature:
            return "invalid AuthSignature"
        }
    }
}
public struct Eoa7702TxData{
    var nonce: BigUInt
    var gasLimit: BigUInt
    var value: BigUInt
    var data: Data
    var to: Address
    var accessList: [AccessListBytesItem]
    var authorizationList: [EOACode7702AuthorizationListBytesItem]
    var chainId: BigUInt
    var maxPriorityFeePerGas: BigUInt
    var maxFeePerGas: BigUInt
    
    var signatureYParity: Data?
    var signatureR: Data?
    var signatureS: Data?
   
    public init(nonce: BigUInt, gasLimit: BigUInt, value: BigUInt, data: Data, to: Address, accessList: [AccessListBytesItem], authorizationList: [EOACode7702AuthorizationListBytesItem], chainId: BigUInt, maxPriorityFeePerGas: BigUInt, maxFeePerGas: BigUInt) {
        self.nonce = nonce
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
        self.to = to
        self.accessList = accessList
        self.authorizationList = authorizationList
        self.chainId = chainId
        self.maxPriorityFeePerGas = maxPriorityFeePerGas
        self.maxFeePerGas = maxFeePerGas
    }
    
    public mutating func sign(privateKey: Data) throws {
        let encodeData =  EOACodeEIP7702Type + (RLP.encode(self.rawData()) ?? Data())
        let hashed = encodeData.sha3(.keccak256)
        let (serializedSignature, _) = SECP256K1.signForRecovery(hash: hashed, privateKey: privateKey, useExtraVer: false)
        guard let _serializedSignature = serializedSignature else {
            throw Eoa7702TxError.invalidSignature
        }
        let unmarshalSignature = SECP256K1.unmarshalSignature(signatureData: _serializedSignature)
        guard let v = unmarshalSignature?.v, let r = unmarshalSignature?.r, let s = unmarshalSignature?.s else {
            throw Eoa7702TxError.invalidSignature
        }
        self.signatureYParity = Data([v])
        self.signatureR = r
        self.signatureS = s
    }
    
    public func rawData() -> [Any?] {
        return [
            self.chainId,
            self.nonce,
            self.maxPriorityFeePerGas,
            self.maxFeePerGas,
            self.gasLimit,
            self.to,
            self.value,
            self.data,
            self.accessList.compactMap({$0.rawData()}),
            self.authorizationList.compactMap({$0.rawData()})
        ]
    }
    
    public func signRawData() -> [Any?] {
        var rawArray = self.rawData()
        rawArray.append(self.signatureYParity)
        rawArray.append(self.signatureR)
        rawArray.append(self.signatureS)
        return rawArray
    }
    
    public func serialize() -> String? {
        let encodeData = EOACodeEIP7702Type + (RLP.encode(self.signRawData()) ?? Data())
        return encodeData.toHexString()
    }
}
