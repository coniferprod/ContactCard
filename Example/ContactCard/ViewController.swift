//
//  ViewController.swift
//  ContactCard
//
//  Created by Jere Käpyaho on 03/14/2017.
//  Copyright (c) 2017 Jere Käpyaho. All rights reserved.
//

import UIKit
import ContactsUI
import ContactCard

class ViewController: UIViewController, CNContactPickerDelegate {
    let controller = CNContactPickerViewController()
    
    @IBOutlet weak var pickContactButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        controller.delegate = self
        
        ContactAuthorizer.authorizeContacts { succeeded in
            DispatchQueue.main.async { [weak self] in
                self?.pickContactButton.isEnabled = succeeded
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func pickContact(_ sender: Any) {
        print("Button clicked")
        present(controller, animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Contact picking cancelled by user")
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        print("User did select contact")
        let card = cardFrom(contact: contact)
        
        let cardAsJSON = card.asJSON()
        print("Contact card as JSON (\(cardAsJSON.count) characters):")
        print(cardAsJSON)
        
        print("\n")
        
        let cardAsvCard = card.asvCard()
        print("Contact card as vCard 3.0 (\(cardAsvCard.count) characters):")
        print(cardAsvCard)
    }
}


public final class ContactAuthorizer {
    public class func authorizeContacts(completionHandler : @escaping (_ succeeded: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            completionHandler(true)
            
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { succeeded, err in completionHandler(err == nil && succeeded)
            }
        default:
            completionHandler(false)
        }
    }
}

