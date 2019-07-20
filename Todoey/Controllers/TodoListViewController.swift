//
//  ViewController.swift
//  Todoey
//
//  Created by Erris Canamusa on 7/15/19.
//  Copyright © 2019 Erris Canamusa. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    
    var todoItems: Results<Item>? //collection of results that are item objects
    let realm = try! Realm()
    @IBOutlet weak var searchBar: UISearchBar!
    
    var selectedCategory : Category? { // once selectedCategory is given a value we use didSet to loadItems()
        didSet{
            loadItems()
            
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80.0
        tableView.separatorStyle = .none
        
        
        
    }
    
//MARK - Tableview Datasource Methods
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory?.name
        
        guard let colorHex  = selectedCategory?.backgroundColor else { fatalError() }
        
        updateNavBar(withHexCode: colorHex)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        updateNavBar(withHexCode: "1D9BF6")
    }
    
    //MARK: - Nav Bar Setup Methods
    
    func updateNavBar (withHexCode colorHexCode : String) {
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigation controller doesn't exist")}
        
        guard let navBarColor = UIColor(hexString: colorHexCode) else { fatalError() }
        
        navBar.barTintColor = navBarColor
        
        navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
        
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
        
        
        searchBar.barTintColor = navBarColor
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1 //specifies the number of cells as we have cells -- if no cells we return 1 cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
        
            
            cell.textLabel?.text = item.title // we give the cell the item's title
            
           // let actualColor = HexColor((selectedCategory?.backgroundColor)!)
            
            if let color = UIColor(hexString: selectedCategory!.backgroundColor)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
            
            cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            cell.accessoryType = item.done == true ? .checkmark : .none // using the ternary operator
       } else {
            cell.textLabel?.text = "No items were added"
        }
    return cell
    
    }
    
    
    

    // MARK - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            do {
                try realm.write {
                    
                    item.done = !item.done
                    }
                } catch {
                    print("error while updating, \(error)")
                }
        }
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
}

    
    @IBAction func buttonPressed(_ sender: UIBarButtonItem) {
    
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item button on our UIAlert
            
            if let currentCategory = self.selectedCategory { //we check if selectedCategory is nil -- remember it's an optional
                
                do {
                    try self.realm.write { // write on realm and update the attributes
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem) //append the new Item to the end of the
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            
            self.tableView.reloadData()
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
            
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK - Model Manipulation Methods

    func loadItems () {
        
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true) // todoItems (which holds items) is populated
        
        tableView.reloadData()
    }
    
   override func updateModel (at indexPath: IndexPath) {
        if let CurrentItem = self.todoItems?[indexPath.row] {
            do{
                try self.realm.write {
                    self.realm.delete(CurrentItem)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
}

//MARK: - Search bar methods

extension TodoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        // filters the data by dissmising special characters and case sensitivity and sorts it ascendingly by date
        
        tableView.reloadData() //sends it back to delegate methods
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()

            DispatchQueue.main.async {
                 searchBar.resignFirstResponder()
            }

        }
    }
}
