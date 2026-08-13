from flask import Flask, request, render_template_string
import sqlite3
import subprocess

app = Flask(__name__)
app.secret_key = "vulncorp-lab-secret"

LOGIN_PAGE = """
<!doctype html>
<html>
<head>
    <title>VulnCorp Portal</title>
</head>
<body>
    <h1>VulnCorp Login</h1>
    <form method="POST">
        <label>Username:</label><br>
        <input name="username"><br><br>

        <label>Password:</label><br>
        <input name="password" type="password"><br><br>

        <button type="submit">Login</button>
    </form>

    {% if message %}
        <p><b>{{ message }}</b></p>
    {% endif %}
</body>
</html>
"""

DASHBOARD_PAGE = """
<!doctype html>
<html>
<head>
    <title>VulnCorp Dashboard</title>
</head>
<body>
    <h1>Welcome to VulnCorp Admin Portal</h1>

    <h2>Internal Ping Tool</h2>
    <form method="POST" action="/ping">
        <label>Target:</label><br>
        <input name="target" value="10.10.0.2"><br><br>
        <button type="submit">Ping</button>
    </form>

    {% if output %}
        <h3>Output:</h3>
        <pre>{{ output }}</pre>
    {% endif %}
</body>
</html>
"""

def init_db():
    conn = sqlite3.connect("users.db")
    cur = conn.cursor()
    cur.execute("CREATE TABLE IF NOT EXISTS users (username TEXT, password TEXT)")
    cur.execute("DELETE FROM users")
    cur.execute("INSERT INTO users VALUES ('admin', 'admin123')")
    conn.commit()
    conn.close()

@app.route("/", methods=["GET", "POST"])
def login():
    message = ""

    if request.method == "POST":
        username = request.form.get("username", "")
        password = request.form.get("password", "")

        conn = sqlite3.connect("users.db")
        cur = conn.cursor()

        query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
        print("[DEBUG] SQL query:", query)

        cur.execute(query)
        user = cur.fetchone()
        conn.close()

        if user:
            return render_template_string(DASHBOARD_PAGE, output="")
        else:
            message = "Login failed"

    return render_template_string(LOGIN_PAGE, message=message)

@app.route("/ping", methods=["POST"])
def ping():
    target = request.form.get("target", "")

    command = f"ping -c 2 {target}"
    output = subprocess.getoutput(command)

    return render_template_string(DASHBOARD_PAGE, output=output)

if __name__ == "__main__":
    init_db()
    app.run(host="0.0.0.0", port=8080)