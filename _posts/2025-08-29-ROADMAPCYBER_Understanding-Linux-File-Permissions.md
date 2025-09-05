---
title: CyberRoadmap — Understanding Linux File Permissions
date: 2025-08-29 08:00:00 +0200
categories: [Cybersecurity Roadmap, Operating Systems]
tags: [Linux, Bash, Permission]
image: 'assets/img/articles/understand-linux-permission.jpg'
description: "This guide teaches you the basics of Linux permissions, so you can confidently manage your files."
---

---

**From the same series**

1. [Understanding Linux File Permissions](https://cyber-owl.xyz/posts/ROADMAPCYBER_Understanding_Linux_File_Permissions_Part_1/)

2. [Understanding Linux Special Permissions](https://cyber-owl.xyz/posts/ROADMAPCYBER_Understanding_Linux_File_Permissions_Part_2/)

3. [Advanced Permissions with Linux ACLs](https://cyber-owl.xyz/posts/ROADMAPCYBER_Understanding_Linux_File_Permissions_Part_3/)

---

Have you ever tried to open a file on Linux and been hit with a "Permission denied" error? Or maybe you've tried to change a file and couldn't? It's a common experience, but once you understand how Linux handles file permissions, it all starts to make sense.

This guide will walk you through the basics of Linux permissions, so you can start managing your files with confidence.

### The Three Basic Permissions

In Linux, every file and directory has three basic permissions that control what users can do with them:

- **Read (`r`)**: This permission allows you to view the contents of a file. For a directory, it allows you to list the files inside it.
    
- **Write (`w`)**: This permission allows you to modify or delete a file. For a directory, it allows you to create, delete, or rename files within it.
    
- **Execute (`x`)**: This permission allows you to run a file if it's a program or script. For a directory, it allows you to `cd` (change directory) into it and access its contents.
    

These three permissions are the building blocks of the entire system.

### The Three Categories of Users

Now, who do these permissions apply to? Linux organizes users into three main categories:

- **Owner (`u`)**: This is the person who created the file or directory.
    
- **Group (`g`)**: This is the group of users that the file belongs to.
    
- **Others (`o`)**: This includes everyone else on the system who isn't the owner or a member of the group.
    

When you run the command `ls -l` in your terminal, the output shows you a long string of permissions. The first character tells you if it's a file (`-`), a directory (`d`) or a symbolic link (`l`). The next nine characters are the permissions for the owner, group, and others, in that order (e.g., `rwx r-x r--`).

### Changing Permissions with `chmod`

The command to change permissions is `chmod` (short for "change mode"). You can use it in two common ways: symbolic mode and octal mode.

#### Symbolic Mode

This method uses the letters we've already learned (`u`, `g`, `o`, `r`, `w`, `x`) to add or remove permissions. You use `+` to add a permission, `-` to remove one and `=` to set one.

For example, to give the group write permission on a file called `my_file.txt`, you would run:

```bash
chmod g+w my_file.txt
```

To remove the write permission for others, you would use:

```bash
chmod o-w my_file.txt
```

You can even combine them! To give the owner and group execute permissions, you'd use: `chmod ug+x my_file.txt`.

To set a permission (overriding existing permission set), you would use:

```bash
chmod g=rx my_file.txt
```

This will set for group the following permission `r-x`.

#### Octal Mode

This method uses numbers to represent the permissions. Each permission has a number:

- `r` = 4
    
- `w` = 2
    
- `x` = 1
    
- No permission = 0
    

You add the numbers together to get a total for each category. For example, `rwx` is 4+2+1=7, and `r-x` is 4+0+1=5.

```
All possible permissions

rwx = 7

rw- = 6
r-x = 5
-wx = 3

r-- = 4
-w- = 2
--x = 1

--- = 0
```

The command `chmod 754 my_file.txt` would set the permissions as follows:

- **Owner (7)**: `rwx` (read, write, execute)
    
- **Group (5)**: `r-x` (read, execute)
    
- **Others (4)**: `r--` (read only)
    

### Changing Ownership with `chown` and `chgrp`

What if you want to change who owns the file or what group it belongs to?

- **`chown`**: This command changes the file owner.
    
    - To make the user `bob` the owner of `my_file.txt`, you'd run: `chown bob my_file.txt`.
	
- **`chgrp`**: This command changes the file's group.
    
    - To change the group of `my_file.txt` to `developers`, you'd run: `chgrp developers my_file.txt`.


You can even do both at once with 

```bash
chown user:group my_file.txt
```

Managing permissions can seem daunting at first, but with `chmod`, `chown`, and `chgrp`, you have everything you need to control access to your files.

I recommend you to create a low-privileged user on a linux OS and test everything you've learn.
(Don't forget to specify a shell for your user otherwise you could have issues using `cd` command)

```bash
sudo useradd johndoe
sudo usermod --shell /bin/bash johndoe

# or

sudo useradd -s /bin/bash johndoe
```

Hopefully, this helps you feel more comfortable navigating the Linux permission system!


{% include comment.html %}