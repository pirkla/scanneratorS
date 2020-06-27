//
//  DeleteDeviceView.swift
//  wiperator
//
//  Created by Andrew Pirkl on 5/27/20.
//  Copyright © 2020 Pirklator. All rights reserved.
//

import SwiftUI
/**
 Sheet view to display information and escape a bool based on user input
 */
struct OptionSheet: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    let title: String
    let description: String

    var completion: (Bool) -> Void
    
    init(title: String, description: String, completion: @escaping (Bool)->Void) {
        self.title = title
        self.description = description
        self.completion = completion
    }

    var body: some View {
      Group {
        Text(title)
        Text(description)
        
        //stack for true and false buttons
        VStack {
            // return true button
            Button(action: {
                self.completion(true)
               self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "checkmark")
                        .padding([.top, .leading, .bottom], 10.0)
                    Text("Yes")
                        .padding([.top, .bottom, .trailing], 10.0)
                }
                .background(Color.init("TextBackground"))
            }
            .cornerRadius(10)
            // return false button
            Button(action: {
                self.completion(false)
               self.presentationMode.wrappedValue.dismiss()
            }) {
                HStack {
                    Image(systemName: "xmark")
                        .padding([.top, .leading, .bottom], 10.0)
                    Text("No")
                        .padding([.top, .bottom, .trailing], 10.0)
                }
                .background(Color.init("TextBackground"))
              
            }
            .cornerRadius(10)
        }
      }
    }
}

struct WipeDeviceView_Previews: PreviewProvider {
    static var previews: some View {
        OptionSheet(title: "Preview", description: "Description Preview"){_ in 
            
        }
    }
}
