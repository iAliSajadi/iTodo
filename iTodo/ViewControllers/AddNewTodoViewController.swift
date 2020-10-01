//
//  AddNewTodoViewController.swift
//  iTodo
//
//  Created by Ali Sajadi on 9/29/20.
//  Copyright © 2020 Ali Sajadi. All rights reserved.
//

import UIKit
import CoreData

enum Priority: Int {
    case low
    case medium
    case high
}

class AddNewTodoViewController: UIViewController {

    //MARK: - Properties
    
    var context: NSManagedObjectContext!
    var todo: Todo?
    
    //MARK: - Outlets
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotification()
        setupViews()
        textView.becomeFirstResponder()
    }
    
    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(with:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    func setupViews() {
        if let todo = self.todo {
            textView.text = todo.title
            textView.text = todo.title
            for segment in 0..<segmentedControl.numberOfSegments {
                if segmentedControl.titleForSegment(at: segment) == todo.priority {
                    segmentedControl.selectedSegmentIndex = segment
                }
            }
        }
    }

    //MARK: - Actions
    
    @objc func keyboardWillShow(with notification: Notification) {
        let key = "UIKeyboardFrameEndUserInfoKey"
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        let keyboardHeight = keyboardFrame.cgRectValue.height
        
        bottomConstraint.constant = keyboardHeight + 8
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    fileprivate func dismissAndResign() {
        dismiss(animated: true, completion: nil)
        textView.resignFirstResponder()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        dismissAndResign()
    }
    
    @IBAction func didTapDone(_ sender: Any) {
        guard let title = textView.text, !title.isEmpty else { return }
        
        if let todo = self.todo {
            todo.title = title
            todo.priority = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
        } else {
            let todo = Todo(context: context)
            todo.title = title
            todo.priority = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)
            todo.date = Date()
        }
        
        do {
            try context.save()
            dismissAndResign()
        } catch {
            print("Error saving todo: \(error)")
        }
    }
}

extension AddNewTodoViewController: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        if doneButton.isHidden {
            textView.text.removeAll()
            textView.textColor = .white
            
            doneButton.isHidden = false
            
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
