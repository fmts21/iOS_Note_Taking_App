//
//  Note.swift
//  PlainNotes
//
//  Created by Michael on 2016-02-09.
//  Copyright © 2016 Michael. All rights reserved.
//

import Foundation
import UIKit

var allNotes = [Note]()
var currentNoteIndex : Int = -1
var noteTable: UITableView?


var newNote = false

var databasePath = NSString()

class Note : NSObject {
    var date : String
    var note : String
    var lati : Double
    var long : Double
    var image: String
    var audio: String
  
    override init () {
        date = NSDate().description
        note = ""
        lati = 0
        long = 0
        image = ""
        audio = ""
        
    }
    
    class func saveNotes(noteIndex: Int) {

        let noteDB = FMDatabase(path: databasePath as String)
        
        if noteDB.open() {
            
            if !newNote {
                let updateSQL = "UPDATE NOTES SET DATE = '\(Note().date)', NOTE = '\(allNotes[noteIndex].note)', IMAGE = '\(allNotes[noteIndex].image)', AUDIO = '\(allNotes[noteIndex].audio)' WHERE DATE = '\(allNotes[noteIndex].date)'"
                let result = noteDB.executeUpdate(updateSQL, withArgumentsInArray: nil)
                
                if !result {
                    print("Error: \(noteDB.lastErrorMessage())")
                }
            } else {
                
                let insertSQL = "INSERT INTO NOTES (DATE, NOTE, LATITUDE, LONGITUDE, IMAGE, AUDIO) VALUES('\(Note().date)', '\(allNotes[noteIndex].note)', '\(allNotes[noteIndex].lati)', '\(allNotes[noteIndex].long)', '\(allNotes[noteIndex].image)', '\(allNotes[noteIndex].audio)')"
                let result = noteDB.executeUpdate(insertSQL, withArgumentsInArray: nil)
                newNote = false
                    if !result {
                        print("Error: \(noteDB.lastErrorMessage())")
                    }
            }
            
            noteDB.close()
            
        } else {
            print("Error: \(noteDB.lastErrorMessage())")
        } 
        
    }
    
    class func loadNotes() {
        allNotes.removeAll()
        let noteDB = FMDatabase(path: databasePath as String)
        
        if noteDB.open() {
            let selectSQL = "SELECT date, note, latitude, longitude, image, audio FROM notes ORDER BY date DESC"

            let results: FMResultSet? = noteDB.executeQuery(selectSQL, withArgumentsInArray: nil)
        
            while results!.next() {
                let note = Note()
                note.date = results!.stringForColumn("date")
                note.note = results!.stringForColumn("note")
                note.lati = results!.doubleForColumn("latitude")
                note.long = results!.doubleForColumn("longitude")
                note.image = results!.stringForColumn("image")
                note.audio = results!.stringForColumn("audio")
                allNotes.append(note)
            }
            
            noteDB.close()
            
        } else {
            print("Error: \(noteDB.lastErrorMessage())")
        }

    }
    
    class func deleteNotes(noteIndex: Int) {
        
        let noteDB = FMDatabase(path: databasePath as String)
        
        if noteDB.open() {
            let deleteSQL = "DELETE FROM NOTES WHERE DATE = '\(allNotes[noteIndex].date)'"
            
            let result = noteDB.executeUpdate(deleteSQL, withArgumentsInArray: nil)
            
            if !result {
                
                print("Error: \(noteDB.lastErrorMessage())")
                
            } else {
                
            }
            
            noteDB.close()
            
        } else {
            print("Error: \(noteDB.lastErrorMessage())")
        }
        
        
    }
    
}
