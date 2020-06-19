//
//  ScannerErrorExtension.swift
//  wiperator
//
//  Created by Andrew Pirkl on 6/11/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import Foundation

extension CodeScannerView.ScanError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .badInput:
            return "Scanner input could not be read"
        case .badOutput:
            return "There was an error with the scanner output"
        case .cancelled:
            return "Scanner cancelled"
        }
    }
}
