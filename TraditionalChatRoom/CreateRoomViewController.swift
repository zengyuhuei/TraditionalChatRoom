

import UIKit

class CreateRoomViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate{
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var roomName: UITextField!
    @IBOutlet weak var roomImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        roomName.delegate = self
        // Do any additional setup after loading the view.
    }
    
    @IBAction func choosePicture(_ sender: UIButton) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        roomImage.image = selectedImage
    
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
