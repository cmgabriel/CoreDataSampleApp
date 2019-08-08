//
//  ViewController.swift
//  CoreDataSampleApp
//
//  Created by CMGabriel on 8/8/19.
//  Copyright © 2019 AkhileshSharma. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var people: [NSManagedObject] = []
    var names:[String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.initializeTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Retrieves the information from the coredata saved entity
        self.getInformation()
    }

    @IBAction func addNewItem(_ sender: Any) {
        
        let alertViewController = UIAlertController(title: "Add New Item", message: "Add a new item to list", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self] action in
            guard let textField = alertViewController.textFields?.first,
                let nameToSave = textField.text else {
                    print("Cannot get the value from the textField")
                    return
            }
            self.save(name: nameToSave);
            self.tableView.reloadData()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("Add operation cancelled")
        }
        
        alertViewController.addTextField()
        
        alertViewController.addAction(saveAction)
        alertViewController.addAction(cancelAction)
        
        present(alertViewController, animated: true) {
            print("Add new item alert presented")
        }
        
    }
    
    private func save(name:String){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)!
        
        let person = NSManagedObject(entity: entity, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        
        do {
            try managedContext.save()
            people.append(person)
        } catch let error as NSError {
            print("Could not save \(error),\(error.userInfo)");
        }
        
    }
    
    private func getInformation(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")
        
        do {
            people = try managedContext.fetch(fetchRequest)
        } catch let error as NSError{
            print("Could retireve the data from local storage, \(error),\(error.userInfo)")
        }
    }
    
    
    private func initializeTableView(){
        self.title = "Sample App"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "cell")
        tableView.dataSource = self
    }
}

extension ViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.people.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let person = people[indexPath.row]
        
        cell.textLabel?.text = person.value(forKeyPath: "name") as? String
        
        return cell
    }
}

