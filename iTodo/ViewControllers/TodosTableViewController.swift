//
//  TodosTableViewController.swift
//  iTodo
//
//  Created by Ali Sajadi on 9/29/20.
//  Copyright © 2020 Ali Sajadi. All rights reserved.
//

import UIKit
import CoreData

class TodosTableViewController: UITableViewController {

    //MARK: - Properties
    
    var resultsController: NSFetchedResultsController<Todo>!
    
    var request: NSFetchRequest<Todo> = {
        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        return request
    }()

    let coreDataStack = CoreDataStack()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SetupFetchedResults()
        fetchTodo()
    }
    
    //MARK: - Setup fetch request
    
//    func setupFetchRequest() {
//        let request: NSFetchRequest<Todo> = Todo.fetchRequest()
//        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
//    }
    
    
    //MARK: - Setup fetched Results Controller
    
    func SetupFetchedResults() {
        resultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: coreDataStack.context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        resultsController.delegate = self
    }
    
    //MARK: - Fetch Todo
    
    func fetchTodo() {
        do {
            try resultsController.performFetch()
        } catch {
            print("Error in fetching Todo: \(error)")
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return resultsController.sections?[section].objects?.count ?? 0
        return resultsController.sections?[section].numberOfObjects ?? 0

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)

        let todo = resultsController.object(at: indexPath)
        cell.textLabel?.text = todo.title

        return cell
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Deleting todo failed\(error)")
                completion(false)
            }
        }
        action.image = #imageLiteral(resourceName: "trash")
        action.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Check") { (action, view, completion) in
            
            let todo = self.resultsController.object(at: indexPath)
            self.resultsController.managedObjectContext.delete(todo)
            
            do {
                try self.resultsController.managedObjectContext.save()
                completion(true)
            } catch {
                print("Deleting todo failed\(error)")
                completion(false)
            }
        }
        action.image = #imageLiteral(resourceName: "check")
        action.backgroundColor = .green
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showAddNewTodo", sender: tableView.cellForRow(at: indexPath))
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let _ = sender as? UIBarButtonItem, let viewController = segue.destination as? AddNewTodoViewController {
            viewController.context = resultsController.managedObjectContext
        }
        
        if let cell = sender as? UITableViewCell, let viewController = segue.destination as? AddNewTodoViewController {
            viewController.context = resultsController.managedObjectContext
            if let indexPath = tableView.indexPath(for: cell) {
                let todo = resultsController.object(at: indexPath)
                viewController.todo = todo
            }
        }
    }
}

extension TodosTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) {
                let todo = resultsController.object(at: indexPath)
                cell.textLabel?.text = todo.title
            }
        default:
            break
        }
    }
}
