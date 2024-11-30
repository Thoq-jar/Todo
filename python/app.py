from flask import Flask, render_template, request, redirect, url_for

app = Flask(__name__)

todos = []

@app.route('/')
def index():
    return render_template('todos.jinja2', todos=todos)

@app.route('/add', methods=['POST'])
def add_todo():
    title = request.form.get('title')
    if title:
        todos.append({'title': title, 'complete': False})
    return redirect(url_for('index'))

@app.route('/complete/<int:index>')
def complete_todo(index):
    if 0 <= index < len(todos):
        todos[index]['complete'] = not todos[index]['complete']
    return redirect(url_for('index'))

@app.route('/delete/<int:index>')
def delete_todo(index):
    if 0 <= index < len(todos):
        todos.pop(index)
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
