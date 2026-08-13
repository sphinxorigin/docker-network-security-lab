# HTW Rechnernetze Lab mit Docker Compose

Dieses Repository enthält meine lokale Rekonstruktion eines Docker-basierten Netzwerk-Labs aus dem Modul **Rechnernetze** an der HTW Berlin. Ziel des ursprünglichen Projekts war es, ein mehrstufiges Netzwerk mit Routing, Firewalling, NAT, DHCP und DNS aufzubauen und lokal lauffähig zu machen.

Nach der erfolgreichen Umsetzung habe ich das Projekt zusätzlich erweitert, um erste Security-Tests in einer isolierten Lernumgebung durchführen zu können.

## Projektziel

Das ursprüngliche Ziel war nicht die Durchführung eines Pentests, sondern der Aufbau und die Konfiguration einer realistischen Netzwerktopologie mit mehreren getrennten Bereichen.

Im Fokus standen dabei:

```text
Routing
Firewall-Regeln
NAT
Port-Forwarding
DHCP
DNS
Docker-Netzwerke
Linux-Netzwerktools
```

Durch das Projekt konnte ich besser nachvollziehen, wie Pakete durch verschiedene Netzbereiche laufen, wie Router miteinander kommunizieren und wie Firewall- und NAT-Regeln die Erreichbarkeit beeinflussen.

## Netzwerktopologie

Das Lab besteht aus elf Containern und mehreren getrennten Docker-Netzwerken.

```text
ISP-Mesh:
i2, i3, i4, i5

Service-Netz:
dns, webserver

Subscription-Netz:
homerouter, client1, client2, client3, gameserver
```

Der `homerouter` verbindet das Subscription-Netz mit dem ISP-Netz. Der `webserver` befindet sich im Service-Netz. Der `gameserver` liegt hinter dem HomeRouter im internen Netz und ist über Port-Forwarding erreichbar.


## Umsetzung

Die ursprünglichen Startup-Skripte wurden nicht direkt überschrieben. Stattdessen wurden sie als `original_<name>_startup.sh` gespeichert. Dadurch bleibt nachvollziehbar, welche Logik aus dem ursprünglichen Rechnernetze-Lab stammt und welche Anpassungen für den lokalen Betrieb mit Docker Compose ergänzt wurden.

Für die lokale Ausführung auf meinem Rechner waren mehrere Anpassungen notwendig. Dazu gehören feste Docker-Subnetze, eigene Gateways, Interface-Umbenennungen und zusätzliche Routing-Regeln.

## Technische Anpassungen

Docker vergibt Interface-Namen und Gateway-Adressen teilweise anders, als es die ursprünglichen Skripte erwarten. Deshalb wurden kleine Kompatibilitäts-Layer ergänzt.

Dazu gehören:

```text
feste MAC-Adressen in docker-compose.yml
Interface-Umbenennung über rename_by_subnet.sh
angepasste Docker-Gateways
zusätzliche statische Routen
NAT-Regeln für Internetzugang
DNAT und MASQUERADE für Port-Forwarding
```

Ein Beispiel war das Service-Netz. Docker hätte standardmäßig `100.24.0.1` als Gateway verwendet. Diese Adresse wird im Lab aber von `i4` benötigt. Deshalb wurde das Docker-Gateway auf `100.24.0.254` gelegt.

## Ergänzte Routen

Beim Testen ist aufgefallen, dass einige Router keine passenden Routen zum Subscription-Netz hatten. Dadurch konnten Pakete aus dem Service-Netz den HomeRouter und den Gameserver nicht zuverlässig erreichen.

Deshalb wurden zusätzliche Routen ergänzt:

```text
i2 → Subscription-Netz über i5
i4 → Subscription-Netz über i5
i3 → Subscription-Netz über i4
```

Diese Ergänzung war notwendig, damit die Kommunikation zwischen Service-Netz und Subscription-Netz funktioniert.

## Gelöste Netzwerkprobleme

Während der Umsetzung sind mehrere typische Netzwerkprobleme aufgetreten, die ich Schritt für Schritt analysiert und gelöst habe.

Ein Problem war, dass Clients das Internet nicht erreichen konnten. Die Ursache lag bei `i2`, weil das Internet-Interface nicht korrekt aktiv war und keine passende Default-Route zum Docker-Gateway gesetzt war.

Ein weiteres Problem war das Port-Forwarding zum Gameserver. Die DNAT-Regel wurde zwar getroffen, aber die TCP-Verbindung funktionierte erst stabil, nachdem zusätzlich eine passende MASQUERADE-Regel für den Rückweg ergänzt wurde.

Außerdem gab es eine IP-Kollision im Service-Netz, weil Docker und `i4` dieselbe Gateway-Adresse verwendet haben. Dieses Problem wurde durch ein separates Docker-Gateway gelöst.

## Eigene Security-Erweiterung

Das ursprüngliche HTW-Projekt hatte nicht das Ziel, einen Pentest oder eine Angriffssimulation durchzuführen. Der Fokus lag zuerst klar auf Netzwerktechnik.

