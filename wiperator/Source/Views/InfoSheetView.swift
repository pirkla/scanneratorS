//
//  ErrorView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI

struct InfoSheetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let description: String
    let image: Image?
    
    var body: some View {
      HStack {
        VStack {
            HStack{
            Text(title)
            image
            }
            Text(description)
                .padding(.all, 40.0)
                .multilineTextAlignment(.center)
            Button(action: {
               self.presentationMode.wrappedValue.dismiss()
            }) {
              Text("Dismiss")
            }
        }
      }
    }
}

struct ErrorView_Previews: PreviewProvider {
    static var previews: some View {
        InfoSheetView(title: "Preview", description: "Description Preview", image: nil)
    }
}
