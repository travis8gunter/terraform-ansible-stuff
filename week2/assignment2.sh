#!/bin/bash

ssh_opts="-o StrictHostKeyChecking=no"
ip=$1
selection=$2
user=$3

one() {
    if ping -c 1 $ip &>/dev/null; then
        echo "$ip is awake."
    else
        echo "$ip is not awake"
    fi
}

two() {
    local status=$(ssh $ssh_opts $user@$ip "systemctl status apache2 | grep 'Active:' | awk '{ print \$2 }'")
    echo "$status"
}

three() {
    local percentage=$(ssh $ssh_opts $user@$ip "df | grep -E '/$' | awk '{ print \$5 }'")
    echo "$percentage"
}

four() {
    local hostname=$(ssh $ssh_opts $user@$ip "hostname")
    echo "$hostname"
}

five() {
    local users_count=$(ssh $ssh_opts $user@$ip "who | wc -l")
    echo "$users_count"
}

main() {
    if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
        echo "Missing required arguments."
        echo "Usage: $0 <IP address> <Selection> <Username>"
        exit 1
    fi

    case $selection in
        1) one ;;
        2) two ;;
        3) three ;;
        4) four ;;
        5) five ;;
        *) echo "Invalid selection. Please choose a number between 1-5."; exit 1 ;;
    esac
}

[[ "$0" == "${BASH_SOURCE[0]}" ]] && main "$@" || true
