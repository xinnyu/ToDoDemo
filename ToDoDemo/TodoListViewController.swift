//
//  ViewController.swift
//  TodoDemo
//
//  Created by panxinyu on 24/05/2017.
//  Copyright © 2017 panxinyu. All rights reserved.
//

import UIKit
import RxSwift

class TodoListViewController: UIViewController {
    var todoItems = Variable<[TodoItem]> ([])
    let bag = DisposeBag()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var clearTodoBtn: UIButton!
    @IBOutlet weak var addTodo: UIBarButtonItem!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadTodoItems()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self

        todoItems.asObservable().subscribe(onNext: {
            [weak self] todos in
            self?.updateUI(todos: todos)
        }).addDisposableTo(bag)
    }

    func updateUI(todos: [TodoItem]) {
        clearTodoBtn.isEnabled = !todos.isEmpty
        self.title = todos.isEmpty ? "Todo" : "Todo: \(todos.count)"
        addTodo.isEnabled = todos.filter { !$0.isFinished }.count < 5
        tableView.reloadData()
    }

    
    @IBAction func saveTodoList(_ sender: Any) {
        saveTodoItems()
    }
    
    @IBAction func clearTodoList(_ sender: Any) {
        todoItems.value.removeAll()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let naviController = segue.destination as! UINavigationController
        var todoDetailController: TodoDetailViewController!

        todoDetailController = naviController.topViewController as! TodoDetailViewController

        if segue.identifier == "add todo" {
            todoDetailController.title = "Add Todo"

            _ = todoDetailController.todoOb.subscribe(
                onNext: {
                    [weak self] newTodo in
                    self?.todoItems.value.append(newTodo)
                },
                onDisposed: {
                    print("Finish adding a new todo.")
            }
            )
        }
        else if segue.identifier == "show todo detail" {
            todoDetailController.title = "Edit todo"

            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                todoDetailController.todo = todoItems.value[indexPath.row]

                _ = todoDetailController.todoOb.subscribe(
                    onNext: { [weak self] todo in
                        self?.todoItems.value[indexPath.row] = todo
                    },
                    onDisposed: {
                        print("Finish editing a todo.")
                })
            }
        }

    }
}
