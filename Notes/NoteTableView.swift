//
//  NoteTableView.swift
//  Notes
//
//  Created by Leonid on 26.09.2021.
//

import UIKit
import CoreData

class NoteTableView: UITableViewController {
    
    public var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = l10n("NOTE_TABLE_VIEW_TITLE")

        if let firstOpen = UserDefaults.standard.object(forKey: "FirstOpen") as? Date {
            print("The app was first opened on\(firstOpen)")
        } else {
            UserDefaults.standard.setValue(Date(), forKey: "FirstOpen")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Note", in: context)
                let newNote = Note(entity: entity!, insertInto: context)
                newNote.id = noteList.count as NSNumber
                newNote.title = l10n("FIRST_LOAD_NEW_NOTE_TITLE")
                newNote.desc = l10n("FIRST_LOAD_NEW_NOTE_DESC")
                do {
                    try context.save()
                } catch {
                    print("Context save error!")
                }
        }

        if(self.firstLoad) {
            self.firstLoad = false
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let note = result as! Note
                    noteList.append(note)
                }
            } catch {
                print("Fetch error!")
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    func nonDeletedNotes() -> [Note] {
        var noDeleteNoteList = [Note]()
        for note in noteList {
            if(note.deletedDate == nil) {
                noDeleteNoteList.append(note)
            }
        }
        return noDeleteNoteList
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "editNote") {
            let indexPath = tableView.indexPathForSelectedRow!
            let noteDetail = segue.destination as? NoteViewController
            let selectedNote: Note!
            selectedNote = nonDeletedNotes()[indexPath.row]
            noteDetail!.selectedNote = selectedNote
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension NoteTableView {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoteCellView
        let note: Note!
        note = nonDeletedNotes()[indexPath.row]
        cell.titleLabel.text = note.title
        cell.descriptionLabel.text = note.desc
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nonDeletedNotes().count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "editNote", sender: self)
    }
}
