# SQL-Injection Simulation

## 1. Einordnung

Diese Datei dokumentiert eine kleine Security-Erweiterung meines lokalen HTW-Rechnernetze-Labs. Das ursprüngliche Projekt hatte nicht das Ziel, einen Pentest durchzuführen. Der Fokus lag zuerst auf Netzwerktechnik, also Routing, Firewalling, NAT, DHCP, DNS und Docker-Netzwerken.

Nachdem das Netzwerk stabil funktioniert hat, habe ich den Webserver mit Unterstützung von KI um eine einfache HTML/Login-Seite erweitert. Ziel war es, in einer isolierten lokalen Umgebung eine SQL-Injection zu simulieren und das Prinzip dahinter besser zu verstehen.

## 2. Testumgebung

Die Simulation wurde ausschließlich lokal in Docker durchgeführt.

```text
Host: lokaler Rechner
Umgebung: Docker Compose
Ziel: webserver Container
Web-App: einfache Flask Login-Seite
URL: http://127.0.0.1:8082/
```

Die Anwendung ist absichtlich unsicher gebaut und nicht für produktive Nutzung gedacht.

## 3. Ziel der Simulation

Das Ziel war nicht, ein echtes System anzugreifen, sondern zu verstehen, wie eine SQL-Injection im Login-Bereich funktionieren kann.

Dabei ging es vor allem um diese Fragen:

```text
Wie verarbeitet eine Login-Funktion Benutzereingaben?
Warum ist direkte String-Verkettung in SQL-Abfragen gefährlich?
Wie kann eine manipulierte Eingabe die Login-Logik verändern?
Wie kann man diese Schwachstelle verhindern?
```

## 4. Unsichere Login-Abfrage

In der Flask-Anwendung wurde die SQL-Abfrage bewusst unsicher aufgebaut.

```python
query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
```

Das Problem ist, dass die Eingaben aus dem Login-Formular direkt in die SQL-Abfrage eingesetzt werden. Dadurch kann eine Eingabe nicht nur als normaler Text behandelt werden, sondern die Struktur der SQL-Abfrage verändern.

## 5. Test-Payload

Für die Simulation wurde folgender Benutzername verwendet:

```text
admin' OR '1'='1
```

Als Passwort wurde ein beliebiger Wert eingetragen:

```text
test
```

## 6. Beobachtung

Mit dieser Eingabe konnte der Login in der lokalen Lab-Umgebung umgangen werden. Die Anwendung hat den Zugriff auf das Dashboard erlaubt, obwohl kein gültiges Passwort eingegeben wurde.

Die manipulierte Eingabe sorgt dafür, dass die Bedingung in der SQL-Abfrage immer wahr wird.

## 7. Vereinfachtes Beispiel

Normalerweise soll die Abfrage prüfen:

```sql
SELECT * FROM users
WHERE username = 'admin'
AND password = 'admin123';
```

Durch die manipulierte Eingabe entsteht sinngemäß eine Abfrage, bei der die Bedingung immer wahr werden kann:

```sql
SELECT * FROM users
WHERE username = 'admin' OR '1'='1'
AND password = 'test';
```

Damit wird die eigentliche Passwortprüfung umgangen.

## 8. Auswirkung

Wenn eine solche Schwachstelle in einer echten Anwendung vorhanden wäre, könnte sich ein Angreifer unter Umständen ohne gültige Zugangsdaten anmelden.

In meinem Projekt wurde diese Schwachstelle aber nur absichtlich in einer lokalen Lernumgebung eingebaut.

## 9. Ursache

Die Ursache liegt darin, dass Benutzereingaben direkt in eine SQL-Abfrage eingefügt werden. Die Anwendung trennt nicht sauber zwischen Daten und SQL-Code.

Das ist ein typischer Fehler bei unsicherer Eingabeverarbeitung.

## 10. Sichere Umsetzung

Eine sichere Variante nutzt parametrisierte SQL-Abfragen.

```python
cur.execute(
    "SELECT * FROM users WHERE username = ? AND password = ?",
    (username, password)
)
```

Dabei werden Eingaben als Daten behandelt und nicht als ausführbarer Teil der SQL-Abfrage.

## 11. Weitere Gegenmaßnahmen

Zusätzlich zu parametrisierten SQL-Abfragen wären weitere Schutzmaßnahmen sinnvoll:

```text
Passwörter niemals im Klartext speichern
Passwörter mit Hashing speichern
Eingaben validieren
Fehlermeldungen nicht zu detailliert ausgeben
Logging für verdächtige Login-Versuche einbauen
```

## 12. Lernziel

Durch die Simulation konnte ich nachvollziehen, warum SQL-Injection eine kritische Schwachstelle ist. Besonders wichtig war für mich zu verstehen, dass das Problem nicht durch das Netzwerk entsteht, sondern durch unsichere Verarbeitung in der Webanwendung.

Das Netzwerk-Lab macht die Simulation trotzdem realistischer, weil die Webanwendung in eine größere Umgebung mit mehreren Netzwerkzonen eingebettet ist.

## 13. Fazit

Die SQL-Injection-Simulation war eine nachträgliche Erweiterung meines Rechnernetze-Projekts. Sie zeigt, wie Netzwerktechnik und Web Security zusammenhängen können.

Das Projekt bleibt hauptsächlich ein Docker-basiertes Netzwerk-Lab, wurde aber um eine einfache Security-Komponente ergänzt, um grundlegende Web-Sicherheitskonzepte praktisch zu verstehen.
