//
//  MasterViewController.swift
//  PlainNotes
//
//  Created by Michael on 2016-02-09.
//  Copyright © 2016 Michael. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [AnyObject]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        noteTable = self.tableView
        
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.leftBarButtonItem = self.editButtonItem()

        let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        self.navigationItem.rightBarButtonItem = addButton
        if let split = self.splitViewController {
            let controllers = split.viewControllers
            self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
     

        let filemgr = NSFileManager.defaultManager()
        let dirPath = filemgr.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        
        databasePath = dirPath[0].URLByAppendingPathComponent("notes.db").path!
     
        if !filemgr.fileExistsAtPath(databasePath as String) {
            let noteDB = FMDatabase(path: databasePath as String)
            
            if noteDB == nil {
                print("Error: \(noteDB.lastErrorMessage())")
            }
            
            if noteDB.open() {
                let sqlStatement = "CREATE TABLE IF NOT EXISTS NOTES (ID INTEGER PRIMARY KEY AUTOINCREMENT, DATE TEXT, NOTE TEXT, LATITUDE REAL, LONGITUDE REAL, IMAGE TEXT, AUDIO TEXT)"
                
                if !noteDB.executeStatements(sqlStatement) {
                    print("Error: \(noteDB.lastErrorMessage())")
                    noteDB.close()
                }
            } else {
                print("Error: \(noteDB.lastErrorMessage())")
            }
        } else {
            Note.loadNotes()
        }
    }

    override func viewWillAppear(animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.collapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        allNotes.insert(Note(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        self.performSegueWithIdentifier("showDetail", sender: self)
        newNote = true
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {

                currentNoteIndex = indexPath.row
                
                let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                controller.navigationItem.leftItemsSupplementBackButton = true
            } else {
                currentNoteIndex = 0
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allNotes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        let object = allNotes[indexPath.row]
        cell.textLabel!.text = object.date
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            Note.deleteNotes(indexPath.row)
            allNotes.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            noteTable?.reloadData()
            Note.loadNotes()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

