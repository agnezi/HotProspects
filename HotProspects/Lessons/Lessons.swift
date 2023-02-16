////
// HotProspects
// Created by: itsjagnezi on 03/02/23
// Copyright (c) today and beyond
//

import SwiftUI
import UserNotifications
import SamplePackage

@MainActor class User: ObservableObject {
	@Published var name = "Taylor Swift"
}


@MainActor class UpdateDelayed:ObservableObject {
	@Published var value = 0
	
	
	init() {
		for i in 1...10 {
			DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
				self.value += 1
			}
		}
	}
}


struct EditView: View {
	@EnvironmentObject var user: User
	
	var body: some View {
		TextField("Name", text: $user.name)
			.textFieldStyle(.roundedBorder)
	}
}


struct DisplayView: View {
	@EnvironmentObject var user: User
	
	var body: some View {
		VStack {
			
			Text(user.name)
			
			
		}
	}
}

struct ImageWithContextMenu: View {
	var body: some View {
		Image("some-person")
			.interpolation(.none)
			.resizable()
			.scaledToFit()
			.background(.black)
			.contextMenu {
				Button("Nothing") {
					print("Nothing")
				}
			}
	}
}


struct TextWithSwipeActions: View {
	var output: String
	
	var body: some View {
		List {
			Text(output)
				.foregroundColor(.green)
				.swipeActions {
					Button {
						print("Nothing")
					} label: {
						Label("test", systemImage: "heart")
					}
					.tint(.red)
				}
		}
		.listStyle(.inset)
	}
}

struct Lessons: View {
	
	@StateObject var user = User()
	@StateObject var updater = UpdateDelayed()
	
	@State private var output = ""
	
	
	let possibleNumbers = Array(1...60)
	var results: String {
		let selected = possibleNumbers.random(7).sorted()
		let strings = selected.map(String.init)
		
		return strings.joined(separator: ", ")
	}
	
	var body: some View {
		
		TabView {
			VStack {
				EditView()
				DisplayView()
				
				Text("Value is: \(updater.value)")
					.font(.largeTitle)
				
				ImageWithContextMenu()
			}
			.task {
				await fetchReadings()
			}
			
			.tabItem {
				Label("Home", systemImage: "house")
			}
			
			VStack {
				
				Button("Request notifications permission") {
					UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { success, error in
						if success {
							print("All set for notifications")
						} else if let error = error {
							print(error.localizedDescription)
						}
					}
				}
				.buttonStyle(.bordered)
				
				
				Button("Dispatch a notification after five seconds") {
					let content = UNMutableNotificationContent()
					content.title = "Feed the dog"
					content.subtitle = "It looks hungry"
					content.sound = UNNotificationSound.default
					
					//show this notification five seconds from now
					let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
					
					// choose a random identifier
					let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
					
					// add notification request
					UNUserNotificationCenter.current().add(request)
				}
				
				TextWithSwipeActions(output: output)
				.buttonStyle(.bordered)
			}
			.tabItem {
				Label("Test", systemImage: "pencil")
			}
			
			VStack{
				Text(results)
			}
				.tabItem {
					Label("Outros", systemImage: "heart")
				}
		}
	
		
		.environmentObject(user)
	}
	
	func fetchReadings() async {
		
		let fetchTask = Task { () -> String in
			let url = URL(string: "https://hws.dev/readings.json")!
			let (data, _) = try await URLSession.shared.data(from: url)
			let readings = try JSONDecoder().decode([Double].self, from: data)
			return "Found \(readings.count) readings"
		}
		
		let result = await fetchTask.result
		
		do {
			output = try result.get()
		} catch {
			output = "Error: \(error.localizedDescription)"
		}
	}
}

struct Lessons_Previews: PreviewProvider {
	static var previews: some View {
		Lessons()
	}
}

