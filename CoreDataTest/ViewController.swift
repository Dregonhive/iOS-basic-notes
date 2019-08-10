//
//  ViewController.swift
//  CoreDataTest
//
//  Created by Meave on 09/08/2019.
//  Copyright © 2019 Dregon Corp. All rights reserved.
//

import UIKit
import CoreData

var names: [NSManagedObject] = []

class ViewController: UIViewController {

    
    @IBOutlet weak var TableView: UITableView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        title = "List of Notes"
        TableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        names = dataFetchAll(entityName: "Notes")
    }

    @IBAction func addName(_ sender: Any)
    {
        let alertBox = UIAlertController(title: "Add new note", message: "Enter a title for your new note", preferredStyle: .alert)
        
        alertBox.addTextField()
        
        alertBox.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel))
        let saveAction = UIAlertAction(title: "Add", style: UIAlertAction.Style.default) {
            [unowned self] action in
            guard let textField = alertBox.textFields?.first,
            let noteTitle = textField.text
            else
            {
                return
            }
            names.append(dataSaveInstance(entityName: "Notes", keyValues: ["title":noteTitle]))
            self.TableView.reloadData()
            self.dismiss(animated: true)
        }
        alertBox.addAction(saveAction)
        
        present(alertBox, animated: true)
    }
    
    
    
}

extension ViewController: UITableViewDataSource
{
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        //cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let instance = names[indexPath.row]
        cell.textLabel?.text = (instance.value(forKey: "title") as! String)
        if (instance.value(forKey: "body") == nil)
        {
            cell.detailTextLabel?.text = "Empty Note" //think of replacing it by date and put "Empty Note" in textLabel
        }
        else
        {
            cell.detailTextLabel?.text = (instance.value(forKey: "body") as! String)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    
}

func dataSaveInstance(entityName: String, keyValues: [String: Any?]) -> NSManagedObject
{
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    let entity = NSEntityDescription.entity(forEntityName: entityName, in: context)
    let instance = NSManagedObject.init(entity: entity!, insertInto: context)
    
    keyValues.forEach {
        key, value in
        instance.setValue(value, forKey: key)
    }
    
    do
    {
        try context.save()
    }
    catch let error as NSError
    {
        print("Coredata saving error \n \(error) \n \(error.userInfo)")
    }
    return instance
}

func dataFetchAll(entityName: String) -> [NSManagedObject]
{
    var result: [NSManagedObject] = []
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
    
    do
    {
        result = try context.fetch(request) as! [NSManagedObject]
    }
    catch let error as NSError
    {
        print("Coredata fetching all error \n \(error) \n \(error.userInfo)")
    }
    return result
}

class SubtitleTableViewCell: UITableViewCell
{
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
