//
//  TodoDetailViewController.swift
//  ToDoDemo
//
//  Created by panxinyu on 2017-28-06.
//  Copyright © 2017年 panxinyu. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TodoDetailViewController: UITableViewController {

    var todo: TodoItem!

    fileprivate var todoCollage: UIImage?
    fileprivate let images = Variable<[UIImage]>([])

    fileprivate var todoSub = PublishSubject<TodoItem>()
    var todoOb: Observable<TodoItem> {
        return todoSub.asObserver()
    }

    var bag = DisposeBag()

    @IBOutlet weak var finishedSwitch: UISwitch!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var addTodoTextField: UITextField!
    @IBOutlet weak var memoCollageBtn: UIButton!

    @IBAction func done(_ sender: UIBarButtonItem) {
        todo.name = addTodoTextField.text ?? ""
        todo.isFinished = finishedSwitch.isOn

        todoSub.onNext(todo)
        todoSub.onCompleted()
        dismiss()
    }

    @IBAction func dismiss(_ sender: UIBarButtonItem) {
        dismiss()
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setMemoSectionHederText()

        images.asObservable().subscribe(onNext: {
            [weak self] images in
            guard let `self` = self else {
                return
            }

            guard !images.isEmpty else {
                self.resetMemoBtn()
                return
            }

            self.todoCollage = UIImage.collage(images: images,
                                               in: self.memoCollageBtn.frame.size)
            self.setMemoBtn(bkImage: self.todoCollage ?? UIImage())
        }).addDisposableTo(bag)

        if todo == nil {
            todo = TodoItem()
            todo.name = ""
        }
        addTodoTextField.text = todo.name
        finishedSwitch.isOn = todo.isFinished


        let textOb = addTodoTextField.rx.text.orEmpty.map { [weak self] text -> Bool in
            return text != self?.todo.name
        }

        let switchOb = finishedSwitch.rx.isOn.map { [weak self] isOn -> Bool in
            return isOn != self?.todo.isFinished
        }


        _ = Observable.combineLatest([textOb, switchOb]).asObservable().map {
            $0.reduce(false) { $0 || $1 }
            }.subscribe(
                onNext: { [weak self] changed in
                    self?.doneButton.isEnabled = changed
                }
        )

    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        addTodoTextField.resignFirstResponder()
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let photoCollectionViewController =
            segue.destination as! PhotoCollectionViewController
        images.value.removeAll()
        resetMemoBtn()

        let selectedPhotos = photoCollectionViewController.selectedPhotos.share()

        _ = selectedPhotos.scan([]) {
            (photos: [UIImage], newPhoto: UIImage) in
            var newPhotos = photos

            if let index = newPhotos.index(where: {
                UIImage.isEqual(lhs: newPhoto, rhs: $0)
            }) {
                newPhotos.remove(at: index)
            }
            else {
                newPhotos.append(newPhoto)
            }

            return newPhotos
            }.subscribe(onNext: { (photos: [UIImage]) in
                self.images.value = photos
            }, onDisposed: {
                print("Finished choose photo memos.")
            })

        _ = selectedPhotos.ignoreElements()
            .subscribe(onCompleted: { _ in
                self.setMemoSectionHederText()
            })
    }

}

extension TodoDetailViewController {
    func hideKeyboard() {
        if addTodoTextField.isFirstResponder {
            addTodoTextField.resignFirstResponder()
        }
    }

    func dismiss() {
        hideKeyboard()
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
}

extension TodoDetailViewController {
    fileprivate func getDocumentsDir() -> URL {
        return FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask)[0]
    }

    fileprivate func resetMemoBtn() {
        memoCollageBtn.setBackgroundImage(nil, for: .normal)
        memoCollageBtn.setTitle("Add image", for: .normal)
    }

    fileprivate func setMemoBtn(bkImage: UIImage) {
        memoCollageBtn.setBackgroundImage(bkImage, for: .normal)
        memoCollageBtn.setTitle("", for: .normal);
    }

    fileprivate func savePictureMemos() -> String {
        if let todoCollage = todoCollage,
            let data = UIImagePNGRepresentation(todoCollage) {
            let path = getDocumentsDir()
            let filename = self.addTodoTextField.text! + UUID().uuidString + ".png"
            let memoImageUrl = path.appendingPathComponent(filename)

            try? data.write(to: memoImageUrl)

            return filename
        }

        return self.todo.pictureMemoFilename
    }
}

extension TodoDetailViewController {
    override func tableView(_ tableView: UITableView,
                            willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    func setMemoSectionHederText() {
        guard !images.value.isEmpty,
            let headerView = self.tableView.headerView(forSection: 2) else { return }

        headerView.textLabel?.text = "\(images.value.count) MEMOS"
    }
}

