using .WebFramework

mutable struct Todo
    id::Int
    text::String
    completed::Bool
end

todos = Todo[]
next_id = 1

function add_todo(text::String)
    global next_id
    push!(todos, Todo(next_id, text, false))
    next_id += 1
end

function delete_todo(id::Int)
    global todos
    todos = filter(todo -> todo.id != id, todos)
end

function toggle_todo(id::Int)
    for todo in todos
        if todo.id == id
            todo.completed = !todo.completed
            break
        end
    end
end

function render_todo_list()
    todo_items = ""
    for todo in todos
        checkbox = WebFramework.input(type="checkbox", 
            onclick="window.location.href='/toggle/$(todo.id)'",
            checked=todo.completed)
        todo_text = WebFramework.span(todo.text, class=todo.completed ? "completed" : "")
        delete_btn = WebFramework.a("&times;", href="/delete/$(todo.id)", 
            style="color: #ff4444; text-decoration: none; margin-left: auto; font-size: 24px;")
        todo_items *= WebFramework.div(checkbox * todo_text * delete_btn, class="todo-item")
    end

    content = WebFramework.div(
        WebFramework.h1("Dark Todo List") *
        WebFramework.div(
            WebFramework.form(
                WebFramework.input(type="text", name="todo", placeholder="Enter a new todo", autofocus="true") *
                WebFramework.button("Add", type="submit"),
                action="/add", method="post",
                class="form-container"
            ) *
            WebFramework.div(todo_items, id="todo-list"),
            class="todo-container"
        )
    )
    
    WebFramework.response(content)
end

function handle_request(req)
    if req.method == "GET" && req.target == "/"
        return render_todo_list()
    elseif startswith(req.target, "/toggle/")
        id = parse(Int, split(req.target, "/")[3])
        toggle_todo(id)
        return HTTP.Response(302, ["Location" => "/"])
    elseif startswith(req.target, "/delete/")
        id = parse(Int, split(req.target, "/")[3])
        delete_todo(id)
        return HTTP.Response(302, ["Location" => "/"])
    elseif req.method == "POST" && req.target == "/add"
        form_data = Inputs.parse_form_data(req.body)
        if haskey(form_data, "todo") && !isempty(form_data["todo"])
            add_todo(form_data["todo"])
        end
        return HTTP.Response(302, ["Location" => "/"])
    else
        return HTTP.Response(404, "Not Found")
    end
end

HTTP.serve(handle_request, "127.0.0.1", 8080) 