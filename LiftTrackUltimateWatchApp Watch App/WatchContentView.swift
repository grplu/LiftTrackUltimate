import SwiftUI

struct WatchContentView: View {
    @State private var isWorkoutActive = false
    @State private var selectedWorkoutType: String?
    
    var body: some View {
        if isWorkoutActive, let workoutType = selectedWorkoutType {
            WatchActiveWorkoutView(
                workoutType: workoutType,
                onEnd: {
                    isWorkoutActive = false
                    selectedWorkoutType = nil
                }
            )
        } else {
            NavigationView {
                List {
                    Section(header: Text("Start Workout")) {
                        ForEach(workoutTypes, id: \.self) { workoutType in
                            Button(action: {
                                selectedWorkoutType = workoutType
                                isWorkoutActive = true
                            }) {
                                Text(workoutType)
                            }
                        }
                    }
                    
                    Section(header: Text("Quick Actions")) {
                        NavigationLink(destination: WatchHistoryView()) {
                            Label("History", systemImage: "clock")
                        }
                        
                        NavigationLink(destination: WatchStatisticsView()) {
                            Label("Statistics", systemImage: "chart.bar")
                        }
                    }
                }
                .navigationTitle("LiftTrack")
            }
        }
    }
    
    let workoutTypes = ["Strength Training", "Cardio", "HIIT", "Flexibility", "Custom"]
}
