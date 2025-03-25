import SwiftUI

struct TemplatesView: View {
    @EnvironmentObject var dataManager: DataManager
    @State private var showingAddTemplate = false
    @State private var selectedTab: TemplateTab = .myTemplates
    @State private var searchText = ""
    @State private var isSearching = false
    @State private var animateCards = false
    
    enum TemplateTab {
        case myTemplates, discover
    }
    
    var body: some View {
        NavigationView {  // Added NavigationView here
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color(hex: "101010")]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header with search
                    HStack(spacing: 16) {
                        if isSearching {
                            // Back button when searching
                            Button(action: {
                                withAnimation {
                                    isSearching = false
                                    searchText = ""
                                }
                            }) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        } else {
                            // Title when not searching
                            Text(selectedTab == .myTemplates ? "Workout Templates" : "Template Store")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                        // Search button
                        Button(action: {
                            withAnimation {
                                isSearching.toggle()
                            }
                        }) {
                            Image(systemName: isSearching ? "xmark.circle.fill" : "magnifyingglass")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .frame(width: 38, height: 38)
                                .background(
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .opacity(isSearching ? 0 : 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, isSearching ? 8 : 16)
                    
                    // Search field (when searching)
                    if isSearching {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .padding(.leading, 8)
                            
                            TextField("Search templates...", text: $searchText)
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                        .padding(.trailing, 8)
                                }
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6).opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal)
                        .padding(.bottom, 16)
                    }
                    
                    // Tab switcher
                    HStack(spacing: 0) {
                        TabButton(
                            title: "My Templates",
                            isSelected: selectedTab == .myTemplates,
                            action: { withAnimation { selectedTab = .myTemplates } }
                        )
                        
                        TabButton(
                            title: "Discover",
                            isSelected: selectedTab == .discover,
                            action: { withAnimation { selectedTab = .discover } }
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
                    // Templates content
                    ScrollView {
                        if selectedTab == .myTemplates {
                            // My Templates
                            myTemplatesSection
                        } else {
                            // Discover section
                            discoverSection
                        }
                    }
                    .refreshable {
                        // Pull to refresh - reload templates
                        animateCards = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                animateCards = true
                            }
                        }
                    }
                }
                
                // Floating Add Button (only in My Templates tab)
                if selectedTab == .myTemplates && !isSearching {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                showingAddTemplate = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                                    .frame(width: 56, height: 56)
                                    .background(
                                        Circle()
                                            .fill(Color.blue)
                                            .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
                                    )
                            }
                            .padding(.trailing, 20)
                            .padding(.bottom, 80) // Extra padding for tab bar
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddTemplate) {
                EnhancedTemplateCreationView(onSave: { newTemplate in
                    // Save the new template to the data manager
                    dataManager.saveTemplate(newTemplate)
                })
                .environmentObject(dataManager)
                .environment(\.colorScheme, .dark)
            }
            .navigationBarHidden(true)
            .onAppear {
                // Animate cards when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        animateCards = true
                    }
                }
            }
        } // Closing NavigationView here
    }
    
    // Update the myTemplatesSection in your TemplatesView.swift

    private var myTemplatesSection: some View {
        VStack(spacing: 16) {
            if dataManager.templates.isEmpty {
                emptyTemplatesView
            } else {
                let templates = searchText.isEmpty ? dataManager.templates :
                    dataManager.templates.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                
                if templates.isEmpty {
                    // No templates found view
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .padding(.top, 40)
                        
                        Text("No templates found")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Try a different search term")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 60)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(templates) { template in
                            NavigationLink(destination: TemplateDetailView(template: template)) {
                                EnhancedTemplateCard(
                                    template: template,
                                    index: templates.firstIndex(of: template) ?? 0,
                                    appear: animateCards
                                )
                                .id(template.id)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
        }
    }
    
    // MARK: - Discover Section
    private var discoverSection: some View {
        VStack(spacing: 24) {
            // Featured template section
            VStack(alignment: .leading, spacing: 16) {
                Text("Featured Templates")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<5) { i in
                            EnhancedFeaturedCard(
                                name: featuredTemplates[i].name,
                                author: featuredTemplates[i].author,
                                exercises: featuredTemplates[i].exercises,
                                rating: featuredTemplates[i].rating,
                                color: featuredTemplates[i].color,
                                index: i,
                                appear: animateCards
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
            }
            
            // Popular templates section
            VStack(alignment: .leading, spacing: 16) {
                Text("Popular Templates")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ForEach(0..<6) { i in
                    EnhancedPopularRow(
                        name: popularTemplates[i].name,
                        author: popularTemplates[i].author,
                        exercises: popularTemplates[i].exercises,
                        rating: popularTemplates[i].rating,
                        downloads: popularTemplates[i].downloads,
                        index: i,
                        appear: animateCards
                    )
                    .padding(.horizontal)
                }
            }
            
            // Categories section
            VStack(alignment: .leading, spacing: 16) {
                Text("Categories")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            EnhancedCategoryPill(name: category)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Spacer(minLength: 100)
        }
        .padding(.vertical)
    }
    
    // MARK: - Empty Templates View
    private var emptyTemplatesView: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "rectangle.stack.badge.plus")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
            }
            .padding(.bottom, 16)
            
            Text("No Templates Yet")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Create custom workout templates to quickly start your favorite workouts")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)
            
            Button(action: {
                showingAddTemplate = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                    
                    Text("Create Template")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .shadow(color: Color.blue.opacity(0.4), radius: 8, x: 0, y: 4)
            }
            .padding(.top, 16)
            
            Divider()
                .background(Color.gray.opacity(0.3))
                .padding(.vertical, 24)
            
            Text("Or discover templates from others")
                .font(.headline)
                .foregroundColor(.white)
            
            Button(action: {
                withAnimation {
                    selectedTab = .discover
                }
            }) {
                Text("Browse Template Store")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.blue.opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.top, 8)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // Sample data for Discover section
    private let featuredTemplates = [
        (name: "Full Body Blast", author: "FitCoach", exercises: 8, rating: 4.8, color: Color.blue),
        (name: "Home HIIT", author: "GymPro", exercises: 6, rating: 4.6, color: Color.purple),
        (name: "Strength Builder", author: "MuscleGains", exercises: 10, rating: 4.9, color: Color.green),
        (name: "5x5 Workout", author: "StrengthPro", exercises: 5, rating: 4.7, color: Color.orange),
        (name: "Core Crusher", author: "AbMaster", exercises: 7, rating: 4.5, color: Color.red)
    ]
    
    private let popularTemplates = [
        (name: "PPL - 6 Day Split", author: "MuscleScience", exercises: 18, rating: 4.9, downloads: "10.2K"),
        (name: "Starting Strength", author: "BarBeast", exercises: 9, rating: 4.8, downloads: "8.5K"),
        (name: "HIIT Cardio Mix", author: "CardioKing", exercises: 12, rating: 4.7, downloads: "7.3K"),
        (name: "Calisthenics Basic", author: "BodyWeight", exercises: 8, rating: 4.6, downloads: "6.8K"),
        (name: "Quick 20 Min", author: "TimeSaver", exercises: 5, rating: 4.5, downloads: "5.9K"),
        (name: "Olympic Lifting", author: "LiftHeavy", exercises: 6, rating: 4.7, downloads: "4.2K")
    ]
    
    private let categories = [
        "Strength", "Hypertrophy", "HIIT", "Cardio", "Calisthenics",
        "Beginner", "Intermediate", "Advanced", "Home", "Gym"
    ]
}

// MARK: - Component Views

struct TabButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : .gray)
                    .frame(maxWidth: .infinity)
                
                // Indicator bar
                Rectangle()
                    .fill(isSelected ? Color.blue : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
    }
}

struct EnhancedTemplateCard: View {
    var template: WorkoutTemplate
    var index: Int
    var appear: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Icon and title row
            HStack(alignment: .center, spacing: 12) {
                // Badge icon with gradient background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.5)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
                
                // Template name
                Text(template.name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Stats row
            VStack(spacing: 12) {
                // Exercise count
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    
                    Text("\(template.exercises.count) exercises")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    // Chevron indicator
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                // Estimated time with divider
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("\(template.exercises.count * 10) mins")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
            }
        }
        .padding(16)
        .frame(height: 160)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
            .delay(0.1 + Double(index) * 0.05),
            value: appear
        )
    }
}

