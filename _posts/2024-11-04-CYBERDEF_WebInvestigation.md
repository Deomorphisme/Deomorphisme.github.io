---
title: Write-up — Web Investigation
date: 2024-11-04 08:50:00 PM
categories: [Write-up, CyberDefenders]
tags: [Cyberdefender, Write-up, ctf, Easy, Network Forensics, Wireshark]
image: 'assets/img/articles/CYBERDEF-Web investigation.webp'
description: This is a network forensics lab focused on packet inspection, as we follow the steps of a malicious actor who broke in by taking advantage of a vulnerable web application.
---

> Walkthrough of Lab **Web Investigation** from CyberDefenders:\
> [https://cyberdefenders.org/blueteam-ctf-challenges/web-investigation/](https://cyberdefenders.org/blueteam-ctf-challenges/web-investigation/)

This is a network forensics lab focused on packet inspection, as we follow the steps of a malicious actor who broke in by taking advantage of a vulnerable web application.

---
First thing first, download the lab file (`WebInvestigation.pcap`), the password is `cyberdefenders.org`. Open it in **Wireshark** and we are ready.

## Question 1
> By knowing the attacker's IP, we can analyze all logs and actions related to that IP and determine the extent of the attack, the duration of the attack, and the techniques used. *Can you provide the attacker's IP?*

To answer this question, we will go to Statistics sections and watch the all conversations
`Statistics > Conversations > IPv4`

![Suspicious IP](assets/img/2024-11-04-CYBERDEF-WebInvestigation/1_suspicious_ip.png)
_Suspicious IP_

The amount of data exchange give us the suspicious IP.

## Question 2
> If the geographical origin of an IP address is known to be from a region that has no business or expected traffic with our network, this can be an indicator of a targeted attack. *Can you determine the origin city of the attacker?*

Visit the website and copy-paste the suspicious IP: `https://whatismyipaddress.com`

![City of origin of the suspicious IP](assets/img/2024-11-04-CYBERDEF-WebInvestigation/2_suspicious_ip_location.png)
_City of origin of the suspicious IP_

Now that we've got the city of origin, let's take a closer look at the pcap file.

## Question 3
> Identifying the exploited script allows security teams to understand exactly which vulnerability was used in the attack. This knowledge is critical for finding the appropriate patch or workaround to close the security gap and prevent future exploitation. *Can you provide the vulnerable script name?*

To simplify the inspection, we gonna do some filtering. In the search bar (a.k.a. filter bar), type the **IP address of the suspicious IP** and the protocol we want to focus on **HTTP**.
Apply the following filter: `ip.src == 111.224.250.131 and http`.

We didn't use `ip` or `ip.dst` here because they less accurate in this case. Think of a malicious actor who we want to make a first foot on an unknown system, he will make a lot requests to our server to understand how it works and find potential vulnerabilities.

![The vulnerable script](assets/img/2024-11-04-CYBERDEF-WebInvestigation/3_vulnerable_script.png)
_The vulnerable script_

Among the first files, we found our potentially vulnerable script. Without getting too far ahead of ourselves, we can say that there is an attempt of SQL injection(many SQL injection attempt).

## Question 4
> Establishing the timeline of an attack, starting from the initial exploitation attempt, *What's the complete request URI of the first SQLi attempt by the attacker?*

The framed text on the previous image is the URI.

## Question 5
> *Can you provide the complete request URI that was used to read the web server available databases?*

This time, we gonna use a different filter.
Remember the SQLi is attempted over HTTP requests and if the attacker manage to read the available databases means the SQLi probably works. Better still, the server returns a special code, HTTP code 200. We gonna apply a filter to only get the `HTTP 200 code` packets.

The filter: `ip.dst == 111.224.250.131 and http.response.code == 200`

We use `ip.dst` here because we are looking for the packet sent *by the server* to the malicious actor.

![Field to be expanded](assets/img/2024-11-04-CYBERDEF-WebInvestigation/4_the_field_to_look_at.png)
_Field to be expanded_
Make sure to expand the field `Line-based text data: text/html ...`, it contains the results of the HTTP GET of the malicious user.

After a few packets (I lie but not that much), I discover the packet related to the desired URI. See **packet no. 1525**. Expand the field `Hypertext Transfer Protocol` and you will find the URI.

![Available databases](assets/img/2024-11-04-CYBERDEF-WebInvestigation/5_databases.png)
_Available databases_

## Question 6
> Assessing the impact of the breach and data access is crucial, including the potential harm to the organization's reputation. _What's the table name containing the website users data?_

Same as step 5. See **packet no. 1553**. The databases found are `["admin", "books", "customers"]`.

## Question 7
> The website directories hidden from the public could serve as an unauthorized access point or contain sensitive functionalities not intended for public access. _Can you provide name of the directory discovered by the attacker?_

Probably related to the databases of **question no. 6**. This time, we'll use the following filter:
`ip.src == 111.224.250.131 and http.request.method == "POST"`

We use this filter because we are looking for a login attempt.

> POST is the standard method for sending connection information, thanks to its enhanced security and separation of data from the URL.\
> _ChatGPT_

![Post method packets](assets/img/2024-11-04-CYBERDEF-WebInvestigation/6_post_method_packets.png)
_Post method packets_

We also notice that, these POST request are login attempts.

![Login attempts](assets/img/2024-11-04-CYBERDEF-WebInvestigation/9_post_username_password.png)
_Login attempts_

## Question 8
> Knowing which credentials were used allows us to determine the extent of account compromise. _What's the credentials used by the attacker for logging in?_

We'll follow the *HTTP stream* of the first four packets.

![How to follow a HTTP/TCP stream](assets/img/2024-11-04-CYBERDEF-WebInvestigation/7_follow_the_stream.png)
_How to follow a HTTP/TCP stream_

3 of 4 packets lead to a *HTTP 200 invalid username or password*, and only one to *HTTP 302 Found*.

![Invalid username or password](assets/img/2024-11-04-CYBERDEF-WebInvestigation/8_http_response.png)
_HTTP 200 OK — Invalid username or password_

## Question 9
> We need to determine if the attacker gained further access or control on our web server. _What's the name of the malicious script uploaded by the attacker?_

The last answer can be answered by analyzing the last packet of question 7.
![Malicious script](assets/img/2024-11-04-CYBERDEF-WebInvestigation/11_malicious_script.png)
_Malicious script_

All flags down, mission passed.

![](https://media1.tenor.com/m/lQBJJmatxPYAAAAd/mission-accomplished-penguins.gif)

Be proud of what you’ve accomplished.

See you soon!

> “It takes 20 years to build a reputation and a few minutes of cyber-incident to ruin it.” – Stephane Nappo
