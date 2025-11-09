---
title: CyberRoadmap — Mastering CRUD Operations in Linux, PowerShell, and CMD
date: 2025-08-28 00:00:00 AM
categories: [Cybersecurity Roadmap, Operating Systems]
tags: [Bash, Powershell, CMD, CRUD]
image: 'assets/img/articles/crud-files-directories.png'
description: "Today, we're diving into something truly fundamental for anyone working with computers: CRUD operations. CRUD stands for Create, Read, Update, and Delete. These are the basic actions you perform on files and folders, and mastering them across different operating systems is absolutely essential for a strong sys admin and cybersecurity toolkit."
---

Hello dear hacker!

Today, we're diving into something truly fundamental for anyone working with computers: **CRUD operations**. CRUD stands for **C**reate, **R**ead, **U**pdate, and **D**elete. These are the basic actions you perform on files and folders, and mastering them across different operating systems is absolutely essential for a strong sys admin and cybersecurity toolkit.

## Part 1: Linux – Your Command Line Powerhouse

Linux is where many of us start our command-line journey. Its commands are often short and sweet, but incredibly powerful.

**1. Create ➕**

- **Files:**
    
    - `touch new_file`: This is your go-to for making an empty file. Simple and quick!
        
    - `nano new_file` or `vi new_file`: These open a text editor, letting you create a file and start typing right away.
        
    - `command > new_file`: Use this to create a file and put the output of a command directly into it.
        
    - **The `tee` command (Bonus!):** We talked about `tee` for a bit. It’s like a "T" pipe for data! `command | tee file.txt` shows the output on your screen _and_ saves it to a file at the same time. Super useful for logging things while you watch them happen.
        
- **Directories (Folders):**
    
    - `mkdir folder_name`: Creates a new, empty directory.
        
    - `mkdir -p project/docs/images`: The `-p` flag is a lifesaver! It creates all parent directories if they don't exist, so you can build out a whole path at once.
        

**2. Read 📖**

- `cat file`: Shows the entire content of a file on your screen. Great for short files, but can be overwhelming for long ones!
    
- `less file`: This is your best friend for long files. It lets you scroll up and down, search, and view content without loading the whole file into memory. (Remember `more` only lets you scroll forward, `less` gives you more flexibility!)
    
- `head -n X file`: Shows the first `X` lines of a file.
    
- `tail -n X file`: Shows the last `X` lines of a file. Very handy for logs!
    

**3. Update ✏️**

- `echo "New line of text" >> file.txt`: The `>>` operator appends (adds to the end) the text to your file. It won't erase what's already there.
    
- `nano file` or `vi file`: Use these text editors to open the file and make changes directly.
    
- **Here Documents:** A cool trick for scripts! You can pass multiple lines of text directly into a file:
    
```bash
cat >> file.txt << EOF
This is the first new line.
This is the second new line.
EOF
```
    

**4. Delete 🗑️**

- **Files:**
    
    - `rm file`: Removes a file.
        
- **Directories:**
    
    - `rmdir empty_folder`: Only works if the folder is completely empty.
        
    - `rm -r folder_with_stuff`: **Use with caution!** The `-r` (recursive) flag deletes the folder and everything inside it (files, subfolders, etc.). This is powerful but permanent!
        
    - `rm -ri folder_with_stuff`: Adding `-i` (interactive) will prompt you for confirmation before deleting each item, giving you a chance to double-check. A good habit to develop!
        

---

## Part 2: PowerShell – The Modern Windows Powerhouse

PowerShell is Microsoft's answer to a powerful command-line shell, heavily inspired by Linux concepts but with its own unique flair. It's becoming crucial for Windows sys admin tasks and, by extension, cybersecurity operations.

The key thing to remember is PowerShell's `Verb-Noun` structure for its commands (cmdlets).

**1. Create ➕**

- **Files and Directories:**
    
    - `New-Item -ItemType File new_file.txt`: Creates a new, empty file.
        
    - `New-Item -ItemType Directory folder_name`: Creates a new directory.
        
    - `mkdir folder_name`: A handy alias that works just like in Linux!
        

**2. Read 📖**

- `Get-Content file.txt`: Reads and displays the content of a file.
    
- `cat file.txt` or `type file.txt`: These are aliases for `Get-Content`, making it familiar for users coming from other shells.
    

**3. Update ✏️**

- `Add-Content -Value "New text" file.txt`: Appends the specified content to the end of the file.
    
- `echo "Another line" >> file.txt`: Yes, the `>>` operator works here too!
    
- `Set-Content -Value "This replaces everything" file.txt`: **Careful!** This command overwrites the _entire_ content of the file. Similar to `command > file.txt`.
    

**4. Delete 🗑️**

- `Remove-Item file.txt`: Deletes a file.
    
- `Remove-Item folder_name`: Deletes an empty directory.
    
- `Remove-Item -Recurse folder_with_stuff`: **Again, be careful!** The `-Recurse` flag deletes the directory and all its contents.
    
- `Remove-Item -Recurse -Force protected_item`: The `-Force` flag can be used to delete items that might be hidden or read-only.
    

---

## Part 3: Command Prompt (CMD) – The Classic Windows Shell

While PowerShell is generally preferred for new tasks, understanding CMD is still important, especially when dealing with older scripts or environments. Some of its commands are quite similar to Linux, others are uniquely Windows.

**1. Create ➕**

- **Files:**
    
    - `type NUL > new_file.txt`: This is the classic CMD trick to create an empty file. `NUL` is an empty device, and we redirect its (lack of) content into the new file.
        
- **Directories:**
    
    - `mkdir folder_name` or `md folder_name`: Just like in Linux!
        

**2. Read 📖**

- `type file.txt`: Displays the content of a file.
    

**3. Update ✏️**

- `echo "Adding this line" >> file.txt`: Yep, `>>` works here too!
    
- `echo "This replaces everything" > file.txt`: The `>` operator overwrites the file.
    

**4. Delete 🗑️**

- **Files:**
    
    - `del file.txt`: Deletes a file.
        
- **Directories:**
    
    - `rd empty_folder` or `rmdir empty_folder`: Deletes an empty directory.
        
    - `rd /s folder_with_stuff`: **Be careful!** The `/s` flag deletes the directory and all its contents.
        
    - `rd /s /q folder_with_stuff`: Adding `/q` (quiet) makes it delete without asking for confirmation.
        

---

## Why is This Important for Cybersecurity?

Understanding CRUD isn't just about managing files; it's about understanding how data is handled at a fundamental level. In cybersecurity, this knowledge helps you to:

- **Analyze logs:** Quickly read and filter massive log files to spot suspicious activity.
- **Automate tasks:** Write scripts to create, update, or delete temporary files for security checks or cleanups.
- **Incident Response:** Securely delete malicious files or quickly deploy new configurations.
- **Forensics:** Extract and read specific data from compromised systems.

This might seem basic, but these commands are your building blocks for much more complex operations. Practice them often!

## Cheat sheet

<iframe src="{{ 'assets/files/CRUD Operations Cheat Sheet.pdf' | relative_url }}" width="100%" height="650px" style="border: none;"></iframe>

{% include comment.html %}