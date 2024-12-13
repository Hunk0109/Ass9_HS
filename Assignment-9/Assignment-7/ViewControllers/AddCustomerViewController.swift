import UIKit
import Photos


class AddCustomerViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var profileImage: UIImageView!
    private var profileImageLocation: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        
        let image = converttoImage(from: InsuranceDirectory.profileImage)
        profileImage.image = image
        
    }
    
    func converttoImage(from base64String: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    @IBAction func addCustomer(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter a name")
            return
        }
        guard let age = ageTextField.text, !age.isEmpty else {
            showAlert(title: "Error", message: "Please enter an age")
            return
        }
        guard let ageInt = Int(age), ageInt > 0  else {
            showAlert(title: "Error", message: "Please enter an age greater than zero.")
            return
        }
        let emailPattern = #"^\S+@\S+\.\S+$"#
        
        guard emailTextField.text?.range(of: emailPattern, options: .regularExpression) != nil else {
            showAlert(title: "Warning",message:"Invalid email format. Please enter a valid email.")
            return
        }
        let newCustomer = Customer(id: UUID().hashValue, name: name, age: ageInt, email: emailTextField.text!)
        newCustomer.profileImage = profileImageLocation
        
        Task{
            if await InsuranceDirectory.shared.addCustomer(customer: newCustomer) {
                await MainActor.run {
                    showAlert(title: "Success", message: "Customer added successfully.")
                }
            } else{
                await MainActor.run {
                    showAlert(title: "Error", message: "Customer could not be added.")
                }
            }
        }
        nameTextField.text = ""
        ageTextField.text = ""
        emailTextField.text = ""
        profileImageLocation = ""
        profileImage.image = converttoImage(from: InsuranceDirectory.profileImage)
    }
    
    @IBAction func changeProfileImage(_ sender: UIButton) {
        checkPhotoLibraryPermission()
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    self.openImagePicker()
                }
            }
        case .authorized:
            openImagePicker()
        case .denied, .restricted:
            print("Permission denied.")
        case .limited:
            openImagePicker()
        @unknown default:
            break
        }
    }
    func openImagePicker() {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            profileImage.image = selectedImage
            if let imageURL = info[.imageURL] as? URL {
                let newURL = saveImageFromGallery(contentURI: imageURL)
                self.profileImageLocation = newURL ?? ""
            } else {
                print("Image URL not available.")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
