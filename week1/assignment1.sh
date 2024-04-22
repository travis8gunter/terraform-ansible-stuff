#!/bin/bash

machine=$1
column=$2
myurl=$3


function main()
{
  get_file
  get_column
  make_dhcp
  make_dns
  show_output
}
function get_file()
{
  wget --quiet $myurl -O /tmp/sample.txt
}

function get_column() {
  value=$(tail -n +2 /tmp/sample.txt | grep $machine | awk -v col="$column" '{ print $col; }')
  echo $value
}

function show_output(){
  echo "Column ${column} for the machine $machine is:"
  get_column
}
function make_dhcp(){
  hostname=$(tail -n +3 /tmp/sample.txt | grep "$machine" | awk -v col="$column" '{print $1}')
  mac=$(tail -n +3 /tmp/sample.txt | grep "$machine" | awk -v col="$column" '{print $2}')
  ip=$(tail -n +3 /tmp/sample.txt | grep "$machine" | awk -v col="$column" '{print $3}')
}
function make_dns(){
  hostname=$(tail -n +3 /tmp/sample.txt | grep "$machine" | awk -v col="$column" '{print$1}')
  ip=$(tail -n +3 /tmp/sample.txt | grep "$machine" | awk -v col="$column" '{print $3}')
}

# do not run main when sourcing the script
[[ "$0" == "${BASH_SOURCE[0]}" ]] && main "$@" || true
#main
