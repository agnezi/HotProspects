////
// HotProspects
// Created by: itsjagnezi on 15/02/23
// Copyright (c) today and beyond
//

import Foundation

extension FileManager {
	static var documentsDirectory: URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}
