////
// HotProspects
// Created by: itsjagnezi on 09/02/23
// Copyright (c) today and beyond
//

import Foundation

class Prospect: Identifiable, Codable, Comparable {
	static func == (lhs: Prospect, rhs: Prospect) -> Bool {
		lhs.name == lhs.name
	}
	
	static func < (lhs: Prospect, rhs: Prospect) -> Bool {
		return lhs.name < rhs.name
	}
	
	var id = UUID()
	var name = "Anonymous"
	var emailAddress = ""
	var createdAt = Date()
	fileprivate(set) var isContacted = false
}

@MainActor class Prospects: ObservableObject {
	@Published private(set) var people: [Prospect]
	
	//	let keyName = "SavedData"
	private static let fileURL = FileManager.documentsDirectory.appendingPathComponent("prospects.data")
	
	init() {
		people = []
		Prospects.loadFile { result in
			switch result {
			case .success(let prospects):
				self.people = prospects
				
			case .failure(let error):
				print("Load json error: \(error.localizedDescription)")
				self.people = []
			}
		}
		return
	}
	
	func toggle(_ prospect: Prospect) {
		objectWillChange.send()
		prospect.isContacted.toggle()
		save()
	}
	
	private func save() {
		Prospects.saveFile(prospects: people) {result in
			switch result {
			case .success:
				print("People saved")
				
			case .failure(let error):
				print("People saved error \(error)")
				
			}
		}
	}
	
	func add(_ prospect: Prospect) {
		people.append(prospect)
		save()
	}
	
	private static func loadFile() async throws -> [Prospect] {
		try await withCheckedContinuation { continuation in
			loadFile { result in
				switch result {
				case .failure(let error):
					continuation.resume(throwing: error as! Never)
					
				case .success(let prospects):
					continuation.resume(returning: prospects)
				}
			}
		}
	}
	
	private static func loadFile(completion: @escaping (Result<[Prospect], Error>)->Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let fileURL = fileURL
				
				guard let file = try? FileHandle(forReadingFrom: fileURL) else {
					DispatchQueue.main.async {
						completion(.success([]))
					}
					return
				}
				let prospects = try JSONDecoder().decode([Prospect].self, from: file.availableData)
				DispatchQueue.main.async {
					completion(.success(prospects))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	private static func saveFile(prospects: [Prospect]) async throws -> Int {
		try await withCheckedThrowingContinuation { continuation in
			saveFile(prospects: prospects) { result in
				switch result {
				case .failure(let error):
					continuation.resume(throwing: error)
				case .success(let prospectsSaved):
					continuation.resume(returning: prospectsSaved)
				}
			}
		}
	}
	
	private static func saveFile(prospects: [Prospect], completion: @escaping (Result<Int, Error>)-> Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let data = try JSONEncoder().encode(prospects)
				let outfile = fileURL
				try data.write(to: outfile)
				DispatchQueue.main.async {
					completion(.success(prospects.count))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
}
