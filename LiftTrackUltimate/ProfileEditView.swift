import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @Binding var profile: UserProfile
    var onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    // State for optional values
    @State private var heightString: String = ""
    @State private var weightString: String = ""
    @State private var birthDate: Date = Date()
    @State private var showingBirthDatePicker: Bool = false
    @State private var showingGoalPicker: Bool = false
    
    // Image picker state
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var profileImage: UIImage?
    
    // Available fitness goals
    let fitnessGoals = [
        "Strength Training",
        "Muscle Building",
        "Weight Loss",
        "Endurance",
        "Athletic Performance",
        "General Fitness"
    ]
    
    init(profile: Binding<UserProfile>, onSave: @escaping () -> Void) {
        self._profile = profile
        self.onSave = onSave
        
        // Initialize height string if available
        if let height = profile.wrappedValue.height {
            self._heightString = State(initialValue: String(format: "%.1f", height))
        }
        
        // Initialize weight string if available
        if let weight = profile.wrappedValue.weight {
            self._weightString = State(initialValue: String(format: "%.1f", weight))
        }
        
        // Initialize birth date if available, otherwise use a default date
        if let date = profile.wrappedValue.birthDate {
            self._birthDate = State(initialValue: date)
        } else {
            // Default to 30 years ago
            let calendar = Calendar.current
            if let date = calendar.date(byAdding: .year, value: -30, to: Date()) {
                self._birthDate = State(initialValue: date)
            }
        }
        
        // Load existing profile image if available
        if let profilePicture = profile.wrappedValue.profilePicture,
           let uiImage = UIImage(data: profilePicture) {
            self._profileImage = State(initialValue: uiImage)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Picture Section
                    profileImageSection
                    
                    // Personal Information
                    sectionCard(title: "Personal Information") {
                        VStack(spacing: 16) {
                            // Name field
                            inputField(title: "Name",
                                    icon: "person.fill",
                                    placeholder: "Enter your name",
                                    text: $profile.name)
                            
                            // Fitness Goal picker
                            Button(action: {
                                withAnimation {
                                    showingGoalPicker = true
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Fitness Goal")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Text(profile.fitnessGoal)
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Physical Information
                    sectionCard(title: "Physical Information") {
                        VStack(spacing: 16) {
                            // Height field
                            inputField(title: "Height (cm)",
                                    icon: "ruler",
                                    placeholder: "Enter your height",
                                    text: $heightString,
                                    keyboardType: .decimalPad)
                            
                            // Weight field
                            inputField(title: "Weight (kg)",
                                    icon: "scalemass",
                                    placeholder: "Enter your weight",
                                    text: $weightString,
                                    keyboardType: .decimalPad)
                            
                            // Birth Date field
                            Button(action: {
                                withAnimation {
                                    showingBirthDatePicker = true
                                }
                            }) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Birth Date")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.gray)
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.gray)
                                            .frame(width: 24)
                                        
                                        Text(formatDate(birthDate))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .foregroundColor(.gray)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(Color.black)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                                }
                            }
                        }
                    }
                    
                    // Save button
                    Button(action: saveProfile) {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.body.weight(.semibold))
                            
                            Text("Save Profile")
                                .font(.body.weight(.semibold))
                        }
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 50)
            }
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(
            leading: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(.white),
            
            trailing: Button("Save") {
                saveProfile()
            }
            .fontWeight(.bold)
            .foregroundColor(.white)
        )
        .sheet(isPresented: $showingBirthDatePicker) {
            VStack {
                HStack {
                    Button("Cancel") {
                        showingBirthDatePicker = false
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Done") {
                        showingBirthDatePicker = false
                    }
                    .fontWeight(.bold)
                    .padding()
                }
                .background(Color.black)
                .foregroundColor(.white)
                
                DatePicker(
                    "",
                    selection: $birthDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .colorScheme(.light) // Force light mode for the date picker
                
                Spacer()
            }
            .background(Color.white)
        }
        .sheet(isPresented: $showingGoalPicker) {
            NavigationView {
                List {
                    ForEach(fitnessGoals, id: \.self) { goal in
                        Button {
                            profile.fitnessGoal = goal
                            showingGoalPicker = false
                        } label: {
                            HStack {
                                Text(goal)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if profile.fitnessGoal == goal {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Fitness Goal")
                .navigationBarItems(trailing: Button("Done") {
                    showingGoalPicker = false
                }
                .foregroundColor(.white))
                .background(Color.black)
            }
            .preferredColorScheme(.dark)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    if let uiImage = UIImage(data: data) {
                        profileImage = uiImage
                    }
                }
            }
        }
    }
    
    // MARK: - Section Card
    private func sectionCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            content()
        }
        .padding(.horizontal)
    }
    
    // MARK: - Input Field
    private func inputField(title: String, icon: String, placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                TextField(placeholder, text: text)
                    .foregroundColor(.white)
                    .keyboardType(keyboardType)
                    .accentColor(.white)
            }
            .padding()
            .background(Color.black)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Profile Image Section
    private var profileImageSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                if let profileImage = profileImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else if let profilePicture = profile.profilePicture, let uiImage = UIImage(data: profilePicture) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                }
                
                // Change photo button overlay
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.black)
                                .padding(8)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                        .offset(x: -4, y: -4)
                    }
                }
                .frame(width: 120, height: 120)
            }
            
            // Change photo text button
            PhotosPicker(selection: $selectedItem, matching: .images) {
                Text("Change Photo")
                    .font(.subheadline)
                    .foregroundColor(.white)
            }
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func saveProfile() {
        // Convert height string to Double if possible
        if let height = Double(heightString) {
            profile.height = height
        }
        
        // Convert weight string to Double if possible
        if let weight = Double(weightString) {
            profile.weight = weight
        }
        
        // Save birth date
        profile.birthDate = birthDate
        
        // Save profile image
        if let selectedImageData = selectedImageData {
            profile.profilePicture = selectedImageData
        }
        
        // Call the save callback
        onSave()
        
        // Dismiss the sheet
        presentationMode.wrappedValue.dismiss()
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(
            profile: .constant(UserProfile(name: "John Doe", fitnessGoal: "Strength Training")),
            onSave: {}
        )
        .preferredColorScheme(.dark)
    }
}
