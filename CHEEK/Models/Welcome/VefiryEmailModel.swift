//
//  VefiryEmailModel.swift
//  CHEEK
//
//  Created by 김태은 on 6/5/24.
//

import Foundation

struct VefiryEmailModel: Codable {
    var email: String
    
    init?(email: String?) {
        guard let email = email
        else {
            print("VefiryEmailModel init 실패")
            return nil
        }
        
        self.email = email
    }
}
