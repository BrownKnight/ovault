import SwiftUI
import SwiftData
import Models

struct ContentView: View {
    @State private var isOtpScanPresented: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.notifier) private var notifier
    
    @Query private var items: [OtpMetadata]

    var body: some View {
        NavigationStack {
            if items.count == 0 {
                ContentUnavailableView(
                    label: {
                        Label("No OTPs Registered", systemImage: "list.bullet")
                    },
                    description: {
                        Text("Add OTPs by scanning their QR codes, or adding it manually")
                    },
                    actions: {
                        NavigationLink {
                            AddOtpEntryView()
                        } label: {
                            Label("Add Manually", systemImage: "plus")
                        }
                        
                        Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                            isOtpScanPresented = true
                        }
                    })
            }
            
            List {
                ForEach(items) { item in
                    OtpEntryView(otp: item)
                    #if os(macOS)
                    .padding()
                    #else
                    .padding(.top, 2)
                    .padding(.bottom, 6)
                    #endif
                }
            }
            .toolbar {
                ToolbarItem {
                    Menu {
                        NavigationLink {
                            AddOtpEntryView()
                        } label: {
                            Label("Manual", systemImage: "plus")
                        }
                        
                        Button("Scan QR Code", systemImage: "qrcode.viewfinder") {
                            isOtpScanPresented = true
                        }
                    } label: {
                        Label("New OTP", systemImage: "plus")
                    }
                }
            }
            .navigationTitle("OVault")
            .onOpenURL { url in
                notifier.execute {
                    let entry = try OtpMetadata.from(url: url)
                    modelContext.insert(entry)
                    try modelContext.save()
                }
            }
            .sheet(isPresented: $isOtpScanPresented) {
                OtpQrScannerView()
                    .withNotifierSupport()
            }
        }
    }
}

#if DEBUG
#Preview("With items") {
    ContentView()
        .previewEnvironment()
}

#Preview("Empty") {
    ContentView()
        .previewEnvironment(withData: false)
}
#endif
