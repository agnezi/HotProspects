////
// HotProspects
// Created by: itsjagnezi on 08/02/23
// Copyright (c) today and beyond
//

import UserNotifications
import CodeScanner
import SwiftUI

struct ProspectsView: View {
	
	@EnvironmentObject var prospects: Prospects
	
	@State private var isShowingScanner = false
	@State private var isShowingSortAlert = false
	
	@State private var sortBy = SortBy.none
	
	enum SortBy {
		case none, recent, name
	}
	
	enum FilterType {
		case everyone, contacted, uncontacted
	}
	
	var filter: FilterType
	
	var title: String {
		switch filter {
		case .everyone:
			return "Everyone"
			
		case .contacted:
			return "Contacted people"
			
		case .uncontacted:
			return "Uncontacted people"
		}
		
	}
	
	var filteredProspects: [Prospect] {
		switch filter {
		case .everyone:
			return prospects.people
			
		case .contacted:
				return prospects.people.filter { $0.isContacted }
			
		case .uncontacted:
			return prospects.people.filter { !$0.isContacted }
		}
	}
	
	var sortedProspects: [Prospect] {
		switch sortBy {
			
		case .none:
			return filteredProspects
			
		case .name:
			return filteredProspects.sorted(by: <)
			
		case .recent:
			return filteredProspects.sorted { $0.createdAt < $1.createdAt}
		}
		
	}
	
	var body: some View {
		NavigationView {
			List {
				ForEach(sortedProspects) { prospect in
					HStack {
						if prospect.isContacted && filter == .everyone {
							Image(systemName:"person.fill.checkmark")
						}
							
							VStack(alignment: .leading) {
								Text(prospect.name)
									.font(.headline)
								Text(prospect.emailAddress)
									.foregroundColor(.secondary)
							}
					}
					.swipeActions {
						if prospect.isContacted {
							Button {
								prospects.toggle(prospect)
							} label: {
								Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
							}
							.tint(.blue)
						} else {
							Button {
								prospects.toggle(prospect)
							} label: {
								Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
							}
							.tint(.green)
						}
						
						Button {
							addNotification(for: prospect)
						} label: {
							Label("Reminder", systemImage: "bell")
						}
						.tint(.orange)
					}
				}
			}
			.navigationTitle(title)
			.toolbar {
				Button {
					
					isShowingSortAlert = true
				} label: {
					Label("Sort", systemImage: "arrow.up.arrow.down")
				}
				Button {
					isShowingScanner = true
				} label: {
					Label("Scan", systemImage: "qrcode.viewfinder")
				}
			}
			.sheet(isPresented: $isShowingScanner) {
				CodeScannerView(codeTypes: [.qr], simulatedData: "Jonas\ntkoff0110@hotmail.com", completion: handleScan)
			}
			.alert(Text("Sort by: "), isPresented: $isShowingSortAlert) {
				Button{
					prospects.objectWillChange.send()
					sortBy = .name
				} label: {
					Text("Sort by name")
				}
				Button{
					prospects.objectWillChange.send()
					sortBy = .recent
				} label: {
					Text("Sort by recent added")
				}
				Button{
					prospects.objectWillChange.send()
					sortBy = .none
				} label: {
					Text("Do not sort")
				}
			}
		}
		
	}
	
	func handleScan(result: Result<ScanResult, ScanError>) {
		isShowingScanner = false
		
		switch result {
		case .success(let result):
			let details = result.string.components(separatedBy: "\n")
			guard details.count == 2 else { return }
			
			let person = Prospect()
			person.name = details[0]
			person.emailAddress = details[1]
			
			prospects.add(person)
			
		case .failure(let error):
			print("Scanning failed: \(error.localizedDescription)")
		}
	}
	
	func addNotification(for prospect: Prospect) {
		let center = UNUserNotificationCenter.current()
		
		let addRequest = {
			let content = UNMutableNotificationContent()
			content.title = "Contact \(prospect.name)"
			content.subtitle = prospect.emailAddress
			content.sound = UNNotificationSound.default
			
			var dateComponents = DateComponents()
			dateComponents.hour = 9
			
			//			let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
			let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
			
			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			center.add(request)
		}
		
		center.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				center.requestAuthorization(options: [.alert, .badge, .sound]) { succcess, error in
					if succcess {
						addRequest()
					} else {
						print("D'oh")
					}
				}
			}
		}
	}
}
