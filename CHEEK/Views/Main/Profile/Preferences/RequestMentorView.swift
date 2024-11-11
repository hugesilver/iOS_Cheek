//
//  RequestMentorView.swift
//  CHEEK
//
//  Created by 김태은 on 11/5/24.
//

import SwiftUI

struct RequestMentorView: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var stateViewModel: StateViewModel
    
    @State private var isRegisterDomainView: Bool = false
    
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
        .navigationBarHidden(true).onAppear {
            stateViewModel.checkRefreshTokenValid()
        }
    }
    
    func isDone() {
        DispatchQueue.main.async {
            dismiss()
        }
    }
}

#Preview {
    RequestMentorView(stateViewModel: StateViewModel())
}
