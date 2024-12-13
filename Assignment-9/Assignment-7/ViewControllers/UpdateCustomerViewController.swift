import UIKit
import Photos

class UpdateCustomerViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var profileImage: UIImageView!
    
    private var profileImageLocation: String = ""
    
    var user: Customer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let user else { return }
        
        nameTextField.text = user.name
        ageTextField.text = String(user.age)
        emailTextField.isEnabled = false
        emailTextField.text = user.email
        
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        profileImageLocation = user.profileImage ?? ""
        let image = getImagefromURL(user.profileImage)
        profileImage.image = image
       
    }
    
    func converttoImage(from base64String: String) -> UIImage? {
        guard let data = Data(base64Encoded: base64String) else {
            return nil
        }
        return UIImage(data: data)
    }
    
    
    @IBAction func updateCustomer(_ sender: UIButton) {
        print("Update Customer")
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
        guard let user = user else {
            showAlert(title: "Error", message: "Please select a customer to update.")
            return
        }
        let newCustomer = Customer(id: user.id, name: name, age: Int(age)!, email: emailTextField.text!)
        newCustomer.profileImage = profileImageLocation
        Task{
            let result = await InsuranceDirectory.shared.updateCustomer(update: newCustomer)
            if result {
                await MainActor.run {
                    showAlert(title: "Success", message: "Customer updated successfully.",handler:{_ in self.navigationController?.popViewController(animated: true)
                    })
                }
            } else {
                await MainActor.run {
                    showAlert(title: "Error", message: "Customer could not be updated.")
                }
            }
        }
    }
    
    @IBAction func deleteCustomer(_ sender: UIButton) {
        print("Delete Customer")
        guard let user = user else {
            showAlert(title: "Warning", message: "No customer selected.")
            return
        }
        guard user.pastPolicies else {
            Task{
                if await InsuranceDirectory.shared.deleteCustomer(id:user.id){
                    await MainActor.run {
                        showAlert(title: "Success", message: "Customer deleted.", handler:{_ in self.navigationController?.popViewController(animated: true)})
                    }
                } else {
                    await MainActor.run {
                        showAlert(title: "Error", message: "Could not delete customer.")
                    }
                }
            }
            return
        }
        showAlert(title: "Warning", message: "Can't delete customer with active/past insurance.")
        
    }
    
    @IBAction func unwindToPreviousScreen(_ sender: UIStoryboardSegue) {
        print("Unwind to previous screen")
    }
    
    @IBAction func changeProfilePicture(_ sender: UIButton) {
        checkPhotoLibraryPermission()
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
    
    func showAlert(title: String, message: String, handler: ((UIAlertAction) -> Void)?=nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler))
        present(alert, animated: true, completion: nil)
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
