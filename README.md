# Docker Network Security Lab

This project is based on a network lab from my Computer Networks module at HTW Berlin. I later rebuilt it locally with Docker Compose because I wanted to understand the network setup better and keep it as a portfolio project.

The main focus of this project is networking: routing, NAT, firewall rules, DNS, DHCP and port forwarding between multiple Docker containers. After the network was working, I added a small vulnerable login page to the webserver to simulate a basic SQL injection in a controlled local environment.

## Project Background

The original HTW project was not a pentest project. It was mainly about building and configuring a multi-zone network.

At the time, I focused mostly on getting the network tasks done. Later, I decided to reconstruct the setup locally, document it properly and extend it a bit so I could also practice basic web security concepts inside the same lab.

## Network Overview

The lab contains multiple Docker containers that represent different parts of the network.

```text
ISP network:
i2, i3, i4, i5

Service network:
dns, webserver

Subscription network:
homerouter, client1, client2, client3, gameserver
```

The `homerouter` connects the internal subscription network with the ISP network. The `webserver` and `dns` server are located in the service network. The `gameserver` is placed behind the home router and can be reached through port forwarding.

## Network Topology

The following diagram shows the logical topology that I used as a reference for the Docker Compose setup.

![Network Topology](docs/network-topology.png)

In my Docker setup, the switches from the diagram are represented by Docker bridge networks. I also had to add some Docker-specific adjustments, for example custom subnets, gateway addresses, interface renaming and additional routes.

## What I Built

This project includes:

- a multi-container network setup with Docker Compose
- separated ISP, service and subscription networks
- static routing between network zones
- NAT for internet access
- port forwarding from the home router to the internal gameserver
- DNS for internal hostnames
- a local webserver
- a simple vulnerable login page for SQL injection testing

## Repository Structure

```text
docker-network-security-lab/
├── docker-compose.yml
├── README.md
├── .gitignore
├── docs/
│   └── network-topology.png
├── webserver/
│   ├── Dockerfile
│   ├── app.py
│   ├── entrypoint.sh
│   ├── original_webserver_startup.sh
│   └── rename_by_subnet.sh
├── dns/
├── homerouter/
├── gameserver/
├── i2/
├── i3/
├── i4/
├── i5/
├── client1/
├── client2/
├── client3/
└── report/
    └── SQLInjection.md
```

## Local Reconstruction

The original startup scripts were kept as `original_<name>_startup.sh` files. I added wrapper and entrypoint scripts around them so the lab can run locally with Docker Compose.

This was necessary because Docker Desktop does not always use the same interface names or gateway behavior that the original lab expected.

## Problems I Had to Solve

While rebuilding the lab, I had to debug several networking issues.

Some examples:

- Docker used a gateway address that conflicted with one of the lab routers
- some containers had missing routes to the subscription network
- interface names inside containers did not match the original scripts
- internet access from internal clients did not work at first
- port forwarding to the gameserver needed both DNAT and MASQUERADE to work correctly

One concrete example was the gameserver connection. The DNAT rule forwarded the traffic to the internal gameserver, but the response path was not correct at first. The connection only worked after adding the correct MASQUERADE rule.

## Security Extension

After the network was working, I added a small Flask login page to the `webserver`.

This part was not included in the original HTW project. I added it later with help from AI so I could simulate a basic SQL injection in my own local lab.

The login page is intentionally insecure. It is only used to understand how SQL injection can happen when user input is inserted directly into a SQL query.

Example payload used in the lab:

```text
Username: admin' OR '1'='1
Password: test
```

The SQL injection simulation is documented here:

```text
report/SQLInjection.md
```

## How to Run

Start the lab:

```bash
docker compose up --build -d
```

Stop the lab:

```bash
docker compose down
```

Open the local web portal:

```text
http://127.0.0.1:8082/
```

Default test login:

```text
Username: admin
Password: admin123
```

## Basic Network Tests

Test internet access from a client:

```bash
docker compose exec client1 ping -c 3 8.8.8.8
```

Test access from the webserver to the home router:

```bash
docker compose exec webserver ping -c 3 10.10.0.2
```

Test port forwarding to the internal gameserver:

```bash
docker compose exec webserver nc -vz -w 3 10.10.0.2 12933
```

## Current Status

```text
Client internet access: working
DNS service: available
Webserver: reachable
HomeRouter routing: working
Gameserver port forwarding: working
Local login page: working
SQL injection simulation: working
```

## What I Learned

This project helped me understand networking much more practically.

Instead of only looking at routing tables in theory, I had to test the path of packets step by step. I learned how small mistakes in routes, gateways or NAT rules can break communication between networks.

The later SQL injection part also helped me see how web security can be tested inside a realistic network setup, even if the web application itself is very simple.

## Disclaimer

The SQL injection part is only meant for my local lab, so I would not expose it to the internet or use it with real data.
