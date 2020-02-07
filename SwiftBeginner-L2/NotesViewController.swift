//
//  ViewController.swift
//  SwiftBeginner-L2
//
//  Created by Andrey Stecenko on 7/20/19.
//  Copyright © 2019 Andrii Stetsenko. All rights reserved.
//

import UIKit

class NotesViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var noNotesLabel: UILabel!
    

    // MARK: - Properties

    var notes = [Note]()
    var loggedIn = false
    
    // вставляем из "AppDelegate" "dependency injection" (внедрение зависимости)
    var coreDataManager: CoreDataManager!
    
    let dataController = DataController()


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(coreDataManager.mainManagedObjectContext)

        // подписываемся на делегата
        dataController.delegate = self
        
        dataController.coreDataManager = coreDataManager
        dataController.getNotes()

         // а функцию "getNotes()" будем вызывать когда мы уже залогинелись
        if UserDefaults.standard.value(forKey: "UserIdentifier") != nil {
            dataController.getNotes()
        }

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "UserLoggedIn"), object: nil, queue: nil) { (notification) in
            if let success: Bool = notification.userInfo?["success"] as! Bool? {
                self.loggedIn = success
                print("notification received")
            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        if loggedIn == false && (UserDefaults.standard.value(forKey: "UserIdentifier") != nil) {
            showLogginViewController()
        }
    }


    // MARK: - IBActions

    @IBAction func addButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "EditNoteSegue", sender: nil)
    }


    // MARK: - Add Functions

    func deleteNoteAt(index: Int) {
        notes.remove(at: index)
    }

    func showLogginViewController() {
        let loginStoryboard = UIStoryboard(name: "Login", bundle: .main)

        if let loginVC = loginStoryboard.instantiateInitialViewController() as? LoginViewController {
            loginVC.delegate = self
            present(loginVC, animated: true, completion: nil)
        }
    }


    // MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        if let addVC = segue.destination as? AddNoteViewController {
//            if let noteIndex = sender as? Int {
//                addVC.note = notes[noteIndex]
//            }
//            addVC.dataController = self.dataController
//        }
//    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addVC = segue.destination as? AddNoteViewController {
            if segue.identifier == "EditNoteSegue" {
                addVC.dataController = self.dataController

                if let index = sender as? Int {
                    addVC.note = notes[index]
                }
                
            }
        }
    }

}


// MARK: - Extensions

extension NotesViewController: UITableViewDataSource {

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notesCount = notes.count

        if notesCount > 0 {
            noNotesLabel.isHidden = true
        } else {
            noNotesLabel.isHidden = false
        }

        return notesCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteCell")! as UITableViewCell

        let note = notes[indexPath.row]
        cell.textLabel?.text = note.text

        return cell
    }

}

extension NotesViewController: UITableViewDelegate {

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dataController.modify(note: notes[indexPath.row], task: .delete)

            //deleteNoteAt(index: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "EditNoteSegue", sender: indexPath.row)
    }

    // сделаем так что после появления ячейки внизу не будет лишних видимых ячеек (сетки). Добавим два метода Футера.
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10.0
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

}

extension NotesViewController: LoginViewControllerDelegate {

    // MARK: - LoginViewControllerDelegate

    func didLoggedIn(identifier: String?, success: Bool) {
        loggedIn = success
        UserDefaults.standard.set(identifier, forKey: "UserIdentifier")
        
        if  UserDefaults.standard.value(forKey: "UserIdentifier") != nil {
            dataController.getNotes()
        }
    }

}

extension NotesViewController: DataControllerDelegate {

    // MARK: - DataControllerDelegate

    func dataSourseChanged(dataSourse: [Note]?, error: Error?) {
        
        if let notes = dataSourse {
            self.notes = notes.sorted(by: {$0.lastModified > $1.lastModified})

            // перезагрузку таблицы нужно обязательно вызывать из главного потока
            DispatchQueue.main.async {
                self.notesTable.reloadData()
            }
        }
    }

}
