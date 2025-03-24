import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var profile: UserProfile
    @State private var tempName: String
    @State private var tempFitnessGoal: String
    @State private var tempHeight: String
    @State private var tempWeight: String
    @State private var tempBirthDate: Date
    @State private var showingImagePicker = false
    @State private var inputImage: UIImage?
    @State private var showingGoalPicker = false
    @State private var showingDatePicker = false
    
    // Animation states
    @State private var animateFields = false
    @State private var animateButton = false
    
    var onSave: () -> Void
    
    // Available fitness goals
    private let fitnessGoals = [
        "Build Muscle", "Lose Weight", "Improve Strength",
        "Increase Endurance", "General Fitness", "Sport Performance"
    ]
    
    init(profile: Binding<UserProfile>, onSave: @escaping () -> Void) {
        self._profile = profile
        self.onSave = onSave
        
        // Initialize temporary state variables
        _tempName = State(initialValue: profile.wrappedValue.name)
        _tempFitnessGoal = State(initialValue: profile.wrappedValue.fitnessGoal)
        _tempHeight = State(initialValue: profile.wrappedValue.height != nil ? "\(profile.wrappedValue.height!)" : "")
        _tempWeight = State(initialValue: profile.wrappedValue.weight != nil ? "\(profile.wrappedValue.weight!)" : "")
        _tempBirthDate = State(initialValue: profile.wrappedValue.birthDate ?? Date())
    }
    
    var body: some View {
        ZStack {
            // Background with subtle gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color(red: 0.1, green: 0.1, blue: 0.15)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 28) {
                    // Profile photo
                    profilePhotoSection
                        .padding(.top, 20)
                    
                    // Personal Information section
                    sectionHeader("Personal Information")
                        .opacity(animateFields ? 1 : 0)
                        .offset(y: animateFields ? 0 : 20)
                    
                    // Name field
                    inputField(title: "Name", iconName: "person.fill", placeholder: "Enter your name") {
                        TextField("", text: $tempName)
                            .foregroundColor(.white)
                    }
                    .opacity(animateFields ? 1 : 0)
                    .offset(y: animateFields ? 0 : 15)
                    
                    // Fitness Goal picker
                    inputField(title: "Fitness Goal", iconName: "figure.strengthtraining.traditional", placeholder: tempFitnessGoal) {
                        HStack {
                            Text(tempFitnessGoal)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                showingGoalPicker = true
                            }
                        }
                    }
                    .opacity(animateFields ? 1 : 0)
                    .offset(y: animateFields ? 0 : 15)
                    
                    // Physical Information section
                    sectionHeader("Physical Information")
                        .padding(.top, 10)
                        .opacity(animateFields ? 1 : 0)
                        .offset(y: animateFields ? 0 : 15)
                    
                    // Height field
                    inputField(title: "Height (cm)", iconName: "ruler", placeholder: "Enter your height") {
                        TextField("", text: $tempHeight)
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                    }
                    .opacity(animateFields ? 1 : 0)
                    .offset(y: animateFields ? 0 : 15)
                    
                    // Weight field
                    inputField(title: "Weight (kg)", iconName: "scalemass", placeholder: "Enter your weight") {
                        TextField("", text: $tempWeight)
                            .foregroundColor(.white)
                            .keyboardType(.decimalPad)
                    }
                    .opacity(animateFields ? 1 : 0)
                    .offset(y: animateFields ? 0 : 15)
                    
                    // Birth Date field
                    inputField(title: "Birth Date", iconName: "calendar", placeholder: formatDate(tempBirthDate)) {
                        HStack {
                            Text(formatDate(tempBirthDate))
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                                .font(.system(size: 14))
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                showingDatePicker = true
                            }
                        }
                    }
                    .opacity(animateFields ? 1 : 0)
                    .offset(y: animateFields ? 0 : 15)
                    
                    // Save button
                    Button(action: saveProfile) {
                        HStack {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .semibold))
                            
                            Text("Save Profile")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                    .scaleEffect(animateButton ? 1 : 0.9)
                    .opacity(animateButton ? 1 : 0)
                }
                .padding(.horizontal, 20)
            }
            
            // Goal picker overlay
            if showingGoalPicker {
                goalPickerOverlay
            }
            
            // Date picker overlay
            if showingDatePicker {
                datePickerOverlay
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.white)
                        .font(.system(size: 16, weight: .medium))
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                        )
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Edit Profile")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .onAppear {
            startAnimations()
        }
    }
    
    // MARK: - Profile Photo Section
    private var profilePhotoSection: some View {
        VStack {
            ZStack {
                // Circle background with gradient
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.3)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 130, height: 130)
                    .opacity(0.5)
                
                // Current profile image
                if let profilePicture = profile.profilePicture,
                   let uiImage = UIImage(data: profilePicture) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else if let inputImage = inputImage {
                    Image(uiImage: inputImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.white)
                        .frame(width: 100, height: 100)
                }
                
                // Camera icon button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showingImagePicker = true
                        } label: {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(
                                    Circle()
                                        .fill(Color.blue)
                                        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                        }
                        .offset(x: 10, y: 10)
                    }
                }
                .frame(width: 120, height: 120)
            }
            
            Text("Change Photo")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.gray)
                .padding(.top, 12)
        }
    }
    
    // MARK: - Section Headers
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.bottom, 8)
    }
    
    // MARK: - Input Field
    private func inputField<Content: View>(title: String, iconName: String, placeholder: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
            HStack(spacing: 14) {
                Image(systemName: iconName)
                    .foregroundColor(.gray)
                    .frame(width: 24)
                
                content()
            }
            .padding()
            .frame(height: 56)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Goal Picker Overlay
    private var goalPickerOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showingGoalPicker = false
                    }
                }
            
            // Picker container
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Select Fitness Goal")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            showingGoalPicker = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.2))
                
                // Goals list
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(fitnessGoals, id: \.self) { goal in
                            Button {
                                tempFitnessGoal = goal
                                withAnimation {
                                    showingGoalPicker = false
                                }
                            } label: {
                                HStack {
                                    Text(goal)
                                        .font(.system(size: 16))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 16)
                                    
                                    Spacer()
                                    
                                    if goal == tempFitnessGoal {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                            }
                            
                            Divider()
                                .background(Color.gray.opacity(0.2))
                        }
                    }
                }
            }
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .center)))
        }
        .transition(.opacity)
    }
    
    // MARK: - Date Picker Overlay
    private var datePickerOverlay: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation {
                        showingDatePicker = false
                    }
                }
            
            // Date picker container
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Select Birth Date")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            showingDatePicker = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.2))
                
                // Date picker
                DatePicker("", selection: $tempBirthDate, displayedComponents: .date)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .accentColor(.blue)
                    .padding()
                    .colorScheme(.dark)
                
                // Confirm button
                Button {
                    withAnimation {
                        showingDatePicker = false
                    }
                } label: {
                    Text("Confirm")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.white)
                        .cornerRadius(12)
                        .padding(16)
                }
            }
            .background(Color(.systemGray6).opacity(0.3))
            .cornerRadius(16)
            .padding(.horizontal, 20)
            .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .center)))
        }
        .transition(.opacity)
    }
    
    // MARK: - Helper Methods
    private func saveProfile() {
        // Save name and fitness goal
        profile.name = tempName
        profile.fitnessGoal = tempFitnessGoal
        
        // Save height if valid
        if let height = Double(tempHeight) {
            profile.height = height
        }
        
        // Save weight if valid
        if let weight = Double(tempWeight) {
            profile.weight = weight
        }
        
        // Save birth date
        profile.birthDate = tempBirthDate
        
        // Call completion handler
        onSave()
        
        // Dismiss the view
        dismiss()
    }
    
    private func loadImage() {
        guard let inputImage = inputImage else { return }
        
        // Convert UIImage to Data
        if let imageData = inputImage.jpegData(compressionQuality: 0.8) {
            // Save to profile
            profile.profilePicture = imageData
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func startAnimations() {
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            animateFields = true
        }
        
        withAnimation(.easeOut(duration: 0.5).delay(0.6)) {
            animateButton = true
        }
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.image = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.image = originalImage
            }
            
            parent.dismiss()
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    @State static private var profile = UserProfile(name: "User", fitnessGoal: "Build Muscle")
    
    static var previews: some View {
        NavigationView {
            ProfileEditView(profile: $profile) {
                print("Profile saved")
            }
            .preferredColorScheme(.dark)
        }
    }
}
