//
//  VerifyCodesModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/11/24.
//

import Foundation

struct VerifyCodesModel: Codable {
    let email: String
    let verificationCode: String
}
