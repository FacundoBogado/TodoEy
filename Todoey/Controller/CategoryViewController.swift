//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Facundo Bogado on 27/04/2020.
//  Copyright © 2020 Facundo Bogado. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    var categories: Results<Category>?
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navbar = navigationController?.navigationBar else{ fatalError("Navigation controller does not exist.") }
        
        navbar.barTintColor = UIColor(hexString: "#00ADB5")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let category = categories?[indexPath.row] {
            
            guard let selectedColor = UIColor(hexString: category.colour) else {fatalError()}
                       
            cell.textLabel?.text = categories?[indexPath.row].name ?? "No Categories Added yet"
            cell.backgroundColor = selectedColor
            cell.textLabel?.textColor = ContrastColorOf(selectedColor, returnFlat: true)
        }
       
        
        return cell 
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "GoToItems", sender: self)
    }
    
    
    
    @IBAction func AddButtonPresed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newCategory = Category()
            newCategory.name = textField.text!
            newCategory.colour = UIColor.randomFlat().hexValue()
            self.saveData(newCategory)
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add new Category"
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destination.selectedCategory = categories?[indexPath.row]
        }
    }
    
    
    func saveData(_ category: Category){
        do {
            try realm.write{
                realm.add(category)
            }
        } catch {
            print("Error saving data \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadData(){
        
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(_ indexPath: IndexPath) {
        if let selectedCategory = self.categories?[indexPath.row]{
            do {
                try self.realm.write{
                    self.realm.delete(selectedCategory)
                }
            } catch {
                print("Error deleting category \(error)")
            }
        }
    }
}
