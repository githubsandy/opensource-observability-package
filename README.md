# Open Source Observability Package

This repository provides an open-source observability package solution that allows users to easily install and configure essential monitoring and logging tools using Ansible automation.

## Features

- One-click installation script to set up the observability stack.
- Automated installation of Prometheus, Node Exporter, Loki, and Grafana.
- Checks for prerequisites and installs them if missing.

## Prerequisites

Before running the installation script, ensure that you have the following installed on your system:

- Linux or MacOS
- Python 3
- (On Mac) Homebrew
- sudo privileges for package installation

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/opensource-observability-package.git
   cd opensource-observability-package
   ```

2. Run the installation script:

   ```bash
   bash scripts/run_installer.sh
   ```

This script will check for Ansible, install it if necessary, and then execute the main Ansible playbook to install the observability tools in the specified order.

## Usage

After the installation is complete, you can access the following tools:

- **Prometheus**: Access it at `http://<your-server-ip>:9090`
- **Grafana**: Access it at `http://<your-server-ip>:3000` (default credentials: admin/admin)

## What Gets Installed

- **Prometheus**: Metrics collection
- **Node Exporter**: Host metrics
- **Loki**: Log aggregation
- **Grafana**: Visualization

## Customization

Edit the playbooks in `ansible/playbooks/` to customize versions or configuration.

## Troubleshooting

- Ensure you have sudo privileges.
- For Mac, Homebrew is required for Ansible install.

---

## How it Works

- The installer script checks for Ansible and installs it if missing.
- The main playbook (`install_stack.yml`) runs each tool’s playbook in order.
- Each playbook checks if the tool is already installed and skips installation if so.

---

## What You Might Still Want to Consider

### 1. System Prerequisites

- **Python 3**: Ansible requires Python 3 on the target machine (most modern systems have it).
- **Sudo privileges**: The script assumes the user can run `sudo` commands.
- **Network access**: The script downloads binaries from the internet.

### 2. Service Management

- The playbooks do not yet create or enable systemd service files for Prometheus, Node Exporter, or Loki. Without this, you’ll need to run the binaries manually after install.
- **Grafana** (when installed via apt) is set up as a service automatically.

### 3. Configuration Files

- The playbooks install binaries, but do not provide default configuration files for Prometheus, Loki, etc.  
  (You may want to add this for a true “ready-to-use” experience.)

### 4. Cross-Platform Support

- The current playbooks are written for Debian/Ubuntu.  
  For RedHat/CentOS or other OSes, you’d need to add tasks for those platforms.

### 5. User Experience

- For a true “one-click” experience, you could provide a `.desktop` launcher for Linux GUIs, or a double-clickable `.command` file for Mac, but most users will be fine running a shell script.

---