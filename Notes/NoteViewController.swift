//
//  NoteViewController.swift
//  Notes
//
//  Created by Leonid on 25.09.2021.
//

import UIKit
import CoreData

var noteList = [Note]()

class NoteViewController: UIViewController {
    
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    @IBOutlet weak var saveButton: UIButton?
    @IBOutlet weak var deleteButton: UIButton?
    
    var selectedNote: Note? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = l10n("NOTE_VIEW_CONTROLLER_TITLE")
        self.saveButton?.setTitle(l10n("NOTE_VIEW_CONTROLLER_SAVE_BUTTON"), for: .normal)
        self.deleteButton?.tintColor = UIColor.red
        if(selectedNote != nil) {
            self.noteTitle.text = selectedNote?.title
            self.noteTextView.text = selectedNote?.desc
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        if(selectedNote == nil && noteTitle.text != "" && noteTextView.text != "") {
            let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
            let newNote = Note(entity: entity!, insertInto: context)
            newNote.id = noteList.count as NSNumber
            newNote.title = noteTitle.text
            newNote.desc = noteTextView.text
            do {
                try context.save()
                noteList.append(newNote)
                navigationController?.popViewController(animated: true)
            } catch {
                print("Context save error!")
            }
        }
        else {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    if(note == selectedNote) {
                        note.title = noteTitle.text
                        note.desc = noteTextView.text
                        try context.save()
                        navigationController?.popViewController(animated: true)
                    }
                }
            } catch {
                print("Fetch error!")
            }
        }
    }
    
    @IBAction func deleteNote(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        do {
            let results: NSArray = try context.fetch(request) as NSArray
            for result in results {
                let note = result as! Note
                if(note == selectedNote) {
                    note.deletedDate = Date()
                    try context.save()
                    navigationController?.popViewController(animated: true)
                }
            }
        } catch {
            print("Fetch error!")
        }
    }
}
