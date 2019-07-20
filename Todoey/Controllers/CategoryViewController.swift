//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Erris Canamusa on 7/18/19.
//  Copyright © 2019 Erris Canamusa. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {

    let realm = try! Realm() //init access point to realm
    
    var categories : Results<Category>? // change array to a collection of results (category objects)           // optional to be safe
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadCategories() // load up all the categories when app starts
        
        tableView.separatorStyle = .none
    
    }
    
    
    //MARK: - Add new Categories

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.backgroundColor = UIColor.randomFlat.hexValue()
            self.save(category: newCategory)
        
        }
        
        alert.addAction(action)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Add a new category"
            textField = alertTextField
            
        }
        
        present(alert, animated: true, completion: nil)
        
       
    }

    //MARK: - TableView DataSource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1 // nil coalescing operator
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) // triggers the cell
      
        if let category = categories?[indexPath.row] {
        
            cell.textLabel?.text = category.name
        
            guard let categoryColor = UIColor(hexString: category.backgroundColor) else {fatalError()}
            cell.backgroundColor = categoryColor
        
            cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
        }
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToItems", sender: self) //when row's clicked segues to items of that category
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController // new instance of the destination ViewController
        
        if let indexPath = tableView.indexPathForSelectedRow { // we don't have access to the current row, hence we create a new indexPath that uses indexPathForSelectedRow
            destinationVC.selectedCategory = categories?[indexPath.row] // we set the destination VC's selected category to the category that triggered the segue
        }
    }
    //MARK: - Data Manipulation Methods
    
    
    func save(category: Category) {
        
        do {
            try realm.write {
                realm.add(category) // add new category to realm database
            }
        } catch {
            print("There was an error saving in the database, \(error)")
            }
        
        tableView.reloadData()
        }
    
    
    func loadCategories() {
        
        categories = realm.objects(Category.self) // set property categories to look in realm to fetch the category data type
        

        tableView.reloadData() // reload the tableView with new data
        
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let categoryForDeletion = self.categories?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(categoryForDeletion)
                }
            } catch {
                print("Error deleting category, \(error)")
            }
        }
    }
}


