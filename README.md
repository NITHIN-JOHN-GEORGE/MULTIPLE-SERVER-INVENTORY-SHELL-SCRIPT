## Description

It's a bash script to show a complete inventory of an Linux OS and it might be useful for Linux system/support engineers who lot of servers in daily life . Instead of manually executing all the commands on each of server which is hell lot of task to do , you can execute this script and this script generates all needed inventory to a file which you can mail to your manager.

This is a small project done by me after studying shell scripting and i have used mix of different concepts like functions , conditional statements , loops , exit status , command chaining , and used different text processing commands like awk ,sed , grep , cut etc ... 


----

## Feature
The script will collect informations from OS such as :

- OS Details ( such as Hostname , OS_name , OS_version , OS_Kernel_Version )
- Hypervisor Details
- CPU Details ( such as No of cores , CPU type , CPU usage , Load Average of server)
- Memory Details
- Disk Detais
- Network Detail ( like IP address , DNS SERVERS , DNS_DOMAIN , Total no of interfaces , List of interfaces )
- SELINUX status
- SWAP details

---
## Pre-Requestes 

- netstat package must be available
- Passwordless SSH authentication b/w servers
  ( Note If you are using password environment u have to use sshpass utility to provide password )
- Common user accross all servers
- Sudo privilege to that user
  


> This script currently supports only rhel 7.x and 8.x (ubuntu servers will be added in future release)
 
----
## How to use this script

```sh
- Create a user common in all servers and make passwordless authentication connection b/w the servers. (Give sudo access to the user)

- Switch to that user.

- git clone https://github.com/NITHIN-JOHN-GEORGE/MULTIPLE-SERVER-INVENTORY-SHELL-SCRIPT.git 

- cd MULTIPLE-SERVER-INVENTORY-SHELL-SCRIPT

- chmod +x MULTIPLE_SERVER_INVENTORY.sh

- Create a servers_list.txt with updated list of server in which you need inventory. 

- Update the username in the script starting

  USER=<username>

- ./MULTIPLE_SERVER_INVENTORY.sh
```

## Script Running

![SCRIPT RUNNING](https://user-images.githubusercontent.com/96073033/147854106-56067071-e8a2-4687-b2d8-37d371b23824.JPG)

## Output

![OUTPUT 1](https://user-images.githubusercontent.com/96073033/147854305-ce43c539-89bc-4b45-bc9e-a31978e33737.JPG)
![OUTPUT 2](https://user-images.githubusercontent.com/96073033/147854307-d8d17f3f-ef47-461c-b8d5-9400822dc2ca.JPG)
![OUTPUT 3](https://user-images.githubusercontent.com/96073033/147854309-560ea8a4-955c-4b4f-9e15-9a496d522911.JPG)
![OUTPUT 4](https://user-images.githubusercontent.com/96073033/147854318-9a0cfc35-28aa-40d0-a98b-f32bfbe57762.JPG)
