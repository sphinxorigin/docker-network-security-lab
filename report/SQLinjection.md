# SQL Injection Simulation

## 1. Background

This file documents a small security extension of my local HTW computer networks lab. The original project was not a pentest project. The main focus was networking, especially routing, NAT, firewall rules, DHCP, DNS and Docker networks.

After the network was working, I added a simple Flask login page to the webserver with help from AI. My goal was to simulate a basic SQL injection in my own local lab and understand the idea behind it better.

## 2. Test Environment

The test was done only locally with Docker Compose.

```text
Host: local machine
Environment: Docker Compose
Target: webserver container
Web app: simple Flask login page
URL: http://127.0.0.1:8082/
```

The login page was intentionally built insecurely for learning purposes. It is not meant for real use.

## 3. Goal

The goal was not to attack a real system. I only wanted to understand how a SQL injection can happen in a login form.

The main questions for me were:

```text
How does a login form handle user input?
Why is direct string formatting in SQL queries dangerous?
How can one input change the logic of a query?
How can this problem be fixed?
```

## 4. Vulnerable Code

In the Flask app, the SQL query was built in an unsafe way.

```python
query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
```

The problem is that the user input is inserted directly into the SQL query. Because of that, the input is not only treated as text, but can also change the structure of the query.

## 5. Test Payload

I used this username in the login form:

```text
admin' OR '1'='1
```

For the password, I used a random value:

```text
test
```

## 6. Result

With this input, I was able to bypass the login in my local lab. The application allowed access to the dashboard even though the correct password was not used.

The reason is that the injected condition can make the SQL query return true.

## 7. Simplified Example

A normal login query should check something like this:

```sql
SELECT * FROM users
WHERE username = 'admin'
AND password = 'admin123';
```

With the manipulated input, the logic changes in a way that can make the condition true:

```sql
SELECT * FROM users
WHERE username = 'admin' OR '1'='1'
AND password = 'test';
```

This shows how the password check can be bypassed if the input is handled unsafely.

## 8. Impact

In a real application, this type of vulnerability could allow someone to log in without valid credentials.

In my project, this was only simulated inside a local Docker lab.

## 9. Cause

The cause is direct string formatting inside the SQL query. The application does not separate user input from SQL code.

This is a common mistake when user input is not handled safely.

## 10. Secure Version

A safer version would use a parameterized query.

```python
cur.execute(
    "SELECT * FROM users WHERE username = ? AND password = ?",
    (username, password)
)
```

With this approach, the input is treated as data and not as executable SQL logic.

## 11. Additional Fixes

Other improvements would also be important:

```text
Do not store passwords in plain text
Use password hashing
Validate user input
Avoid detailed error messages
Log suspicious login attempts
```

## 12. What I Learned

This simulation helped me understand why SQL injection is a serious issue. The problem was not caused by the network itself, but by the way the web application handled input.

Still, using my network lab made the test more useful for me, because the vulnerable webserver was part of a larger Docker network with different zones.

## 13. Conclusion

The SQL injection part was added later as a small extension to my computer networks project.

The main project is still a Docker-based network lab. The security part only adds a simple practical example to connect networking basics with web security basics.
