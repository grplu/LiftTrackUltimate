import SwiftUI
import UIKit  // For UIApplication access
// Import models
import Foundation

// Custom extension to help with color opacity ambiguity
extension Color {
    static func blueWithOpacity(_ opacity: Double) -> Color {
        return Color(red: 0, green: 0.478, blue: 1, opacity: opacity)
    }
    
    // Alternative way to create transparent colors
    static var blueOpacity20: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.2)
    }
    
    static var blueOpacity30: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.3)
    }
    
    static var blueOpacity50: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.5)
    }
    
    static var blueOpacity40: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.4)
    }
    
    static var blueOpacity80: Color {
        return Color(red: 0, green: 0.478, blue: 1).opacity(0.8)
    }
    
    static var systemBlue: Color {
        return Color(red: 0, green: 0.478, blue: 1)
    }
}

struct NewExerciseView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var dataManager: DataManager
    
    // Form data
    @State private var name: String = ""
    @State private var selectedCategory: ExerciseCategory = .strength
    @State private var equipment: String = ""
    @State private var instructions: String = ""
    @State private var selectedMuscleGroups: Set<MuscleGroup> = []
    @State private var selectedMuscleSubregions: Set<String> = []
    
    // UI State
    @State private var expandedMuscleGroup: MuscleGroup? = nil
    @FocusState private var focusedField: Field?
    
    // Validation
    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !selectedMuscleSubregions.isEmpty
    }
    
    // Focus fields enum
    private enum Field {
        case name, equipment, instructions
    }
    
    // Available categories
    private let categories = ["Strength", "Cardio", "Flexibility", "Balance"]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Simple black background
                Color.black.edgesIgnoringSafeArea(.all)
                
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        nameField
                            .padding(.top, 8)
                        
                        categorySelection
                        
                        muscleGroupsSelection
                        
                        equipmentField
                        
                        instructionsField
                        
                        // Spacer to push content up from bottom button
                        Spacer().frame(height: 80)
                    }
                    .padding(.horizontal, 20)
                }
                .onTapGesture {
                    dismissKeyboard()
                }
                
                // Overlay the save button at the bottom
                VStack {
                    Spacer()
                    saveButton
                }
            }
            .navigationBarTitle("New Exercise", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.blue)
            )
            // Fix for keyboard toolbar constraint issues
            .toolbar {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button("Done") {
                            dismissKeyboard()
                        }
                    }
                }
            }
            // Show subregion selection when activated
            .overlay(
                Group {
                    if let expandedGroup = expandedMuscleGroup {
                        ZStack {
                            Color.black.opacity(0.8)
                                .edgesIgnoringSafeArea(.all)
                                .onTapGesture {
                                    withAnimation {
                                        expandedMuscleGroup = nil
                                    }
                                }
                            
                            muscleSubregionSheet(for: expandedGroup)
                                .transition(.opacity)
                        }
                        .transition(.opacity)
                    }
                }
            )
        }
    }
    
    // Improved main components with better styling
    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("", text: $name)
                .focused($focusedField, equals: .name)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(12)
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if name.isEmpty {
                            HStack {
                                Text("Enter exercise name")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
                    }
                )
        }
    }
    
    private var equipmentField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Equipment")
                .font(.headline)
                .foregroundColor(.white)
            
            TextField("", text: $equipment)
                .focused($focusedField, equals: .equipment)
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(12)
                .background(Color(.systemGray6).opacity(0.3))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .overlay(
                    Group {
                        if equipment.isEmpty {
                            HStack {
                                Text("Enter required equipment (optional)")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
                    }
                )
        }
    }
    
    private var categorySelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Category")
                .font(.headline)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ExerciseCategory.allCases, id: \.self) { category in
                        Button(action: {
                            selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(selectedCategory == category ? .white : .gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedCategory == category ? Color.blue : Color(.systemGray6).opacity(0.3))
                                )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.vertical, 4)
            }
        }
    }
    
    private var muscleGroupsSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Muscle Groups")
                .font(.headline)
                .foregroundColor(.white)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(MuscleGroup.allCases.filter { $0 != .none }, id: \.self) { group in
                    Button(action: {
                        handleMuscleGroupTap(group)
                    }) {
                        muscleGroupCard(group)
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
            }
            
            // Show selected subregions
            if !selectedMuscleSubregions.isEmpty {
                Text("Selected Muscles")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(Array(selectedMuscleSubregions).sorted(), id: \.self) { subregion in
                        HStack {
                            Text(subregion)
                                .font(.system(size: 14))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            Button(action: {
                                toggleMuscleSubregion(subregion)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.15))
                        )
                    }
                }
            }
        }
    }
    
    private func muscleGroupCard(_ group: MuscleGroup) -> some View {
        VStack {
            Image(systemName: group.iconName)
                .font(.system(size: 24))
                .foregroundColor(selectedMuscleGroups.contains(group) ? .blue : .gray)
                .frame(width: 50, height: 50)
                .background(Color(.systemGray6).opacity(0.3))
                .clipShape(Circle())
            
            Text(group.displayName)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(selectedMuscleGroups.contains(group) ? Color.blue.opacity(0.15) : Color.clear)
        )
    }
    
    private var instructionsField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Instructions")
                .font(.headline)
                .foregroundColor(.white)
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $instructions)
                    .frame(minHeight: 120, maxHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .scrollContentBackground(.hidden)
                
                if instructions.isEmpty {
                    Text("Enter exercise instructions...")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .allowsHitTesting(false)
                }
            }
            .frame(height: 120)
        }
    }
    
    private var saveButton: some View {
        Button(action: {
            dismissKeyboard()
            saveExercise()
        }) {
            Text("Save Exercise")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                )
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(name.isEmpty)
        .opacity(name.isEmpty ? 0.6 : 1.0)
    }
    
    // Improved subregion sheet
    private func muscleSubregionSheet(for muscleGroup: MuscleGroup) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(muscleGroup.displayName)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        expandedMuscleGroup = nil
                    }
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 8)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(muscleGroup.subregions, id: \.self) { subregion in
                        let isSelected = selectedMuscleSubregions.contains(subregion)
                        Button(action: {
                            toggleMuscleSubregion(subregion)
                        }) {
                            HStack {
                                Text(subregion)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white)
                                    .lineLimit(1)
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6).opacity(0.3))
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
            
            Button(action: {
                withAnimation {
                    expandedMuscleGroup = nil
                }
            }) {
                Text("Done")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.blue)
                    )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black)
                .shadow(radius: 10)
        )
        .frame(width: UIScreen.main.bounds.width * 0.85)
    }
    
    // MARK: - Helper Functions
    
    private func dismissKeyboard() {
        focusedField = nil
    }
    
    private func saveExercise() {
        let newExercise = Exercise(
            id: UUID(),
            name: name,
            category: selectedCategory.rawValue,
            muscleGroups: Array(selectedMuscleGroups).map { $0.name },
            instructions: instructions.isEmpty ? nil : instructions,
            isFavorite: false,
            equipment: equipment.isEmpty ? nil : equipment
        )
        
        dataManager.saveExercise(newExercise)
        dismiss()
    }
    
    private func toggleMuscleSubregion(_ subregion: String) {
        // Find which muscle group this subregion belongs to
        var groupForSubregion: MuscleGroup? = nil
        for group in MuscleGroup.allCases {
            if group.subregions.contains(subregion) {
                groupForSubregion = group
                break
            }
        }
        
        guard let group = groupForSubregion ?? expandedMuscleGroup else { return }
        
        if selectedMuscleSubregions.contains(subregion) {
            selectedMuscleSubregions.remove(subregion)
            
            // Check if this was the last subregion for this muscle group
            let anySubregionsRemain = group.subregions.contains { selectedMuscleSubregions.contains($0) }
            if !anySubregionsRemain {
                selectedMuscleGroups.remove(group)
            }
        } else {
            selectedMuscleSubregions.insert(subregion)
            // Make sure the parent muscle group is selected
            selectedMuscleGroups.insert(group)
        }
    }
    
    private func handleMuscleGroupTap(_ group: MuscleGroup) {
        if selectedMuscleGroups.contains(group) {
            selectedMuscleGroups.remove(group)
        } else {
            selectedMuscleGroups.insert(group)
        }
        withAnimation {
            expandedMuscleGroup = group
        }
    }
}

