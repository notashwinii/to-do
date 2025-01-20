local json = require("cjson") -- Require the lua-cjson library
local tasksFile = "tasks.json"

-- Tasks table
local tasks = { pending = {}, completed = {} }

-- Load tasks from file
local function loadTasks()
    local file = io.open(tasksFile, "r")
    if file then
        local content = file:read("*a")
        tasks = json.decode(content)
        file:close()
    end
end

-- Save tasks to file
local function saveTasks()
    local file = io.open(tasksFile, "w")
    if file then
        file:write(json.encode(tasks))
        file:close()
    end
end

-- Display menu options
local function displayMenu()
    print("\n--- To-Do List ---")
    print("1. Add a Task")
    print("2. View Pending Tasks")
    print("3. View Completed Tasks")
    print("4. Mark a Task as Completed")
    print("5. Remove a Task")
    print("6. Exit")
end

-- Add a task
local function addTask()
    print("Enter the task to add:")
    local task = io.read()
    if task and task ~= "" then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")
        table.insert(tasks.pending, { description = task, added_at = timestamp })
        print("Task added: " .. task)
        saveTasks()
    else
        print("Task cannot be empty!")
    end
end

-- View pending tasks
local function viewTasks(taskType)
    local list = tasks[taskType]
    if #list == 0 then
        print("No " .. taskType .. " tasks found!")
    else
        print("\n--- " .. (taskType == "pending" and "Pending" or "Completed") .. " Tasks ---")
        for i, task in ipairs(list) do
            print(i .. ". " .. task.description .. " (Added: " .. task.added_at .. ")")
            if taskType == "completed" and task.completed_at then
                print("   Completed: " .. task.completed_at)
            end
        end
    end
end

-- Mark a task as completed
local function markTaskAsCompleted()
    if #tasks.pending == 0 then
        print("No pending tasks to mark as completed!")
        return
    end
    viewTasks("pending")
    print("Enter the number of the task to mark as completed:")
    local taskNum = tonumber(io.read())
    if taskNum and tasks.pending[taskNum] then
        local task = table.remove(tasks.pending, taskNum)
        task.completed_at = os.date("%Y-%m-%d %H:%M:%S")
        table.insert(tasks.completed, task)
        print("Marked task as completed: " .. task.description)
        saveTasks()
    else
        print("Invalid task number!")
    end
end

-- Remove a task
local function removeTask()
    viewTasks("pending")
    print("Enter the number of the task to remove:")
    local taskNum = tonumber(io.read())
    if taskNum and tasks.pending[taskNum] then
        local removed = table.remove(tasks.pending, taskNum)
        print("Removed task: " .. removed.description)
        saveTasks()
    else
        print("Invalid task number!")
    end
end

-- Main program loop
loadTasks()
while true do
    displayMenu()
    print("Choose an option (1-6):")
    local choice = tonumber(io.read())
    if choice == 1 then
        addTask()
    elseif choice == 2 then
        viewTasks("pending")
    elseif choice == 3 then
        viewTasks("completed")
    elseif choice == 4 then
        markTaskAsCompleted()
    elseif choice == 5 then
        removeTask()
    elseif choice == 6 then
        print("Exiting... Goodbye!")
        break
    else
        print("Invalid choice! Please enter a number between 1 and 6.")
    end
end
