import SwiftUI

struct WatchStatisticsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                // Weekly summary
                VStack(alignment: .leading, spacing: 5) {
                    Text("This Week")
                        .font(.headline)
                    
                    HStack {
                        VStack {
                            Text("4")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Workouts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("230")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Minutes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                // Heart rate stats
                VStack(alignment: .leading, spacing: 5) {
                    Text("Heart Rate")
                        .font(.headline)
                    
                    HStack {
                        VStack {
                            Text("72")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Resting")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        
                        VStack {
                            Text("150")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Peak")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Stats")
    }
}
