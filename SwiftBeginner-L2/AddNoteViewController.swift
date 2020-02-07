//
//  AddNoteViewController.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 7/29/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import UIKit

class AddNoteViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var noteText: UITextView!


    // MARK: - Properties

    public var note: Note?
    public var dataController: DataController!


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // если у нас заметка присутствует то
        if let note = self.note {
            // то текст в Текст вью приравниваем к тексту в нашей заметке
            noteText.text = note.text
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        
        if noteText.text.count > 0 {
            let taskNote: NoteModificationTask
            var currentNote: Note

            // если у нас заметка существует (НЕ nil)
            if let note = self.note {
                currentNote = Note(text: noteText.text, identifier: note.identifier, userID: note.userID)
                taskNote = .edit
            } else {
                currentNote = Note(text: noteText.text, identifier: UUID().uuidString, userID: "")
                taskNote = .create
            }

            // создаем ячейку
            dataController.modify(note: currentNote, task: taskNote)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
