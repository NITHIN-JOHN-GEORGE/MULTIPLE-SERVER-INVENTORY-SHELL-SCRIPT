#! /bin/bash

# SCRIPT TO GET INVENTORY OF MULTIPLE_SERVERS

# AUTHOR : NITHIN JOHN GEORGE

USER=ansible

# function to print header
# this fn will print # upto terminal size
# example : ################################................... upto terminal ending specified using tput col command
# tput cols ----> command to dispaly the number of colums on your terminal screen
# tput lines -----> command to dispaly the number of lines on your terminal screen

print_header()
{
printf "\n"
printf "#%.0s" $(seq 1  $(tput cols))
printf "\n"
printf "\n"
}

#function to center the specified message

centre()
{
message=$1
col=$(tput cols)
message_length=$(echo ${#1})
pre_space=$(($((col-message_length))/2))
print_header
printf " %.0s" $(seq 1 $pre_space)
printf "%s" "$1"
printf "\n"
print_header
}

# function to check if servers_list.txt file exists or not

check_server_list_file()
{
if [[ ! -e servers_list.txt ]]
then
centre " Please create <<servers_list.txt>> file which contains IP address of all servers "
exit 1
fi
}

sudo_status=$(sudo -v 2>/dev/null 1>/dev/null ; echo $?)

if [[ $(id -u) -eq 0 ]] || [[ $sudo_status -eq  0 ]]

then

centre "WELCOME TO SERVER INVENTORY SCRIPT ( Note : For this script to work there should be Passwordless authentication  b/w the servers )"

check_server_list_file

# We use server_info.csv to see the final inventory of all servers , so checking if it already exist , if exists then remove and create again.

rm -rf server_info.csv 1>/dev/null 2>/dev/null
touch server_info.csv


# Starting Loop for executing commands on each server in servers_list.txt file

while read server

do

centre " PLEASE WAIT QUERYING INFO ON $server"

sleep 2

# To check if netstat package is installed or not

ssh -n -o StrictHostKeyChecking=No -T $USER@$server which netstat &> /dev/null || { echo -e "\033[0;35mNetstat package not installed on server : $server. Please install with \"sudo yum install net-tools -y\" and rerun the script to obtain inventory \033[0m ." ; echo -e "\n" ; exit 3 ;  }


centre "SERVER INVENTORY OF $server" >> server_info.csv

#OS-DETAILS

R_OS_NAME=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo cat /etc/os-release | awk -F = 'NR==1 {print $2}' | tr -d '[""]')
R_HOSTNAME=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo hostname -f)
R_OS_VERSION=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server   sudo uname -p)
R_OS_KERNEL_VERSION=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo hostnamectl | awk -F : 'NR==9 {print $2}' | sed 's/^$//g')

#HYPERVISOR TYPE

R_HTYPE=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server  sudo dmidecode | grep "Product Name" | awk -F : 'NR==1 {print $2}' | sed 's/^$//g')

#HYPERVISOR MANUFACTURER :-

R_MANUFACTURER=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server  sudo dmidecode --type system | grep Manufacturer | awk -F : '{print $2}')
R_SERIAL_NO=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo dmidecode -s system-serial-number)

#PRODUCT NAME :-

R_PRODUCTNAME=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo dmidecode | grep "Product Name" | awk -F : 'NR==1 {print $2}' | sed 's/^$//g')

#CPU Info/Type

R_CPUI=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo cat /proc/cpuinfo | grep "model name" | awk -F : '{print $2}')
R_CPUMHZ=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo /usr/bin/lscpu | grep -i "CPU MHz" | awk -F : '{print $2}' | sed 's/^[ \t]*//')
R_CPU=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server  sudo top -b -n2 -d1 | grep "Cpu(s)" | tail -n1 | awk '{print $2+$4+$6}')
R_LOAD_AVERAGE=$(ssh -n  -o StrictHostKeyChecking=No -T $USER@$server sudo top -n 2 -b -d 2 |grep "load average" |tail -n 1 | awk '{print $10 $11 $12}')
R_CORES=$(ssh -n  -o StrictHostKeyChecking=No -T $USER@$server sudo nproc)

# MEMORY Usage

R_MEM_TOTAL=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo free -mh | grep "Mem" | awk '{print $2}')
R_MEM_USED=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo free -mh | grep "Mem" |  awk '{print $3}')
R_MEM_PERCENTAGE=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo free -m | grep "Mem" | awk '{print $3/$2 * 100}' | awk -F . '{print $1}')

# DISK

R_DISK=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo df -Ph | grep -vE 'Filesystem|tmpfs|/dev/sr0|cdrom' |  awk '{ printf  $1 " " $5 "\n" }' | column -t)

# UPTIME

R_UPTIME=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo uptime|egrep "day" ; [[ `echo $?` -eq 0 ]] && uptime|awk '{print $3,$4,$5,$6}' | tr "," " " || uptime|awk '{print $3}'| tr -d ',')

# SWAP DETAILS

R_SWAP_TOTAL=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo free -mh | grep "Swap" | awk '{print $2}')

