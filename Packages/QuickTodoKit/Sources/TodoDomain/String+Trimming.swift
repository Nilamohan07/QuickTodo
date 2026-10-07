//
//  String+Trimming.swift
//  TodoDomain
//
//  Created by Udhayanila on 05/10/26.
//

import Foundation

extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
