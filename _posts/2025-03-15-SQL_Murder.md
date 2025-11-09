---
title: Walkthrough — SQL Murder Mystery
date: 2025-03-15 10:00:00 PM
categories: [Write-up]
tags: [SQL, ctf]
image: 'assets/img/2025-03-15-SQL_Murder/SQL_Murder_Mystery_Clue_Illustration.png'
description: SQL Murder Mystery is an interactive learning experience that combines SQL querying with a captivating detective narrative. Players take on the role of a detective tasked with solving a murder case by analyzing a SQL database containing various tables, such as crime scene reports, witness statements, and city records. By writing and executing SQL queries, participants uncover clues, establish connections, and ultimately identify the murderer. This engaging approach not only enhances SQL skills but also makes learning data analysis and querying techniques enjoyable and immersive.
---

> Walkthrough of SQL Murder Mystery :
> [https://mystery.knightlab.com/](https://mystery.knightlab.com/)

---

Crime: Murder at **SQL City** occurred on *Jan. 15 2018*.
Goal: Find the murderer of SQL City

## Finding the murderer
### Retrieving the witnesses id
**2 witnesses**
- **1st witness** lives at the last home of `Northwestern Dr`
```sql
select * from person where (address_street_name="Northwestern Dr") order by address_number DESC limit 1;
```

| id    | name           | license_id | address_number | address_street_name | ssn       |
| ----- | -------------- | ---------- | -------------- | ------------------- | --------- |
| 14887 | Morty Schapiro | 118009     | 4919           | Northwestern Dr     | 111564949 |

- **2nd witness** named `Annabel` lives on `Franklin Ave`
```sql
select * from person where (address_street_name="Franklin Ave" and name like "Annabel %");
```

| id    | name           | license_id | address_number | address_street_name | ssn       |
| ----- | -------------- | ---------- | -------------- | ------------------- | --------- |
| 16371 | Annabel Miller | 490173     | 103            | Franklin Ave        | 318771143 |

### Finding the interview of the witnesses

```sql
select person.id, person.name, interview.transcript from person
inner join interview
on person.id=interview.person_id
where (id=14887 or id=16371);
```

|id|name|transcript|
|---|---|---|
|14887|Morty Schapiro|I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. The membership number on the bag started with "48Z". Only gold members have those bags. The man got into a car with a plate that included "H42W".|
|16371|Annabel Miller|I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.|

**1st witness**
- Heard a gunshot
- Suspect wore a "get Fit Now Gym" bag => Own only by gold members
- Membership number starts with `"48Z"`
- Disappeared in a car with plate that included `"H42W"`

**2nd witness**
- Saw the murder happen
- Recognized the murdered from her gym
- Was working out on Jan. 9th 2018

### Retrieving evidences from "Get Fit Now Gym"

- *Getting Annabel gym id*

```sql
select id, person_id, name from get_fit_now_member where person_id=16371;
```

|id|person_id|name|
|---|---|---|
|90081|16371|Annabel Miller|

`id=90081`

- *Getting Annabel's check in check out time*

```sql
select * from get_fit_now_check_in
inner join get_fit_now_member
on get_fit_now_member.id = get_fit_now_check_in.membership_id 
where get_fit_now_member.person_id=16371 
and get_fit_now_check_in.check_in_date = 20180109;
```

|membership_id|check_in_date|check_in_time|check_out_time|id|person_id|name|membership_start_date|
|---|---|---|---|---|---|---|---|
|90081|20180109|1600|1700|90081|16371|Annabel Miller|20160208|

`check_in_time=1600 (16h) | check_out_time=1700 (17h)`

- *Getting all people present during this time slot (with gold membership +id starts with "48Z")*
Many combinations (<16 and >17 || >16 and <17 ||...), we will just try to get the people present the same day and visually select the corresponding people.

```sql
select * from get_fit_now_check_in
inner join get_fit_now_member
on get_fit_now_check_in.membership_id = get_fit_now_member.id
where get_fit_now_check_in.check_in_date=20180109
and get_fit_now_member.membership_status="gold"
and get_fit_now_member.id like "48Z%";
```

| membership_id | check_in_date | check_in_time | check_out_time | id    | person_id | name          | membership_start_date | membership_status |
| ------------- | ------------- | ------------- | -------------- | ----- | --------- | ------------- | --------------------- | ----------------- |
| 48Z7A         | 20180109      | 1600          | 1730           | 48Z7A | 28819     | Joe Germuska  | 20160305              | gold              |
| 48Z55         | 20180109      | 1530          | 1700           | 48Z55 | 67318     | Jeremy Bowers | 20160101              | gold              |

**Two suspects:**
*Joe Germuska*    id=28819  membership_id=48Z7A
*Jeremy Bowers*   id=67318  membership_id=48Z55

- *Now checking the driver_license table to find which one has the corresponding plate car*

```sql
select drivers_license.id, plate_number, car_make, car_model, person.name from drivers_license
inner join person
on person.license_id=drivers_license.id
where person.id=28819 or person.id=67318;
--no need to add `and plate_number like "%H42W%"` because only 2 suspects
```

|id|plate_number|car_make|car_model|name|
|---|---|---|---|---|
|423327|0H42W2|Chevrolet|Spark LS|Jeremy Bowers|

Only **Jeremy Bowers** left as a suspect. It seems Joe Germuska doesn't owns a car.
`plate number="0H42W2" | car make="Chevrolet" | car_model="Spark LS"`


- *Let's check the annual income of our suspect*
`annual income=$10500`
Hard to guess the motive! Seems not a killer for hire. May be police already interviewed him.

- *Let's check our suspect*

```sql
insert into solution VALUES (1, 'Jeremy Bowers');
select value from solution
```

```text
Congrats, you found the murderer! But wait, there's more... If you think you're up for a challenge, try querying the interview transcript of the murderer to find the real villain behind this crime. If you feel especially confident in your SQL skills, try to complete this final step with no more than 2 queries. Use this same INSERT statement with your new suspect to check your answer.
```

- The police interview

```sql
select transcript from interview where person_id=67318;
```

```text
# Tanscript

I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). She has red hair and she drives a Tesla Model S. I know that she attended the SQL Symphony Concert 3 times in December 2017.
```

**mybad! Killer for hire!**
- Hired by a woman with a lot money
- Around 5'5"(65") and 5'7"(67")
- Red hair
- Drive Tesla | Model S
- Attended "SQL Symphony Concert" 3 times in December 2017

