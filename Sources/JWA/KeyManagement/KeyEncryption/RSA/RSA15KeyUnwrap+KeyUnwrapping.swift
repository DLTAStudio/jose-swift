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

import CryptoSwift
import Foundation
import JWK
import Security

struct RSA15KeyUnwrap: KeyUnwrapping {
    func contentKeyDecrypt(
        encryptedKey: Data,
        using: JWK,
        arguments: [KeyEncryptionArguments]
    ) throws -> Data {
        guard let n = using.n else {
            throw JWK.Error.missingNComponent
        }
        guard let e = using.e else {
            throw JWK.Error.missingEComponent
        }
        guard let d = using.d else {
            throw JWK.Error.missingDComponent
        }
        guard
            let p = using.p,
            let q = using.q
        else {
            throw JWK.Error.missingPrimesComponent
        }
        
        let rsaPrivateKey = try CryptoSwift.RSA(
            n: BigUInteger(n),
            e: BigUInteger(e),
            d: BigUInteger(d),
            p: BigUInteger(p),
            q: BigUInteger(q)
        )
        let derEncodedRSAPrivateKey = try rsaPrivateKey.externalRepresentation()
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits as String: n.count * 8,
            kSecAttrIsPermanent as String: false,
        ]
        var error: Unmanaged<CFError>?
        guard let rsaSecKey = SecKeyCreateWithData(
            derEncodedRSAPrivateKey as CFData,
            attributes as CFDictionary,
            &error
        ) else {
            throw CryptoError.securityLayerError(internalStatus: nil, internalError: error?.takeRetainedValue())
        }
        let secKeyAlgorithm = SecKeyAlgorithm.rsaEncryptionPKCS1
        var decryptionError: Unmanaged<CFError>?
        guard
            let plaintext = SecKeyCreateDecryptedData(
                rsaSecKey,
                secKeyAlgorithm,
                encryptedKey as CFData,
                &decryptionError
            )
        else {
            throw CryptoError.securityLayerError(internalStatus: nil, internalError: decryptionError?.takeRetainedValue())
        }
        return plaintext as Data
    }
}
