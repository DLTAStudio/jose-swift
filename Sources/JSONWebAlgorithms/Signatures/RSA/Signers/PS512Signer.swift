/*
 * Copyright 2024 Gonçalo Frade
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

@preconcurrency import CryptoSwift
import Foundation
import JSONWebKey
import Crypto
import _CryptoExtras
/// `PS512Signer` provides methods to sign data using the PS512 algorithm.
public struct PS512Signer: Signer {
    
    /// The algorithm used for signing.
    public var algorithm: String { SigningAlgorithm.PS512.rawValue }
    
    /// Signs the given data using the provided private key.
    /// - Parameters:
    ///   - data: The data to be signed.
    ///   - key: The `JWK` containing the private key to use for signing.
    /// - Throws: An error if the private key is not valid or if the signing process fails.
    /// - Returns: The signature as a `Data` object.
    public func sign(data: Data, key: JWK) throws -> Data {
        guard let n = key.n, let e = key.e else { throw CryptoError.notValidPrivateKey }
        let privateKey: RSA
        if let p = key.p, let q = key.q, let d = key.d {
            privateKey = try RSA(n: BigUInteger(n), e: BigUInteger(e), d: BigUInteger(d), p: BigUInteger(p), q: BigUInteger(q))
        } else {
            privateKey = RSA(n: BigUInteger(n), e: BigUInteger(e), d: key.d.map { BigUInteger($0) })
        }
        
        let derEncodedRSAPrivateKey = try privateKey.externalRepresentation()
        guard let signingKey = try? _RSA.Signing.PrivateKey(derRepresentation: derEncodedRSAPrivateKey),
                let signature = try? signingKey.signature(for:SHA512.hash(data: data), padding: .PSS) else {
            throw CryptoError.securityLayerError(internalStatus: nil, internalError: nil)
        }
        return signature.rawRepresentation

    }
}
