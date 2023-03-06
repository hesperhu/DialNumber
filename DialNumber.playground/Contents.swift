//https://github.com/kodecocodes/comb-materials/blob/editions/3.0/03-transforming-operators/projects/Final.playground/Contents.swift
//https://github.com/kodecocodes/comb-materials/blob/editions/3.0/03-transforming-operators/projects/challenge/Final.playground/Contents.swift

import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()

//将数据的处理分成几段，每段当做一个operator，最后再sink处理 2023-03-06(Mon) 10:13:28
//根据final结果做了优化 2023-03-06(Mon) 10:24:33
example(of: "Create a phone number lookup") {
  let contacts = [
    "603-555-1234": "Florent",
    "408-555-4321": "Marin",
    "217-555-1212": "Scott",
    "212-555-3434": "Shai"
  ]
  
  func convert(phoneNumber: String) -> Int? {
    if let number = Int(phoneNumber),
      number < 10 {
      return number
    }

    let keyMap: [String: Int] = [
      "abc": 2, "def": 3, "ghi": 4,
      "jkl": 5, "mno": 6, "pqrs": 7,
      "tuv": 8, "wxyz": 9
    ]

    let converted = keyMap
      .filter { $0.key.contains(phoneNumber.lowercased()) }
      .map { $0.value }
      .first
    return converted
  }

  func format(digits: [Int]) -> String {
    var phone = digits.map(String.init)
                      .joined()

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 3)
    )

    phone.insert("-", at: phone.index(
      phone.startIndex,
      offsetBy: 7)
    )

    return phone
  }

  func dial(phoneNumber: String) -> String {
    guard let contact = contacts[phoneNumber] else {
      return "Contact not found for \(phoneNumber)"
    }

    return "Dialing \(contact) (\(phoneNumber))..."
  }
  
  let input = PassthroughSubject<String, Never>()
  
    input
        .map({ dial in
            convert(phoneNumber: dial)
        })
        .replaceNil(with: 0)
        .collect(10)
        .map { digits in
            format(digits: digits)
        }
        .sink { numberStr in
            print("first dial",dial(phoneNumber: numberStr))
        }
        .store(in: &subscriptions)
   
    input
        .map(convert)
        .replaceNil(with: 0)
        .collect(10)
        .map(format)
        .map(dial)
        .sink{print("second dial:",$0)}
        .store(in: &subscriptions)

  "0!1234567".forEach {
    input.send(String($0))
  }
  
  "4085554321".forEach {
    input.send(String($0))
  }
  
  "A1BJKLDGEH".forEach {
    input.send("\($0)")
  }
    
    input.send(completion: .finished)
}
/*
 
 ——— Example of: Create a phone number lookup ———
 first dial Contact not found for 000-123-4567
 second dial: Contact not found for 000-123-4567
 first dial Dialing Marin (408-555-4321)...
 second dial: Dialing Marin (408-555-4321)...
 first dial Dialing Shai (212-555-3434)...
 second dial: Dialing Shai (212-555-3434)...

 */

/// Copyright (c) 2021 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
