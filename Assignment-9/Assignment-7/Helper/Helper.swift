import UIKit

func convertImageToBase64String(image: UIImage) -> String? {
    guard let imageData = image.jpegData(compressionQuality: 0.1) else {
        return nil
    }
    return convertBase64ToUtf8(base64String: imageData.base64EncodedString(options: .lineLength64Characters))
}
func convertBase64ToUtf8(base64String: String) -> String? {
    guard let data = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters) else {
        print("Invalid Base64 string")
        return nil
    }

    return String(data: data, encoding: .utf8)
}
func getImagefromURL(_ url:String?)->UIImage?{
    guard let urlString = url, !urlString.isEmpty else {
        if let imageData = Data(base64Encoded: InsuranceDirectory.profileImage, options: .ignoreUnknownCharacters)
        {
            return UIImage(data: imageData)
        }
        return nil
    }
    let imageURL = recreateURL(from: urlString)
    if let filePath = imageURL?.path {
        print(filePath)
        if let image = UIImage(contentsOfFile: filePath){
            print("Successfully loaded image")
            return image
        } else {
            print("Failed to load image from file URL")
        }
    } else {
        print("Invalid file URL")
    }
    return nil
}
func saveImageFromGallery(contentURI: URL) -> String? {
    guard let imageData = getDataFromContentURI(contentURI: contentURI) else { return nil }

    let fileName = UUID().uuidString + ".jpg"
    let documentsDirectory = getDocumentsDirectory() // This is already correct!
    let fileURL = documentsDirectory.appendingPathComponent(fileName)

    try? imageData.write(to: fileURL)
    print("Image saved to: \(fileURL)")
    return fileName
}

func saveImageLocally(imageData: Data, fileName: String) { // Removed directory parameter
    let documentsDirectory = getDocumentsDirectory() // Get the directory here
    let fileURL = documentsDirectory.appendingPathComponent(fileName)
    try? imageData.write(to: fileURL)
    print("Image saved to: \(fileURL)")
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func getDataFromContentURI(contentURI: URL) -> Data? {
    do {
        let data = try Data(contentsOf: contentURI)
        return data
    } catch {
        print("Error getting data from content URI: \(error)")
        return nil
    }
}
func recreateURL(from fileName: String) -> URL? {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    return fileURL
}
