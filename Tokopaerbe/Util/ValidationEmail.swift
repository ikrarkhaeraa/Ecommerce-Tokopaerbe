//
//  ValidationEmail.swift
//  Tokopaerbe
//
//  Created by Ikrar Khaera Arfat on 01/06/24.
//

import Foundation

func isValidEmail(email: String) -> Bool {
    // Regular expression pattern for validating email addresses
    let emailRegex = #"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$"#
    
    // Create NSPredicate with emailRegex
    let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
    
    // Check if the email matches the regular expression
    return emailPredicate.evaluate(with: email)
}