// MARK: - Preview
struct NewExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        NewExerciseView()
            .environmentObject(DataManager.shared)
            .preferredColorScheme(.dark)
    }
}

// MARK: - Support Views

struct MuscleGroupIconButton: View {
    let muscleGroup: MuscleGroup
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack {
                    // Background circle
                    Circle()
                        .fill(isSelected ? Color.blue : Color(.systemGray6).opacity(0.15))
                        .frame(width: 64, height: 64)
                        .shadow(color: isSelected ? Color.blue.opacity(0.4) : Color.clear, radius: 4, x: 0, y: 2)
                    
                    // Icon
                    Image(systemName: muscleGroup.iconName)
                        .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                        .foregroundColor(isSelected ? .white : .gray)
                    
                    // Selection ring
                    if isSelected {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                            .frame(width: 64, height: 64)
                    }
                }
                
                // Label
                Text(muscleGroup.name)
                    .font(.system(size: 13, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? .white : .gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(height: 90)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct MuscleSubregionButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .medium : .regular))
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .white : .gray)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.blue : Color.clear)
                        .frame(width: 22, height: 22)
                    
                    Image(systemName: isSelected ? "checkmark" : "circle")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isSelected ? .white : .gray)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.2) : Color(.systemGray5).opacity(0.3))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Model Data

// MuscleGroup enum is now defined in Models/MuscleGroup.swift
// Using the shared MuscleGroup definition from Models/MuscleGroup.swift

// Button style with scale animation
