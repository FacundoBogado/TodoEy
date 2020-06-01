//
//  ViewController.swift
//  Todoey
//
//  Created by Facundo Bogado on 21/04/2020.
//  Copyright © 2020 Facundo Bogado. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    var todoItems: Results<Item>?
    var selectedCategory : Category?{
        didSet{
            loadData()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        title = selectedCategory!.name

        
        if let hexColor = selectedCategory?.colour{
            
            guard let navbar = navigationController?.navigationBar else{fatalError("Navigation controller does not exist.")}
            
            if let selectedColor = UIColor(hexString: hexColor) {
                navbar.barTintColor = selectedColor
                navigationController?.navigationBar.tintColor = ContrastColorOf(selectedColor, returnFlat: true)
                navbar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(selectedColor, returnFlat: true)]
                searchBar.barTintColor = selectedColor
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) 
        if let item = todoItems?[indexPath.row]{
            cell.textLabel?.text =  item.title
            cell.accessoryType = item.isChecked ? .checkmark : .none
            
            if let colour = UIColor( hexString: selectedCategory!.colour)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(todoItems!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            
        } else {
            cell.textLabel?.text =  "No items added."
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row]{
            do{
                try realm.write{
                    item.isChecked = !item.isChecked
                }
            } catch {
                print("Error updating data \(error)")
            }
        }
        
        tableView.reloadData()
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            if !(textField.text ?? "").isEmpty {
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error saving new items, \(error)")
                    }
                }
                self.tableView.reloadData()
            }
        }
        
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func loadData(){
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    override func updateModel(_ indexPath: IndexPath) {
           if let selectedItem = self.todoItems?[indexPath.row]{
               do {
                   try self.realm.write{
                       self.realm.delete(selectedItem)
                   }
               } catch {
                   print("Error deleting Item \(error)")
               }
           }
       }
}

extension TodoListViewController: UISearchBarDelegate{
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0 {
                loadData()
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
            } else {
                todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
                tableView.reloadData()
            }
        }
}

