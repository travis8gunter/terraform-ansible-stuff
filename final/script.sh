#!/bin/bash

START_IP="$1"
SSH_USER="$2"
ACTION="${3:-create}"  # Default action is to create VMs, 'remove' is optional
VM_USER="d00345455"
VM_SERVER="vm.cs.utahtech.edu"
VLAN="2093"
RAM="2093"  # RAM in MB
DISK="10"  # Disk size in GB
CPU="1"    # Number of CPUs
DHCP_FILE="dhcp.txt"
SSH_OPTIONS="-o StrictHostKeyChecking=no"



# Prompt user for input
echo "Are you a new user? (yes/no)"
read new_user_response

if [[ "$new_user_response" != "yes" ]]; then
    echo "Returning user detected. Exiting setup."
    exit 0
fi

echo "Type your desired username:"
read user_name

echo "Where do you want your stack? (aws/local)"
read vm_type

echo "What do you want for your tech stack? (php/nodejs)"
read tech_stack

# Combine username and tech stack for a unique identifier
unique_identifier="${user_name}-${tech_stack}"

#---------------------------AWS-STUFF--------------------------
# Generate dynamic inventory based on deployment type
if [[ "$vm_type" == "aws" ]]; then
    # Create a Terraform variables file
    echo "Creating Terraform variables file..."
    cat <<EOF > settings.tfvars
developer_name = "$unique_identifier"
tech_stack     = "$tech_stack"
EOF

    echo "Applying Terraform configuration..."
    terraform apply -auto-approve -var-file=settings.tfvars
    echo "[aws]" > aws_inventory.ini
    ip_address=$(terraform output -json instance_ips | jq -r '.[]')
    echo "$ip_address ansible_user=ubuntu" >> aws_inventory.ini

    if [[ "$tech_stack" == "nodejs" ]]; then
        playbook="aws_nodejs_playbook.yml"
    elif [[ "$tech_stack" == "php" ]]; then
        playbook="aws_php_playbook.yml"
    fi

    # Run Ansible playbook for AWS
    echo "Running Ansible playbook for AWS..."
    ansible-playbook -i aws_inventory.ini $playbook
#-----------------------------LOCAL_STUFF-------------------------
elif [[ "$vm_type" == "local" ]]; then
    echo "Provisioning on local server..."
    vm_name="${user_name}-${tech_stack}-${START_IP}"
    echo "Creating VM: $vm_name"

    # Create VM and boot it
    ssh $SSH_OPTIONS "$VM_USER@$VM_SERVER" "/qemu/bin/citv createvm $vm_name $RAM $DISK $VLAN $CPU"
    ssh $SSH_OPTIONS "$VM_USER@$VM_SERVER" "/qemu/bin/citv bootvm $vm_name c"

    sleep 10

    # Fetch the IP address dynamically assigned by DHCP
    vm_ip=$(ssh $SSH_OPTIONS "$VM_USER@$VM_SERVER" "/qemu/bin/citv showvm $vm_name" | grep "IP Address" | awk '{print $4}')

    echo "VM Name: $vm_name"
    echo "IP Address: $vm_ip"
    echo "Username: $VM_USER"

    # Optionally, update local inventory for Ansible if needed
    echo "[local_vms]" > local_inventory.ini
    echo "$vm_name ansible_host=$vm_ip ansible_user=$VM_USER" >> local_inventory.ini

    playbook="local_${tech_stack}_playbook.yml"
    echo "Running Ansible playbook for local VMs..."
    ansible-playbook -i local_inventory.ini $playbook
else
    echo "Invalid selection. Exiting setup."
    exit 1
fi
