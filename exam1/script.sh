#!/bin/bash

ip="144.38.215."

last_oct=150

#this is for what file you want it to read for users

sample_file="sample-test.txt"


usage() {
        echo "This is how you use this script"
        echo "<script name> <ip file> <user file>"
}

#checks if arguments are good
if ["$#" -ne 2]; then
        usage
        exit 1
fi


ip=$1
sample_file=$2


if [ ! -f "$sample_file" ]; then
        echo "no user file found"
        usage
        exit 1
fi


while read user
 do
         new_ip="${ip}${last_oct}"
         echo "${new_ip} user=${user}" >> inventory.txt
         ((last_oct++))
         echo "${user}-IT1100-${last_oct} IN A ${new_ip}" >> dns.txt
done < $sample_file
