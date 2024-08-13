//
//  Utils.swift
//  PassMan
//
//  Created by Vladislav Skotarenko on 13.08.2024.
//

import Foundation
import SwiftUI

func generalAlert() -> Alert {
    Alert(
        title: Text("Something Went Wrong"),
        message: Text("Try restarting the application and try again."),
        dismissButton: .default(Text("OK")))
}
