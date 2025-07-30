//
//  Task.swift
//

import UIKit

// The Task model
struct Task: Codable {

    // The task's title
    var title: String

    // An optional note
    var note: String?

    // The due date by which the task should be completed
    var dueDate: Date

    // Initialize a new task
    // `note` and `dueDate` properties have default values provided if none are passed into the init by the caller.
    init(title: String, note: String? = nil, dueDate: Date = Date()) {
        self.title = title
        self.note = note
        self.dueDate = dueDate
    }

    // A boolean to determine if the task has been completed. Defaults to `false`
    var isComplete: Bool = false {

        // Any time a task is completed, update the completedDate accordingly.
        didSet {
            if isComplete {
                // The task has just been marked complete, set the completed date to "right now".
                completedDate = Date()
            } else {
                completedDate = nil
            }
        }
    }

    // The date the task was completed
    // private(set) means this property can only be set from within this struct, but read from anywhere (i.e. public)
    private(set) var completedDate: Date?

    // The date the task was created
    // This property is set as the current date whenever the task is initially created.
    private(set) var createdDate: Date = Date()

    // An id (Universal Unique Identifier) used to identify a task.
    private(set) var id: String = UUID().uuidString
}

extension Task {

    // A static key to use for saving and retrieving tasks from UserDefaults
    private static let tasksKey = "tasks"

    // Given an array of tasks, encodes them to data and saves to UserDefaults.
    static func save(_ tasks: [Task]) {
        let encoder = JSONEncoder()
        do {
            let encodedTasks = try encoder.encode(tasks)
            UserDefaults.standard.set(encodedTasks, forKey: tasksKey)
        } catch {
            print("Error encoding tasks: \(error.localizedDescription)")
        }
    }

    // Retrieve an array of saved tasks from UserDefaults.
    static func getTasks() -> [Task] {
        guard let savedTasksData = UserDefaults.standard.data(forKey: tasksKey) else {
            return []
        }
        let decoder = JSONDecoder()
        do {
            let decodedTasks = try decoder.decode([Task].self, from: savedTasksData)
            return decodedTasks
        } catch {
            print("Error decoding tasks: \(error.localizedDescription)")
            return []
        }
    }

    // Add a new task or update an existing task with the current task.
    func save() {
        // 1. Get the array of saved tasks
        var tasks = Task.getTasks()

        // 2. Check if the current task already exists
        if let index = tasks.firstIndex(where: { $0.id == self.id }) {
            // If it exists, remove the old one and insert the updated one
            tasks.remove(at: index)
            tasks.insert(self, at: index)
        } else {
            // Otherwise, append the new task
            tasks.append(self)
        }

        // 4. Save the updated tasks array
        Task.save(tasks)
    }
}
