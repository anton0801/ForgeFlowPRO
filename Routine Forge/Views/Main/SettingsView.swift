import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("userName") private var userName = "there"
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("iCloudSyncEnabled") private var iCloudSync = false
    @State private var showingExportAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(hex: "1A1D23").ignoresSafeArea()
                
                Form {
                    Section(header: Text("Profile").foregroundColor(.gray)) {
                        HStack {
                            Text("Name")
                                .foregroundColor(.white)
                            TextField("Your name", text: $userName)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Appearance").foregroundColor(.gray)) {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .foregroundColor(.white)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "FF6B35")))
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("Data").foregroundColor(.gray)) {
                        Toggle("iCloud Sync", isOn: $iCloudSync)
                            .foregroundColor(.white)
                            .toggleStyle(SwitchToggleStyle(tint: Color(hex: "4A90E2")))
                        
                        Button(action: { showingExportAlert = true }) {
                            HStack {
                                Text("Export Data")
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "square.and.arrow.up")
                                    .foregroundColor(Color(hex: "4A90E2"))
                            }
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                    
                    Section(header: Text("About").foregroundColor(.gray)) {
                        HStack {
                            Text("Version")
                                .foregroundColor(.white)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: resetOnboarding) {
                            Text("Reset Onboarding")
                                .foregroundColor(.red)
                        }
                    }
                    .listRowBackground(Color.white.opacity(0.05))
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showingExportAlert) {
                Alert(
                    title: Text("Export Data"),
                    message: Text("Your data will be exported as PDF. This feature is coming soon!"),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
    
    func resetOnboarding() {
        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
        presentationMode.wrappedValue.dismiss()
    }
}
