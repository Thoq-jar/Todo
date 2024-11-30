package dev.thoq

import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import io.ktor.server.html.*
import kotlinx.html.*
import io.ktor.server.request.receiveParameters

data class TodoItem(
    val id: Int,
    var text: String,
    var completed: Boolean = false
)

val todoList = mutableListOf<TodoItem>()

fun main() {
    embeddedServer(Netty, port = 8080) {
        routing {
            get("/") {
                call.respondHtml {
                    head {
                        title("Kotlin Todo List")
                        style {
                            +"""
                                body {
                                    font-family: Arial, sans-serif;
                                    max-width: 800px;
                                    margin: 0 auto;
                                    padding: 20px;
                                    background-color: #f5f5f5;
                                }
                    
                                h1 {
                                    color: #333;
                                    text-align: center;
                                    margin-bottom: 30px;
                                }
                    
                                .todo-item {
                                    margin: 10px 0;
                                    padding: 15px;
                                    border: 1px solid #ddd;
                                    border-radius: 5px;
                                    background-color: white;
                                    display: flex;
                                    justify-content: space-between;
                                    align-items: center;
                                    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                                }
                    
                                .completed {
                                    text-decoration: line-through;
                                    background-color: #f8f8f8;
                                    opacity: 0.8;
                                }
                    
                                form {
                                    margin: 20px 0;
                                    text-align: center;
                                }
                    
                                input[type="text"] {
                                    padding: 10px;
                                    width: 300px;
                                    border: 1px solid #ddd;
                                    border-radius: 4px;
                                    margin-right: 10px;
                                }
                    
                                button {
                                    padding: 10px 15px;
                                    background-color: #4CAF50;
                                    color: white;
                                    border: none;
                                    border-radius: 4px;
                                    cursor: pointer;
                                    transition: background-color 0.3s;
                                }
                    
                                button:hover {
                                    background-color: #45a049;
                                }
                    
                                .delete-btn {
                                    background-color: #f44336;
                                }
                    
                                .delete-btn:hover {
                                    background-color: #da190b;
                                }
                    
                                .toggle-btn {
                                    background-color: #2196F3;
                                    margin-right: 10px;
                                }
                    
                                .toggle-btn:hover {
                                    background-color: #0b7dda;
                                }
                    
                                .inline {
                                    display: inline-block;
                                    margin: 0 5px;
                                }
                            """
                        }
                    }
                    body {
                        h1 { +"Todo List" }
                        
                        form(action = "/add", method = FormMethod.post) {
                            input(type = InputType.text, name = "todo")
                            button(type = ButtonType.submit) { +"Add Todo" }
                        }

                        div {
                            todoList.forEach { todo ->
                                div(classes = if (todo.completed) "todo-item completed" else "todo-item") {
                                    +todo.text
                                    div {
                                        form(action = "/toggle/${todo.id}", method = FormMethod.post, classes = "inline") {
                                            button(type = ButtonType.submit, classes = "toggle-btn") {
                                                +(if (todo.completed) "Mark Incomplete" else "Mark Complete")
                                            }
                                        }
                                        form(action = "/delete/${todo.id}", method = FormMethod.post, classes = "inline") {
                                            button(type = ButtonType.submit, classes = "delete-btn") { +"Delete" }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            post("/add") {
                val parameters = call.receiveParameters()
                val todoText = parameters["todo"] ?: ""
                if (todoText.isNotBlank()) {
                    todoList.add(TodoItem(todoList.size, todoText))
                }
                call.respondRedirect("/")
            }

            post("/toggle/{id}") {
                val id = call.parameters["id"]?.toIntOrNull()
                todoList.find { it.id == id }?.let { it.completed = !it.completed }
                call.respondRedirect("/")
            }

            post("/delete/{id}") {
                val id = call.parameters["id"]?.toIntOrNull()
                todoList.removeIf { it.id == id }
                call.respondRedirect("/")
            }
        }
    }.start(wait = true)
}