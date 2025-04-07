import SwiftUI

struct IconSelectionView: View {
    @Binding var selectedIcon: String
    @Binding var selectedColor: String
    @Environment(\.dismiss) private var dismiss
    
    // Grid layout for colors and icons
    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 90), spacing: 15)
    ]
    
    // Available colors for icons
    let iconColors = [
        (name: "blue", color: Color.blue),
        (name: "red", color: Color.red),
        (name: "green", color: Color.green),
        (name: "orange", color: Color.orange),
        (name: "purple", color: Color.purple),
        (name: "pink", color: Color.pink),
        (name: "yellow", color: Color.yellow),
        (name: "teal", color: Color.teal)
    ]
    
    // Icon options array
    let iconOptions = [
        (name: "Dumbbell", icon: "dumbbell.fill"),
        (name: "Running", icon: "figure.run"),
        (name: "Heart", icon: "heart.fill"),
        (name: "Flame", icon: "flame.fill"),
        (name: "Person", icon: "figure.strengthtraining.traditional"),
        (name: "Arms", icon: "figure.arms.open"),
        (name: "Cycling", icon: "figure.indoor.cycle"),
        (name: "Yoga", icon: "figure.mind.and.body"),
        (name: "Chest", icon: "heart.fill"),
        (name: "Back", icon: "figure.strengthtraining.traditional"),
        (name: "Shoulders", icon: "person.bust"),
        (name: "Core", icon: "figure.core.training"),
        (name: "Legs", icon: "figure.walk"),
        (name: "Cardio", icon: "figure.mixed.cardio"),
        (name: "Timer", icon: "timer"),
        (name: "Calendar", icon: "calendar"),
        (name: "Weight", icon: "scalemass.fill"),
        (name: "Fitness", icon: "figure.highintensity.intervaltraining"),
        (name: "Boxing", icon: "figure.boxing"),
        (name: "Dance", icon: "figure.dance"),
        (name: "Hiking", icon: "figure.hiking"),
        (name: "Water", icon: "drop.fill"),
        (name: "Nutrition", icon: "fork.knife"),
        (name: "Sleep", icon: "bed.double.fill")
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Color selection
                VStack(spacing: 16) {
                    Text("Choose a Color")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Use LazyHGrid for the colors
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: [GridItem(.fixed(60))], spacing: 15) {
                            ForEach(iconColors, id: \.name) { colorOption in
                                Button(action: {
                                    selectedColor = colorOption.name
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(colorOption.color)
                                            .frame(width: 50, height: 50)
                                        
                                        if selectedColor == colorOption.name {
                                            Circle()
                                                .stroke(Color.white, lineWidth: 3)
                                                .frame(width: 50, height: 50)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Icon selection
                VStack(spacing: 16) {
                    Text("Choose an Icon")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    // Use ScrollView for the icons
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(iconOptions, id: \.icon) { option in
                                Button(action: {
                                    selectedIcon = option.icon
                                }) {
                                    VStack(spacing: 8) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedIcon == option.icon ? Color.getColor(named: selectedColor) : Color(.systemGray6).opacity(0.2))
                                                .frame(width: 60, height: 60)
                                            
                                            Image(systemName: option.icon)
                                                .font(.system(size: 24))
                                                .foregroundColor(selectedIcon == option.icon ? .white : .gray)
                                        }
                                        
                                        Text(option.name)
                                            .font(.caption)
                                            .foregroundColor(selectedIcon == option.icon ? .white : .gray)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.8)
                                    }
                                    .frame(width: 80)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitle("Choose Icon & Color", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 