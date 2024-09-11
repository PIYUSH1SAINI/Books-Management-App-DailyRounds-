//
//  EmailFieldView.swift
//  DailyRound
//
//  Created by Piyush saini on 11/09/24.
//

import SwiftUI

struct EmailInputView: View {
    @Binding var email: String
    @StateObject var viewModel = LoginViewModel()
    
    var body: some View {
        VStack {
            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .padding(.leading, 10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onChange(of: email) { newValue in
                    // Add your email validation logic here
                    isEmailValid = validateEmail(newValue)
                }
            
            if !isEmailValid {
                Text("Invalid email address")
                    .foregroundColor(.red)
                    .font(.caption)
            }
        }
    }
}

#Preview {
    EmailFieldView()
}
