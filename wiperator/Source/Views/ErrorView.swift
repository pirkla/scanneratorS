//
//  ErrorView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct ErrorView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let description: String
//    let icon = Image("CFBundlePrimaryIcon")

    var body: some View {
      Group {
        Text("Modal view")
        Button(action: {
           self.presentationMode.wrappedValue.dismiss()
        }) {
          Text("Dismiss")
        }
      }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        ErrorView(title: "Preview", description: "Description Preview")
    }
}