struct EnhancedFeaturedCard: View {
    var name: String
    var author: String
    var exercises: Int
    var rating: Double
    var color: Color
    var index: Int
    var appear: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Top section with rating
            HStack {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("by \(author)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", rating))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            // Bottom section
            HStack {
                // Exercise count
                HStack(spacing: 4) {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(color)
                    
                    Text("\(exercises) exercises")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Download button
                Button(action: {}) {
                    Text("Get")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [color, color.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
            }
        }
        .padding(16)
        .frame(width: 240, height: 140)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6).opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
            .delay(0.2 + Double(index) * 0.1),
            value: appear
        )
    }
}

struct EnhancedPopularRow: View {
    var name: String
    var author: String
    var exercises: Int
    var rating: Double
    var downloads: String
    var index: Int
    var appear: Bool
    
    var body: some View {
        Button(action: {}) {
            HStack(spacing: 16) {
                // Rank number with background
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.blue.opacity(0.3)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text("by \(author) • \(exercises) exercises")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Stats section
                VStack(alignment: .trailing, spacing: 4) {
                    // Rating
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                    
                    // Downloads
                    Text("\(downloads) downloads")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemGray6).opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            .spring(response: 0.5, dampingFraction: 0.8)
            .delay(0.3 + Double(index) * 0.05),
            value: appear
        )
    }
}

struct EnhancedCategoryPill: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(Color.blue.opacity(0.15))
                    .overlay(
                        Capsule()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
            )
    }
}

// Helper for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
