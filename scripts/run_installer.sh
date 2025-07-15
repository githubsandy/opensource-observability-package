#!/bin/bash
# filepath: scripts/run_installer.sh

set -e

# Check for Ansible, install if missing
if ! command -v ansible &> /dev/null; then
    echo "Ansible not found. Installing..."
    sudo apt-get update && sudo apt-get install -y ansible
fi

# Run the main playbook
ansible-playbook -i ansible/inventory.ini ansible/playbooks/install_stack.yml