Nachdem das Netzwerk stabil funktioniert hat, habe ich es mit Unterstützung von KI erweitert. Ich habe auf dem `webserver` eine einfache HTML/Login-Seite über eine Flask-App eingebaut. In dieser kontrollierten Laborumgebung habe ich anschließend eine SQL-Injection simuliert.

Dadurch konnte ich nicht nur das Netzwerk testen, sondern auch nachvollziehen, wie eine einfache Web-Schwachstelle in einem realistischeren Netzwerkaufbau aussehen kann.

Die Erweiterung ist bewusst einfach gehalten und dient nur Lernzwecken. Es geht nicht darum, ein fertiges Pentest-Lab bereitzustellen, sondern darum, die Verbindung zwischen Netzwerktechnik und grundlegender Web Security praktisch zu verstehen.

## Sicherheitshinweis

Dieses Projekt ist ausschließlich für lokale Lernzwecke gedacht. Die verwundbaren Komponenten sind absichtlich unsicher gebaut.

Das Lab sollte nicht ins öffentliche Internet gestellt werden. Es sollten keine echten Zugangsdaten, keine echten Kundendaten und keine produktiven Systeme verwendet werden.

## Voraussetzungen

Benötigt wird:

```text
Docker Desktop für Mac
Docker Compose V2
```

Die installierte Version kann geprüft werden mit:

```bash
docker compose version
```

## Starten

Im Projektordner:

```bash
docker compose up --build -d
```

Dadurch werden alle Container gebaut und im Hintergrund gestartet.

## Stoppen

```bash
docker compose down
```

Wenn alle Docker-Netzwerke vollständig neu erstellt werden sollen:

```bash
docker compose down
docker compose up --build -d
```

## Webportal öffnen

Die lokal erweiterte Webanwendung ist erreichbar unter:

```text
http://127.0.0.1:8082/
```

Normale Test-Zugangsdaten:

```text
Username: admin
Password: admin123
```

## Funktionstests

Internetverbindung eines Clients testen:

```bash
docker compose exec client1 ping -c 3 8.8.8.8
```

Erwartetes Ergebnis:

```text
3 packets transmitted, 3 received, 0% packet loss
```

Webserver erreicht den HomeRouter:

```bash
docker compose exec webserver ping -c 3 10.10.0.2
```

Port-Forwarding zum internen Gameserver testen:

```bash
docker compose exec webserver nc -vz -w 3 10.10.0.2 12933
```

Erwartetes Ergebnis:

```text
10.10.0.2 12933 open
```

Direkter Test vom HomeRouter zum Gameserver:

```bash
docker compose exec homerouter nc -vz -w 3 192.168.1.10 12933
```

## SQL-Injection Simulation

Die Login-Seite wurde bewusst unsicher umgesetzt, damit eine SQL-Injection in einer isolierten Umgebung nachvollzogen werden kann.

Beispiel für den Test:

```text
Username: admin' OR '1'='1
Password: test
```

Dadurch kann der Login in der Lab-Umgebung umgangen werden. Dieser Teil dient nur dazu, das Prinzip einer SQL-Injection besser zu verstehen und später sauber zu dokumentieren.

## Aktueller Status

Folgende Punkte wurden umgesetzt und getestet:

```text
Client → Internet: funktioniert
Webserver → HomeRouter: funktioniert
Webserver → Gameserver über Port 12933: funktioniert
DNS im Service-Netz: vorhanden
Lokales Webportal mit Login-Seite: erreichbar
SQL-Injection Simulation: funktioniert
```

## Geplante Dokumentation

Im Ordner `report/` wird ein einfacher Report gepflegt. Dort dokumentiere ich die durchgeführten Tests, die Beobachtungen und mögliche Gegenmaßnahmen.

Geplante Inhalte:

```text
Finding 1: SQL-Injection im Login
Beschreibung der Ursache
Auswirkung der Schwachstelle
Nachweis mit Test-Payload
Mögliche Gegenmaßnahmen
```

## Was ich aus dem Projekt gelernt habe

Durch das Projekt habe ich gelernt, wie wichtig sauberes Routing, korrekte Gateway-Adressen und passende NAT-Regeln sind. Viele Fehler waren nicht direkt offensichtlich, sondern mussten über einzelne Tests entlang des Paketwegs eingegrenzt werden.

Besonders hilfreich war es, jeden Abschnitt einzeln zu prüfen:

```text
Client → Router
Router → ISP
ISP → Internet
Webserver → HomeRouter
HomeRouter → Gameserver
Gameserver → Rückweg
```

Die spätere Security-Erweiterung hat mir zusätzlich gezeigt, wie Netzwerktechnik und Web Security zusammenhängen können.

## Hinweis zur KI-Unterstützung

Bei der Erweiterung und beim Debugging habe ich KI als Unterstützung genutzt. Die Entscheidungen, Tests und Anpassungen wurden aber Schritt für Schritt lokal ausgeführt und überprüft. Dadurch konnte ich die Fehler nicht nur beheben, sondern auch besser verstehen.
