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
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(hex: "1a1a1a"),
                        Color(hex: "101010")
                    ]),
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
                        }
                        
                        if selectedTab == .myTemplates && !isSearching {
                            // Add template button (only in My Templates)
                            Button(action: {
                                showingAddTemplate = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
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
                            
                            TextField("Search templates...", text: $searchText)
                                .foregroundColor(.white)
                            
                            if !searchText.isEmpty {
                                Button(action: {
                                    searchText = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(10)
                        .background(Color(.systemGray6).opacity(0.3))
                        .cornerRadius(10)
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
            }
            .sheet(isPresented: $showingAddTemplate) {
                EnhancedTemplateCreationView(onSave: { newTemplate in
                    // Save the new template to the data manager
                    dataManager.saveTemplate(newTemplate)
                })
                .environmentObject(dataManager)
                .environment(\.colorScheme, .dark)
            }
        }
        .onAppear {
            // Animate cards when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    animateCards = true
                }
            }
        }
    }
    
    // MARK: - My Templates Section
    private var myTemplatesSection: some View {
        VStack(spacing: 16) {
            // Show user's templates or empty state
            if dataManager.templates.isEmpty {
                emptyTemplatesView
            } else {
                // Filter templates based on search if needed
                let templates = searchText.isEmpty ? dataManager.templates :
                    dataManager.templates.filter { $0.name.lowercased().contains(searchText.lowercased()) }
                
                if templates.isEmpty {
                    // No search results
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("No templates found")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text("Try a different search term")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 100)
                } else {
                    // Display templates in a grid
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(Array(templates.enumerated()), id: \.element.id) { index, template in
                            TemplateCard(
                                template: template,
                                index: index,
                                appear: animateCards
                            )
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
                            FeaturedTemplateCard(
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
                    PopularTemplateRow(
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
                            CategoryPill(name: category)
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
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.blue)
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
                Text("Create Template")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .cornerRadius(10)
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
                    .padding(.vertical, 12)
                    .background(Color.blue.opacity(0.15))
                    .cornerRadius(10)
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

struct TemplateCard: View {
    var template: WorkoutTemplate
    var index: Int
    var appear: Bool
    
    var body: some View {
        NavigationLink(destination: Text("Template Detail View")) {
            VStack(alignment: .leading, spacing: 12) {
                // Template name
                Text(template.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                // Exercise count
                HStack {
                    Image(systemName: "dumbbell.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                    
                    Text("\(template.exercises.count) exercises")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // Estimated time
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                    
                    Text("\(template.exercises.count * 10) mins")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .frame(height: 160)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.systemGray6).opacity(0.3),
                        Color(.systemGray6).opacity(0.2)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 2)
            .opacity(appear ? 1 : 0)
            .offset(y: appear ? 0 : 20)
            .animation(
                .spring(response: 0.6, dampingFraction: 0.8)
                .delay(0.1 + Double(index) * 0.05),
                value: appear
            )
        }
    }
}

struct FeaturedTemplateCard: View {
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
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("by \(author)")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Rating
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    
                    Text(String(format: "%.1f", rating))
                        .font(.subheadline)
                        .fontWeight(.semibold)
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
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Download button
                Button(action: {}) {
                    Text("Get")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(color)
                        .cornerRadius(12)
                }
            }
        }
        .padding(16)
        .frame(width: 240, height: 140)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.systemGray6).opacity(0.3),
                    Color(.systemGray6).opacity(0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(0.2 + Double(index) * 0.1),
            value: appear
        )
    }
}

struct PopularTemplateRow: View {
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
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 36, height: 36)
                    
                    Text("\(index + 1)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Template info
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("by \(author) • \(exercises) exercises")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Stats section
                VStack(alignment: .trailing, spacing: 4) {
                    // Rating
                    HStack(spacing: 4) {
                        Text(String(format: "%.1f", rating))
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.yellow)
                    }
                    
                    // Downloads
                    Text("\(downloads) downloads")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(12)
            .background(Color(.systemGray6).opacity(0.2))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(appear ? 1 : 0)
        .offset(y: appear ? 0 : 20)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.8)
            .delay(0.3 + Double(index) * 0.05),
            value: appear
        )
    }
}

struct CategoryPill: View {
    var name: String
    
    var body: some View {
        Text(name)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.2))
            .cornerRadius(20)
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
