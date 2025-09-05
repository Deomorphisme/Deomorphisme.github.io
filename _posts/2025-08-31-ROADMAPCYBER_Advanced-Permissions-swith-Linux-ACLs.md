---
title: CyberRoadmap — Advanced Permissions with Linux ACLs
date: 2025-08-31 08:00:00 0+200
categories: [Cybersecurity Roadmap, Operating Systems]
tags: [Linux, Bash, Permission]
image: 'assets/img/articles/understand-linux-permission.jpg'
description: "This guide explores access control lists (ACLs) in Linux, offering more granular permission management. Learn how to use getfacl and setfacl to manage specific permissions for individual users or groups."
---

---

**From the same series**

1. [Understanding Linux File Permissions](https://cyber-owl.xyz/posts/ROADMAPCYBER_Understanding_Linux_File_Permissions_Part_1/)

2. [Understanding Linux Special Permissions](https://cyber-owl.xyz/posts/ROADMAPCYBER_Understanding_Linux_File_Permissions_Part_2/)

3. [Advanced Permissions with Linux ACLs](https://cyber-owl.xyz/posts/ROADMAPCYBER_Understanding_Linux_File_Permissions_Part_3/)

---

We've covered the basics of Linux permissions, from `rwx` to the special SUID and SGID bits. But what if you have a unique permission need? For example, what if you want to give read-only access to a specific user who isn't in the file's group, without giving the same access to everyone else?

For these more granular situations, Linux provides **Access Control Lists (ACLs)**. ACLs let you go beyond the simple `owner/group/others` model and define very specific permissions for individual users or groups.

### How to View ACLs with `getfacl`

The first step to working with ACLs is to see if any are set on a file. The command for this is `getfacl`.

When you run `getfacl` on a file, it will show you the traditional permissions and any extra ACLs. For a simple file with no ACLs, the output will look like this:

```
# file: my_report.txt
# owner: bob
# group: marketing
user::rw-
group::r--
other::---
```

You can see the familiar owner, group, and others permissions, but in a more detailed, line-by-line format.

Now, let's see what happens when an ACL is added for a user named `alice`:

```
# file: my_report.txt
# owner: bob
# group: marketing
user::rw-
group::r--
other::---
mask::rwx
user:alice:rwx
```

Notice the new line for `user:alice`. This shows that `alice` has been explicitly granted `rwx` permissions.

You might also see a new line called the **mask**. The mask acts as a filter, setting the maximum permissions that can be granted by any ACL entry. The final effective permission is the intersection of what's granted and what's in the mask.

For example, if the mask was `rw-`, `alice`'s effective permission would be `rw-`, even though she was granted `rwx`.

### How to Set and Delete ACLs with `setfacl`

The command for modifying ACLs is `setfacl`. The syntax is similar to `chmod` but with a few extra options.

#### Modifying an ACL (`-m`)

To give `alice` read and write permissions on the file `my_report.txt`, you would use the `-m` (modify) option:

```
setfacl -m u:alice:rw- my_report.txt
```

#### Deleting an ACL (`-x`)

To remove a specific ACL entry, you use the `-x` (remove) option. You don't need to specify the permissions, just the user or group.

```
setfacl -x u:alice my_report.txt
```

This command would remove the ACL entry for `alice`, and she would revert back to the `other` category's permissions.

#### Removing All ACLs (`-b`)

Finally, to completely remove all ACLs from a file, you can use the `-b` option, which stands for `remove all`.

```
setfacl -b my_report.txt
```

This will strip the file of all extended permissions and return it to the basic owner, group, and others setup.

With `getfacl` and `setfacl`, you have a powerful way to manage file access with a level of control that goes far beyond the traditional permission system. This is what makes ACLs an indispensable tool for advanced Linux administration.

{% include comment.html %}