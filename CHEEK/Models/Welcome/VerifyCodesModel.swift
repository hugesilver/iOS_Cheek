//
//  VerifyCodesModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/11/24.
//

import Foundation

struct VefiryCodesModel: Codable {
    var email: String
    var verificationCode: String
    
    init?(email: String?, verificationCode: String?) {
        guard let email = email,
              let verificationCode = verificationCode
        else {
            print("VefiryCodesModel init 실패")
            return nil
        }
        
        self.email = email
        self.verificationCode = verificationCode
    }
}