## Finding the woman

```sql
select * from drivers_license
where hair_color="red"
and height between 65 and 67
and car_make="Tesla"
and car_model="Model S";
```

We got three suspects based on the hair color, the height and the car.

|id|age|height|eye_color|hair_color|gender|plate_number|car_make|car_model|
|---|---|---|---|---|---|---|---|---|
|202298|68|66|green|red|female|500123|Tesla|Model S|
|291182|65|66|blue|red|female|08CM64|Tesla|Model S|
|918773|48|65|black|red|female|917UU3|Tesla|Model S|

```sql
select person.id, person.name, person.address_street_name, income.annual_income, facebook_event_checkin.event_name, count(*) from person
inner join drivers_license on person.license_id=drivers_license.id
inner join income on person.ssn=income.ssn
INNER join facebook_event_checkin on person.id=facebook_event_checkin.person_id
where drivers_license.hair_color="red"
and drivers_license.height between 65 and 67
and drivers_license.car_make="Tesla"
and drivers_license.car_model="Model S"
and facebook_event_checkin.event_name="SQL Symphony Concert"
and facebook_event_checkin.date between 20171201 and 20171231
group by facebook_event_checkin.event_name;
```

| id    | name             | address_street_name | annual_income | event_name           | count(*) |
| ----- | ---------------- | ------------------- | ------------- | -------------------- | -------- |
| 99716 | Miranda Priestly | Golden Ave          | 310000        | SQL Symphony Concert | 3        |

It seems the red haired woman is `Miranda Priestly`.

**The truth**

```sql
insert into solution VALUES (1, 'Miranda Priestly');
select value from solution
```

```text
Congrats, you found the brains behind the murder! Everyone in SQL City hails you as the greatest SQL detective of all time. Time to break out the champagne!
```

---


- [4 others SQL game including SQL murder mystery](https://datalemur.com/blog/games-to-learn-sql#sql-police-department)


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
