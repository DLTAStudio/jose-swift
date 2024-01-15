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

import Foundation

public struct EncodingError: Error {}

public extension Data {
    func tryToString() throws -> String {
        guard let str = String(data: self, encoding: .utf8) else {
            throw EncodingError()
        }
        return str
    }
}

public extension String {
    func tryToData() throws -> Data {
        guard let data = self.data(using: .utf8) else {
            throw EncodingError()
        }
        return data
    }
}
