//
//  VerifyMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 11/5/24.
//

import SwiftUI

struct VerifyMentorView: View {
    @State private var isRegisterDomainView: Bool = false
    @Binding var navPath: NavigationPath
    
    var body: some View {
        Group {
            if !isRegisterDomainView {
                CertificateEmailView(isNotVailedDomain: { isRegisterDomainView = true}, isDone: { isDone() } )
            } else {
                RegisterDomainView(isDone: { isDone() })
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.cheekBackgroundTeritory)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    func isDone() {
        navPath.append("SetProfileView")
    }
}

#Preview {
    VerifyMentorView(navPath: .constant(NavigationPath()))
}
