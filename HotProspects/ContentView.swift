////
// HotProspects
// Created by: itsjagnezi on 03/02/23
// Copyright (c) today and beyond
//

import SwiftUI

struct ContentView: View {
	
	@StateObject var prospects = Prospects()
	
	
	var body: some View {
		TabView {
			ProspectsView(filter: .everyone)
				.tabItem {
					Label("Everyone",  systemImage: "person.3.fill")
				}
			
			ProspectsView(filter: .contacted)
				.tabItem {
					Label("Contacted", systemImage: "checkmark.circle")
				}
			
			ProspectsView(filter: .uncontacted)
				.tabItem {
					Label("Uncontacted", systemImage: "questionmark.diamond")
				}
			
			MeView()
				.tabItem {
					Label("Me", systemImage: "person.crop.square")
				}
		}
		.environmentObject(prospects)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
			.environmentObject(Prospects())
	}
}
