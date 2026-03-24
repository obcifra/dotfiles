# Executing 

To execute a playbook:

```bash
./play <playbook-file.yml>
```

## Drafts

The following plays have not yet migrated to an Ansible playbook.

### Draft: Installing a new Template
```bash
# dom0
qvm-temlate install <template-name>
```

### Draft: Create Disposable VM Template
```bash
# dom0
qvm-create --template <template-name> --label red <template-name-dvm>
qvm-prefs <template-name-dvm> template_for_dispvms True
qvm-features <template-name-dvm> appmenus-dispvm 1
```

### Draft: Install Yubikey Manager
In a disposable VM:
```bash 
sudo dnf install python3 python3-pip python3-devel
sudo dnf install swig pcsc-lite-devel
pip install --user yubikey-manager
```

### Draft: Generate Client Keys
```bash
# Local key
ssh-keygen -o -a 100 -t ed25519 -f ~/.ssh/id_ed25519 -C "user@hostname"

# U2F/FIDO Security Key
ssh-keygen -t ed25519-sk -O resident -C "user@hostname"
```

### Draft: Rotate Host Keys
```bash
mkdir /etc/ssh/default_keys
mv /etc/ssh/ssh_host_* /etc/ssh/default_keys/
dpkg-reconfigure openssh-server
```

### Draft: Configure sshd on Host
In `/etc/ssh/sshd_config`:

```
PubkeyAuthentication yes
PasswordAuthentication no
```

### Draft: Add User Keys to Host
```bash
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@hostname
```
