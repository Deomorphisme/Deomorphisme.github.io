---
title: Write-up — Agent sudo
date: 2024-11-18 10:00:00 AM
categories: [Write-up, Try Hack Me]
tags: [Try Hack Me, Write-up, ctf, Easy]
image: 'assets/img/articles/Agent sudo.png'
description: The "Agent Sudo" room on TryHackMe challenges players to investigate and exploit vulnerabilities in a fictional espionage-themed scenario. It combines elements of reconnaissance, privilege escalation, and creative problem-solving, offering an engaging experience for both novice and intermediate cybersecurity enthusiasts.
---

> Walkthrough of room Brains from TryHackMe :
> [https://tryhackme.com/r/room/agentsudoctf](https://tryhackme.com/r/room/agentsudoctf)

This room has four parts, **enumerate**, **cracking**, **user pwn** and **privilege escalation**.

---

## Part one — Deploy the machine

![Deployment](assets/img/2024-11-18-THM-AgentSudo/img0 - deployment.png){: w="600"}
_Deployment of the machine_

---

## Part two — Enumerate
Don't ask me why. I was facing network issues with my scan so I tried complete scan 😅. But regular scans should work.

![Nmap scan](assets/img/2024-11-18-THM-AgentSudo/img1 - scan.png){: w="600"}
_Nmap scan_

> How many open ports? \
> **Answer 1: 3 ports**

Let's explore the **web page**.

![Web page](assets/img/2024-11-18-THM-AgentSudo/img2 - codename.png){: w="600"}
_Web page_

> How you redirect yourself to a secret page? \
> **Answer 2: user-agent**

So I have to change the `user-agent` in the browser. I will use the firefox extension **User-Agent Switcher and Manager** to manually change the `user-agent`. After three tentatives, I found the right `user-agent`.

![User-Agent Switcher and Manager](assets/img/2024-11-18-THM-AgentSudo/img3 - user-agent manager.png){: w="600"}
_User-Agent Switcher and Manager interface_

After applying the new parameter (apply container on the window) and the reloading the tab, I am redirected to a new page `http://10.10.59.171/agent_C_attention.php`. It shows up a message **Chris**, probably agent C.

![](assets/img/2024-11-18-THM-AgentSudo/img4 - agent chris.png){: w="600"}
_Message to chris_

> What is the agent name?\
> **Answer 3: chris**

---

## Part three — Hash cracking and brute-force
> Done enumerate the machine? Time to brute your way out.

In the precedent task, I dealt to access a message from *agent R* in destination to *agent C*.

```
Attention chris,  
  
Do you still remember our deal? Please tell agent J about the stuff ASAP. Also, change your god damn password, is weak!  
  
From,  
Agent R
```

It means we could attempt a brute-force on the FTP with the account of agent *chris*.

```bash
hydra -l chris -P /usr/share/wordlists/rockyou.txt ftp://10.10.59.171 -f
```

![Hydra result](assets/img/2024-11-18-THM-AgentSudo/img5 - hydra.png)
_Hydra brute-force result_

> FTP password\
> **Answer 1: crystal**

Let's connect to the FTP server!

![ftp connexion](assets/img/2024-11-18-THM-AgentSudo/img6 - ftp server.png){: w="600"}
_ftp connexion_

I found three files on the ftp server `To_agentJ.txt`, `cute-alien.jpg` and `cutie.png`. Now I'm going to download them in order to analyze.

```bash
# download a file on ftp server
ftp> get filename
```

It seems the message to *agent J* contains a hint on what to do next.

![Message to agent J](assets/img/2024-11-18-THM-AgentSudo/img7 - message to agent J.png){: w="600"}
_Message to agent J_

The password are in the 2 alien pictures, but I don't which under form it is.

`Exiftool` and `steghide` didn't show nothing, except for `cute-alien.jpg` but I need a *passphrase*. Let's check if there is an embedded file.

```bash
# cute-alien.jpg doesn't contain antyhing
binwalk -e cutie.png
```

(Don't mind if you don't get the exact output 😉)

![Embedded file](assets/img/2024-11-18-THM-AgentSudo/img8 - binwalk.png){: w="600"}
_Embedded file_

Now, I gonna extract the password hash of the zip file with **`zip2john`**.

> **How `zip2john` Works?**\
>	- ZIP files that are password-protected do not store the password itself. Instead, they store a cryptographic hash that represents the password.\
>	- `zip2john` extracts this hash from the ZIP file and formats it in a way that is compatible with **John the Ripper**.\
> This allows **John the Ripper** to perform a brute-force or dictionary attack on the hash to find the original password.

```bash
zip2john 8702.zip > zip_hash.txt
john zip_hash.txt --wordlist=/usr/share/wordlists/rockyou.txt
```

![Password cracjing with JohnTheRipper](assets/img/2024-11-18-THM-AgentSudo/img9 - john.png){: w="600"}
_Password cracjing with JohnTheRipper_

![Alien](https://tenor.com/fr/view/alien-creepy-scary-gif-15017835.gif){: w="500"}

> Zip file password\
> **Answer 2: alien**

I can now unzip the file with the cracked password and print the message to *agent R*.

```bash
$> 7z e 8702.zip
...

$> cat To_agentR.txt
Agent C,

We need to send the picture to 'QXJlYTUx' as soon as possible!

By,
Agent R
```

Looks like *`base64`* string.

```bash
$> echo 'QXJlYTUx' | base64 -d
Area51
```

Lmao 😂

![a sticker that says get in loser we 're going to area 51 on it](https://media.tenor.com/IOzeGBm3socAAAAM/alien-aliens.gif){: w="500"}

> steg password\
> **Answer 3: Area51**

![Message to agent James](assets/img/2024-11-18-THM-AgentSudo/img10 - message to James.png){: w="600"}
_Message to agent James_

> Who is the other agent (in full name)?\
> **Answer 4: james**

> SSH password\
> **Answer 5: hackerrules!**

---

## Part four — Capture the user flag

Since I have the username and the password, let's try a connexion to the SSH server.

![ssh connexion](assets/img/2024-11-18-THM-AgentSudo/img11 - ssh.png)
_ssh connexion_

> What is the user flag?\
> **Answer 1: b03d975e8c92a7c04146cfa7a5a313c7**

```bash
# To download the picture
# May be I should use scp but ssh port was blocked on my kali vm

# On the ssh server from james session
$> python3 -m http.server

# On my kali vm
$> wget http://10.10.59.171:8000/Alien_autospy.jpg
```

And this the picture 👽:

![Alien corpse](assets/img/2024-11-18-THM-AgentSudo/Alien_autospy.png)
_Strange alien corpse_

A quick search on google (found on amazon.com):

![Roswell Alien Autopsy book](assets/img/2024-11-18-THM-AgentSudo/img12 - alien incident.png)
_Roswell Alien Autopsy book_

> What is the incident of the photo called?\
> **Answer 2: Roswell Alien Autopsy**

---

## Part five — Privilege escalation
Let's check what I can execute with **`sudo`** privileges.

![](assets/img/2024-11-18-THM-AgentSudo/img13 - sudo -l.png){: w="600"}

It seems I can run `/bin/bash` but not `root` privileges. What can we find on google about this rule?

![](assets/img/2024-11-18-THM-AgentSudo/img14 - CVE.png){: w="600"}

Directly got the CVE!

> CVE number for the escalation\
> **Answer 1: CVE-2019-14287**

I found a resources that explain the flaw and how to exploit it: `https://steflan-security.com/linux-privilege-escalation-vulnerable-sudo-version/`.

![](assets/img/2024-11-18-THM-AgentSudo/img15 - ExploitDB demo.png){: w="600"}

![](assets/img/2024-11-18-THM-AgentSudo/img16 - root flag.png){: w="600"}

> What is the root flag?\
> **Answer 2: b53a02f55b57d4439e3341834d70c062**

> (Bonus) Who is Agent R?\
> **Answer 3: DesKel**

All flags down, mission passed.

![](https://media1.tenor.com/m/lQBJJmatxPYAAAAd/mission-accomplished-penguins.gif)

Be proud of what you’ve accomplished.

See you soon!

> "Cybersecurity is not just about protecting systems; it's about safeguarding the trust and potential of the digital world."
