//
//  MemeEditorViewController.swift
//  MemeMe-V1
//
//  Created by Florent Spahiu on 17/05/2017.
//  Copyright © 2017 Florent Spahiu. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var mainImageView: UIImageView!
    
    @IBOutlet weak var cameraBtn: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var shareBtn: UIBarButtonItem!
    
    @IBOutlet weak var bottomBar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    let memeTextAttributes:[String:Any] = [
        NSStrokeColorAttributeName: UIColor.black,
        NSForegroundColorAttributeName: UIColor.white,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName: -3.6]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topTextField.delegate = self
        bottomTextField.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() //when clicking Done, hide the keyboard
        return true
    }

    //MARK: - Image picking
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        pick(sourceType: .camera)
    }
    
    @IBAction func pickAnImageFromLibrary(_ sender: AnyObject) {
        pick(sourceType: .photoLibrary)
    }
    
    func pick(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            mainImageView.image = image //show image into the imageView
        }
        dismiss(animated: true, completion: nil) //hide image picker
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil) //no image was selected, go back
    }
    
    override func viewWillAppear(_ animated: Bool) {
        subscribeToKeyboardNotifications()
        
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        shareBtn.isEnabled = mainImageView.image != nil
        
        prepareTextField(textField: topTextField)
        prepareTextField(textField: bottomTextField)
    }
    
    func prepareTextField(textField: UITextField) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment  = .center
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: - Keyboard Notifications
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        if bottomTextField.isEditing {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
   @IBAction func clearTextAndImage(){
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        mainImageView.image = nil
        shareBtn.isEnabled = false
    }
    
    //MARK: - Image Sharing and Saving
    @IBAction func shareImage() {
        let memedImage = generateMemedImage()
        let activityView = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityView.completionWithItemsHandler = {(activity, completed, items, error) in
            if (completed) {
                let _ = self.save()
            }
        }
        
        self.present(activityView, animated: true, completion: nil)
    }
    
    func save() {
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: mainImageView.image!, memedImage: generateMemedImage())
        print(meme)
    }
    
    //MARK: - Meme Generation
    func generateMemedImage() -> UIImage {
        bottomBar.isHidden = true
        navigationBar.isHidden = true
        
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        bottomBar.isHidden = false
        navigationBar.isHidden = false
        
        return memedImage
    }
}
