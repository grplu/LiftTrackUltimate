import SwiftUI

struct ProfileHeader: View {
    @Binding var showingEditSheet: Bool
    @Binding var showingSettingsSheet: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Profile")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title)
                        .foregroundColor(.blue)
                }
                
                Button(action: { showingSettingsSheet = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
    }
} 