R_SWAP_USED=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo free -mh | grep "Swap" | awk '{print $3}')

#R_SWAP_PERCENTAGE=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo free -m | grep "Swap" | awk '{print $3/$2 * 100}' | awk -F . '{print $1}')

#NETWORK INFORMATION

R_DNS_NAME_SERVERS=$( ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
R_HOSTNAME=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server hostname -f)
R_DNS_DOMAIN=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server hostname -d)
R_NETWORK_IP=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server hostname -i)
R_TOTAL_NETWORK_INTERFACES=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo netstat -i | awk '{print $1}' | egrep -v "Kernel|Iface|lo" | wc -l)
R_NETWORK_INTERFACES_LIST=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo netstat -i | awk '{print $1}' | egrep -v "Kernel|Iface|lo")

# SELINUX

R_SELINUX=$(ssh -n -o StrictHostKeyChecking=No -T $USER@$server sudo sestatus | grep -E "SELinux status:" | awk -F : '{print $2}' | sed -e 's/^[ \s]*//')


echo "OS DETAILS" >> server_info.csv
echo "==========" >> server_info.csv
echo "          " >> server_info.csv
echo "HOSTNAME : $R_HOSTNAME" >> server_info.csv
echo "OS_NAME: $R_OS_NAME" >> server_info.csv
echo "OS_VERSION: $R_OS_VERSION" >> server_info.csv
echo "OS_KERNEL_VERSION: $R_OS_KERNEL_VERSION" >> server_info.csv
echo "          " >> server_info.csv
echo "SERVER UPTIME" >> server_info.csv
echo "=============" >> server_info.csv
echo "             " >> server_info.csv
echo "UPTIME : $R_UPTIME" >> server_info.csv
echo "             " >> server_info.csv
echo "HYPERVISOR DETAILS" >> server_info.csv
echo "==================" >> server_info.csv
echo "                  "  >> server_info.csv
echo "HYPERVISOR : $R_HTYPE" >> server_info.csv
echo "MANUFACTURER :$R_MANUFACTURER" >> server_info.csv
echo "SERIAL NO :$R_SERIAL_NO" >> server_info.csv
echo "PRODUCT NAME : $R_PRODUCTNAME"  >> server_info.csv
echo "          " >> server_info.csv
echo "NETWORK DETAILS" >> server_info.csv
echo "==================" >> server_info.csv
echo "                  "  >> server_info.csv
echo "DNS_NAME_SERVERS: $R_DNS_NAME_SERVERS" >> server_info.csv
echo "DNS_DOMAIN :$R_DNS_DOMAIN" >> server_info.csv
echo "NETWORK-IP :$R_NETWORK_IP" >> server_info.csv
echo "TOTAL-NETWORK-INTERFACES :$R_TOTAL_NETWORK_INTERFACES" >> server_info.csv
echo "NETWORK-INTERFACES LIST :$R_NETWORK_INTERFACES_LIST"  >> server_info.csv
echo "                          " >> server_info.csv
echo "SELINUX STATUS" >> server_info.csv
echo "=============" >> server_info.csv
echo "             " >> server_info.csv
echo "SELINUX STATE : $R_SELINUX" >> server_info.csv
echo "             " >> server_info.csv
echo "CPU DETAILS" >> server_info.csv
echo "==========" >> server_info.csv
echo "          " >> server_info.csv
echo "CPU TYPE : $R_CPUI" >> server_info.csv
echo "CPU SPEED IN MHz : $R_CPUMHZ " >> server_info.csv
echo "CPU USAGE : $R_CPU %" >> server_info.csv
echo "LOAD AVERAGE : $R_LOAD_AVERAGE" >> server_info.csv
echo "NO OF CORES : $R_CORES"
echo "          " >> server_info.csv
echo "MEMORY DETAILS" >> server_info.csv
echo "==============" >> server_info.csv
echo "              " >> server_info.csv
echo "TOTAL MEMORY : $R_MEM_TOTAL" >> server_info.csv
echo "USED MEMORY : $R_MEM_USED " >> server_info.csv
echo "MEMORY USAGE : $R_MEM_PERCENTAGE %" >> server_info.csv
echo "          " >> server_info.csv
echo "DISK DETAILS" >> server_info.csv
echo "==============" >> server_info.csv
echo "              " >> server_info.csv
echo "$R_DISK" >> server_info.csv
echo "              " >> server_info.csv
echo "SWAP DETAILS" >> server_info.csv
echo "============" >> server_info.csv
echo "            " >> server_info.csv
echo "TOTAL SWAP : $R_SWAP_TOTAL" >> server_info.csv
echo "USED SWAP : $R_SWAP_USED" >> server_info.csv
#echo "SWAP USAGE : $R_SWAP_PERCENTAGE"

centre " DONE "

done < servers_list.txt


centre " PLEASE GO TO server_info.csv in $(pwd) to SEE SERVER INVERTORY"
centre "Thank You for using Inventory Script" >> server_info.csv


else

echo "Sorry u cannot run this script as you are not an root user or the user doesnt have sudo privileges"

fi