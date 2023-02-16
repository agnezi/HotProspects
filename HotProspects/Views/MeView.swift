////
// HotProspects
// Created by: itsjagnezi on 08/02/23
// Copyright (c) today and beyond
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct MeView: View {
	
	@State private var name = "Dexter"
	@State private var emailAddress = "dexter@gmail.com"
	@State private var qrCode = UIImage()
	
	@EnvironmentObject var prospects: Prospects
	
	let context = CIContext()
	let filter = CIFilter.qrCodeGenerator()

	
	var body: some View {
		Form {
			TextField("Name", text: $name)
				.textContentType(.name)
				.font(.title)
			
			TextField("EmailAddress", text: $emailAddress)
				.textContentType(.emailAddress)
				.font(.title)
			
			Image(uiImage: qrCode)
				.interpolation(.none)
				.resizable()
				.scaledToFit()
				.frame(width: 200, height: 200)
				.contextMenu {
					Button {
						let imageSaver = ImageSaver()
						imageSaver.writeToPhotoAlbum(image: qrCode)
					} label: {
						Label("Save to photos", systemImage: "square.and.arrow.down")
					}
				}
			
			Button {
				let person = Prospect()
				person.name = name
				person.emailAddress = emailAddress
				
				prospects.add(person)
			} label: {
				Text("Save me as prospect")
			}
		}
		.navigationTitle("Your code")
		.onAppear(perform: updateImage)
		.onChange(of: name) { _ in updateImage()}
		.onChange(of: emailAddress) { _ in updateImage()}
		
		
	}
	
	func updateImage() {
		qrCode = generateQRCode(from: "\(name)\n\(emailAddress)")
	}
	
	func generateQRCode(from string: String) -> UIImage {
		filter.message = Data(string.utf8)
		
		if let outputImage = filter.outputImage {
			if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
				return UIImage(cgImage: cgImage)
			}
		}
		
		return UIImage(systemName: "xmark.circle") ?? UIImage()
	}
}

struct MeView_Previews: PreviewProvider {
    static var previews: some View {
        MeView()
    }
}
