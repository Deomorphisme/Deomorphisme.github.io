---
title: Write-up — WebStrike
date: 2024-11-05 09:57:00 PM
categories: [Write-up, CyberDefenders]
tags: [Cyberdefender, Write-up, ctf, Easy, Network Forensics, Wireshark]
image: 'assets/img/articles/CYBERDEF-WebStrike.webp'
description: This is a network forensics lab focused on packet inspection, as we follow the steps of a malicious actor who broke in by taking advantage of a vulnerable web application.
---

> Walkthrough of Lab **WebStrike** from CyberDefenders:\
> [https://cyberdefenders.org/blueteam-ctf-challenges/webstrike/](https://cyberdefenders.org/blueteam-ctf-challenges/webstrike/)

This is a network forensics lab focused on packet inspection, as we follow the steps of a malicious actor who broke in by taking advantage of a vulnerable web application.

---

First thing first, download the lab file (`c116-WebStrike.pcap`), the password is `cyberdefenders.org`. Open it in **Wireshark** and we are ready.

## Scenario
> An anomaly was discovered within our company's intranet as our Development team found an unusual file on one of our web servers. Suspecting potential malicious activity, the network team has prepared a pcap file with critical network traffic for analysis for the security team, and you have been tasked with analyzing the pcap.

## Question 1
> Understanding the geographical origin of the attack aids in geo-blocking measures and threat intelligence analysis. What city did the attack originate from?

The pcap file contains *2 IP addresses*. Knowing one is a web server, the other one must be the malicious actor. Since we only have two IP adresses, we can test both and conclude or we can use a filter.
Our server is not suppose to send requests to an user so we can filter our packet only get **HTTP GET requests**.

`http.request.method == "GET"`

![Attack IP](assets/img/2024-11-05-CYBERDEF-WebStrike/q1_attack_ip.png)
_Attack IP_

The source IP should be the malicious IP and the destination IP our web server.

A quick tour on: https://whatismyipaddress.com will help us to determine the originated city of the attack.

![](assets/img/2024-11-05-CYBERDEF-WebStrike/q1_attack_originated_city.png)
_City of origin_
## Question 2
> Knowing the attacker's user-agent assists in creating robust filtering rules. What's the attacker's user agent?

Now select any **HTTP GET packet** and expand the `Hypertext Transfer Protocol` section and the answer should in the `user-agent` field.

![](assets/img/2024-11-05-CYBERDEF-WebStrike/q2_user_agent.png)
_Attacker user-agent_
## Question 3
> We need to identify if there were potential vulnerabilities exploited. What's the name of the malicious web shell uploaded?

For this question, we gonna use a different filter. We're looking for a *file upload* so the most appropriate HTTP method is **POST**.

```bash
ip.src == 117.11.88.124 && http.request.method =="POST"
```

You should get only two packets:

![File uploading filter](assets/img/2024-11-05-CYBERDEF-WebStrike/q3_uploading_filter.png)
_File uploading filter_

![Follow the stream](assets/img/2024-11-05-CYBERDEF-WebStrike/q3_follow_the_stream.png)
_Follow the stream_

When we follow the stream of the first packet, we can find that the uploaded file **`image.php`** has been rejected because of the *file format*.
![](assets/img/2024-11-05-CYBERDEF-WebStrike/q3_invalid_file_format.png)
_Failed upload attempt_

The second packet leads us to the malicious script.
![](assets/img/2024-11-05-CYBERDEF-WebStrike/q3_file_uploaded_successfully.png)
_Uploaded file_

The attacker only change the extension from `.php` to `.jpg.php`. And frame in red, we can see a **Reverse Shell** script.
== meme laughing==
## Question 4
> Knowing the directory where files uploaded are stored is important for reinforcing defenses against unauthorized access. Which directory is used by the website to store the uploaded files?

In question no. 5, we can see a reverse shell script. It will be executed once the attacker has made a GET request for this script. So we'll look for all packets whose URI contains **`image.jpg.php`**.

```bash
http.request.uri contains "image.jpg.php"
```

We find only one packet.

![Compromised directory](assets/img/2024-11-05-CYBERDEF-WebStrike/q5_directory.png)
_Compromised directory_
## Question 5
> Identifying the port utilized by the web shell helps improve firewall configurations for blocking unauthorized outbound traffic. What port was used by the malicious web shell?

The web shell should be executed right after the **GET request**, packet no. 138. The reverse shell in question 3, shows us the destination **`port: 8080`**.
## Question 6
> Understanding the value of compromised data assists in prioritizing incident response actions. What file was the attacker trying to exfiltrate?

Now we can apply a new filter, then follow the stream, to see the entire exchange between the attacker and the web server.

```bash
tcp.dstport == 8080
```

At the end of the stream, we can see `curl -X POST` command that send data toward the attacker IP. It's a sign of **data exfiltration**.

![Exfiltrated file](assets/img/2024-11-05-CYBERDEF-WebStrike/q6_exfiltrated_file.png)
_Exfiltrated file_

All flags down, mission passed.

![Penguin claping hand](https://media1.tenor.com/m/lQBJJmatxPYAAAAd/mission-accomplished-penguins.gif)

Be proud of what you’ve accomplished.

See you soon!

> “There are only two different types of companies in the world: those that have been breached and know it and those that have been breached and don’t know it.” ― Ted Schlein

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
