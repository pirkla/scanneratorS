//import SwiftUI
//
//
//struct TestView: View {
//    @Binding var devices: [Device]
//
//    var body: some View {
//        NavigationView {
//            MasterView(devices: $devices)
//                .navigationBarTitle(Text("Master"))
//                .navigationBarItems(
//                    leading: EditButton(),
//                    trailing: Button(
//                        action: {
//                            withAnimation { self.devices.insert(Device(), at: 0) }
//                        }
//                    ) {
//                        Image(systemName: "plus")
//                    }
//                )
//            DetailView(devices: $devices).navigationBarTitle(Text("Detail"))
//        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
//    }
//}
//
//struct MasterView: View {
//    @Binding var devices: [Device]
//
//    var body: some View {
//        List {
//            ForEach(devices, id: \.self) { device in
//                NavigationLink(
//                    destination: DetailView(devices: self._devices, selectedDevice: device).navigationBarTitle(Text("Detail"))
//                ) {
//                    Text("\(device.id?.uuidString ?? "")")
//                }
//            }.onDelete { indices in
//                indices.forEach { self.devices.remove(at: $0) }
//            }
//        }
//    }
//}
//
//struct DetailView: View {
//    @Binding var devices: [Device]
//    var selectedDevice: Device?
//
//    var body: some View {
//            if let selectedDevice = selectedDevice, devices.contains(selectedDevice) {
//                return Text("\(selectedDevice.id?.uuidString ?? "")")
//            } else {
//                return Text("Detail view content goes here")
//            }
//    }
//}
//
////
////struct ContentView_Previews: PreviewProvider {
////    static var previews: some View {
////        ContentView()
////    }
////}
