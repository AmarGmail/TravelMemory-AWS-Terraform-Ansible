# Travel Memory - AWS Deployment with Terraform and Ansible

**TravelMemory** - MERN application
**Terraform** -  infrastructure provisioning
**Ansible** - configuration management and application deployment
**AWS** - Deployment platform. It's a two Tier deployment.

The deployment separates the public web/application tier from the private MongoDB database tier. 
Nginx serves the React frontend and reverse-proxies API requests to the Node.js/Express backend.

## Architecture in a nut shell
Internet -> EC2 public IP - >AWS Internet Gateway - > Public Subnet (10.20.1.0/24) -> EC2 Web Server (on Ubuntu 24.04 LTS)
 |
                 +-----+------+
            
               Nginx       Express API
                 |          Port 3001
                 
React Frontend - > Private VPC subnet -> Private Subnet (10.20.2.0/24) - > 
EC2 MongoDB Database (on Ubuntu 24.04 LTS) -> MongoDB (Port 27017) 

**<u>Network security:</u>** The database instance has no public IP address. Database access is restricted through security-group rules, and MongoDB authentication is enabled.

**<u>Technology Stack</u>**

- Cloud: Amazon Web Services (AWS)
- Infrastructure as Code: Terraform
- Configuration Management: Ansible
- Compute: Amazon EC2
- Networking: VPC, public/private subnets,   Internet Gateway, route tables and security - groups
- Frontend: React
- Backend: Node.js and Express
- Database: MongoDB Community Edition
- Web Server / Reverse Proxy: Nginx
- Service Management: systemd
- Secrets Management: Ansible Vault

**Repository Structure**

TravelMemory/
├── terraform/
│   ├── ami.tf
│   ├── ec2.tf
│   ├── iam.tf
│   ├── network.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── security_groups.tf
│   ├── variables.tf
│   └── versions.tf
├── ansible/
│   ├── ansible.cfg
│   ├── inventory/
│   ├── group_vars/
│   ├── playbooks/
│   │   └── site.yml
│   ├── roles/
│   │   ├── common/
│   │   ├── database/
│   │   ├── travelmemory/
│   │   └── nginx/
│   ├── test-mongodb-auth.yml
│   ├── test-nginx.yml
│   ├── test-travelmemory-role.yml
│   └── vault/
├── backend/
├── frontend/
├── screenshots/
├── .gitignore
└── README.md

### Expected outcome of the app


## Prepare git repo
Create a clone from source repo
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible$ git clone https://github.com/UnpredictablePrashant/TravelMemory.git
Cloning into 'TravelMemory'...
remote: Enumerating objects: 122, done.
remote: Counting objects: 100% (73/73), done.
remote: Compressing objects: 100% (54/54), done.
remote: Total 122 (delta 35), reused 19 (delta 19), pack-reused 49 (from 1)
Receiving objects: 100% (122/122), 199.65 KiB | 1.41 MiB/s, done.
Resolving deltas: 100% (42/42), done.
```
Mark source repo as upstream
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory$ git remote rename origin upstream
Renaming remote references: 100% (4/4), done.
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory$ git remote -v
upstream        https://github.com/UnpredictablePrashant/TravelMemory.git (fetch)
upstream        https://github.com/UnpredictablePrashant/TravelMemory.git (push)
```
Create repo with github and upload the code
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory$ gh repo create AmarGmail/TravelMemory-AWS-Terraform-Ansible \
> --public \
> --source=. \
> --remote=origin \
> --push
✓ Created repository AmarGmail/TravelMemory-AWS-Terraform-Ansible on GitHub
  https://github.com/AmarGmail/TravelMemory-AWS-Terraform-Ansible
✓ Added remote https://github.com/AmarGmail/TravelMemory-AWS-Terraform-Ansible.git
Enumerating objects: 122, done.
Counting objects: 100% (122/122), done.
Delta compression using up to 4 threads
Compressing objects: 100% (71/71), done.
Writing objects: 100% (122/122), 199.65 KiB | 99.83 MiB/s, done.
Total 122 (delta 42), reused 122 (delta 42), pack-reused 0
remote: Resolving deltas: 100% (42/42), done.
To https://github.com/AmarGmail/TravelMemory-AWS-Terraform-Ansible.git
 * [new branch]      HEAD -> main
branch 'main' set up to track 'origin/main'.
✓ Pushed commits to https://github.com/AmarGmail/TravelMemory-AWS-Terraform-Ansible.git
```
git prepared state before infra setup -
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory$ git remote -v
origin  https://github.com/AmarGmail/TravelMemory-AWS-Terraform-Ansible.git (fetch)
origin  https://github.com/AmarGmail/TravelMemory-AWS-Terraform-Ansible.git (push)
upstream        https://github.com/UnpredictablePrashant/TravelMemory.git (fetch)
upstream        https://github.com/UnpredictablePrashant/TravelMemory.git (push)
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory$ git branch --show-current
main
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory$ git status
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

## #Part-1: Infrastructure Setup with Terraform

Create a dedicated key-pair for this assigment
```
aws ec2 create-key-pair \
  --profile alahkar37-user \
  --region us-east-1 \
  --key-name travelmemory-lab-key \
  --key-type ed25519 \
  --query 'KeyMaterial' \
  --output text > ~/.ssh/travelmemory-lab-key.pem
```
Provision AWS infrastructure. Initially, terraform failed due to syntax error in iam.tf at creating IAM role which was corrected and run terraform apply again to complete the infra provisioning in AWS platform.
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/terraform$ terraform apply travelmemory.tfplan
aws_iam_role.ec2: Creating...
aws_eip.nat: Creating...
aws_vpc.main: Creating...
aws_eip.nat: Creation complete after 4s [id=eipalloc-0606a07c75a318fc3]
aws_vpc.main: Creation complete after 6s [id=vpc-0a13c9e66340e6856]
aws_internet_gateway.main: Creating...
aws_subnet.private: Creating...
aws_subnet.public: Creating...
aws_security_group.web: Creating...
aws_subnet.private: Creation complete after 2s [id=subnet-0b73db5c3ed6ac5ce]
aws_internet_gateway.main: Creation complete after 2s [id=igw-063396d81c6aad794]
aws_route_table.public: Creating...
aws_route_table.public: Creation complete after 1s [id=rtb-0c450a9f517493c52]
aws_security_group.web: Creation complete after 5s [id=sg-04e953cedfac7ea79]
aws_security_group.db: Creating...
aws_subnet.public: Still creating... [00m09s elapsed]
aws_security_group.db: Creation complete after 5s [id=sg-09fd0f82805d715ba]
aws_subnet.public: Creation complete after 11s [id=subnet-0d7fbe94f60ac89ee]
aws_route_table_association.public: Creating...
aws_nat_gateway.main: Creating...
aws_route_table_association.public: Creation complete after 1s [id=rtbassoc-0fdf7eebead4da58f]
aws_nat_gateway.main: Still creating... [00m10s elapsed]
aws_nat_gateway.main: Still creating... [00m20s elapsed]
aws_nat_gateway.main: Still creating... [00m29s elapsed]
aws_nat_gateway.main: Still creating... [00m39s elapsed]
aws_nat_gateway.main: Still creating... [00m49s elapsed]
aws_nat_gateway.main: Still creating... [00m58s elapsed]
aws_nat_gateway.main: Still creating... [01m08s elapsed]
aws_nat_gateway.main: Still creating... [01m18s elapsed]
aws_nat_gateway.main: Still creating... [01m27s elapsed]
aws_nat_gateway.main: Creation complete after 1m36s [id=nat-0b2a77930dc1f97ab]
aws_route_table.private: Creating...
aws_route_table.private: Creation complete after 2s [id=rtb-070cdd129180c0db0]
aws_route_table_association.private: Creating...
aws_route_table_association.private: Creation complete after 1s [id=rtbassoc-07d0d5dc76ba15526]
╷
│ Error: creating IAM Role (travelmemory-ec2-role): operation error IAM: CreateRole, https response error StatusCode: 400, RequestID: dbffb4b6-672b-4a91-9362-abd6b2feede7, MalformedPolicyDocument: Syntax error at position (1,83)
│
│   with aws_iam_role.ec2,
│   on iam.tf line 15, in resource "aws_iam_role" "ec2":
│   15: resource "aws_iam_role" "ec2" {
│
╵
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/terraform$ terraform apply travelmemory.tfplan
aws_iam_role.ec2: Creating...
aws_iam_role.ec2: Creation complete after 3s [id=travelmemory-ec2-role]
aws_iam_role_policy_attachment.ssm_core: Creating...
aws_iam_instance_profile.ec2: Creating...
aws_iam_role_policy_attachment.ssm_core: Creation complete after 3s [id=travelmemory-ec2-role/arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore]
aws_iam_instance_profile.ec2: Still creating... [00m10s elapsed]
aws_iam_instance_profile.ec2: Creation complete after 10s [id=travelmemory-ec2-profile]
aws_instance.db: Creating...
aws_instance.web: Creating...
aws_instance.db: Still creating... [00m10s elapsed]
aws_instance.web: Still creating... [00m10s elapsed]
aws_instance.db: Creation complete after 18s [id=i-0be7cf059073c2b26]
aws_instance.web: Creation complete after 18s [id=i-017eb13b95de53d63]

Apply complete! Resources: 5 added, 0 changed, 0 destroyed.

Outputs:

db_private_ip = "10.20.2.43"
selected_ami_id = "ami-02a9cdd4e98bc3c78"
selected_ami_name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20261017"
web_public_dns = "ec2-35-175-110-90.compute-1.amazonaws.com"
web_public_ip = "35.175.110.90"
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/terraform$ terraform output
db_private_ip = "10.20.2.43"
selected_ami_id = "ami-02a9cdd4e98bc3c78"
selected_ami_name = "ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20261017"
web_public_dns = "ec2-35-175-110-90.compute-1.amazonaws.com"
web_public_ip = "35.175.110.90"
```
Get EC2 instances IP addresses for both WEB and DB tier - 
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/terraform$ aws ec2 describe-instances \
  --instance-ids i-017eb13b95de53d63 i-0be7cf059073c2b26 \
  --query 'Reservations[].Instances[].[InstanceId,State.Name,PrivateIpAddress,PublicIpAddress]' \
  --output table
-------------------------------------------------------------------
|                        DescribeInstances                        |
+----------------------+----------+-------------+-----------------+
|  i-017eb13b95de53d63 |  running |  10.20.1.78 |  35.175.110.90  |
|  i-0be7cf059073c2b26 |  running |  10.20.2.43 |  None           |
+----------------------+----------+-------------+-----------------+
```

## #Part II: Ansible 

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible --version
ansible [core 2.16.3]
  config file = /home/hi/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible/ansible.cfg
  configured module search path = ['/home/hi/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/hi/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Aug 31 2026, 10:18:26) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True
  ```
  ```
  hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-inventory --graph
  @all:
    |--@ungrouped:
    |--@web:
  |  |--web1
  |--@database:
  |  |--db1
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-inventory --list
{
    "_meta": {
        "hostvars": {
            "db1": {
                "ansible_host": "10.20.2.43",
                "ansible_python_interpreter": "/usr/bin/python3",
                "ansible_ssh_common_args": "-o ProxyJump=ubuntu@35.175.110.90",
                "ansible_ssh_private_key_file": "~/.ssh/travelmemory-lab-key.pem",
                "ansible_user": "ubuntu"
            },
            "web1": {
                "ansible_host": "35.175.110.90",
                "ansible_python_interpreter": "/usr/bin/python3",
                "ansible_ssh_private_key_file": "~/.ssh/travelmemory-lab-key.pem",
                "ansible_user": "ubuntu"
            }
        }
    },
    "all": {
        "children": [
            "ungrouped",
            "web",
            "database"
        ]
    },
    "database": {
        "hosts": [
            "db1"
        ]
    },
    "web": {
        "hosts": [
            "web1"
        ]
    }
}
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -m ansible.builtin.ping
web1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
```
db1 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook playbooks/site.yml

PLAY [Inspect the web server] ******************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [Display web server operating system] *****************************************************************************
ok: [web1] => {
    "msg": "Host web1 runs Ubuntu 24.04"
}

PLAY [Inspect the database server] *************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [db1]

TASK [Display database server operating system] ************************************************************************
ok: [db1] => {
    "msg": "Host db1 runs Ubuntu 24.04"
}

PLAY RECAP *************************************************************************************************************
db1                        : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
web1                       : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook playbooks/site.yml

PLAY [Prepare all servers] *********************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]
ok: [db1]

TASK [common : Update APT package index] *******************************************************************************
changed: [web1]
changed: [db1]

TASK [common : Install common prerequisite packages] *******************************************************************
ok: [web1]
ok: [db1]

PLAY RECAP *************************************************************************************************************
db1                        : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
web1                       : ok=3    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook playbooks/site.yml --limit database

PLAY [Prepare all servers] *********************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [db1]

TASK [common : Update APT package index] *******************************************************************************
ok: [db1]

TASK [common : Install common prerequisite packages] *******************************************************************
ok: [db1]

PLAY [Configure database server] ***************************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [db1]

TASK [database : Install MongoDB repository prerequisites] *************************************************************
ok: [db1]

TASK [database : Download MongoDB repository signing key] **************************************************************
changed: [db1]

TASK [database : Ensure keyring directory exists] **********************************************************************
ok: [db1]

TASK [database : Convert MongoDB signing key to GPG keyring format] ****************************************************
changed: [db1]

TASK [database : Set MongoDB keyring permissions] **********************************************************************
ok: [db1]

TASK [database : Configure MongoDB APT repository] *********************************************************************
changed: [db1]

TASK [database : Install MongoDB Community Edition] ********************************************************************
changed: [db1]

TASK [database : Enable and start MongoDB] *****************************************************************************
changed: [db1]

TASK [database : Verify MongoDB version] *******************************************************************************
ok: [db1]

TASK [database : Display MongoDB version] ******************************************************************************
ok: [db1] => {
    "mongodb_version_result.stdout_lines": [
        "db version v8.0.34",
        "Build Info: {",
        "    \"version\": \"8.0.34\",",
        "    \"gitVersion\": \"51db4515a6597aedcf6188ee4e48a27e65b065ae\",",
        "    \"openSSLVersion\": \"OpenSSL 3.0.13 30 Jan 2024\",",
        "    \"modules\": [],",
        "    \"allocator\": \"tcmalloc-google\",",
        "    \"environment\": {",
        "        \"distmod\": \"ubuntu2404\",",
        "        \"distarch\": \"x86_64\",",
        "        \"target_arch\": \"x86_64\"",
        "    }",
        "}"
    ]
}

PLAY RECAP *************************************************************************************************************
db1                        : ok=14   changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook test-travelmemory-role.yml

PLAY [Test TravelMemory role on web server] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js repository prerequisites] *********************************************************
ok: [web1]

TASK [travelmemory : Download Node.js repository signing key] **********************************************************
ok: [web1]

TASK [travelmemory : Ensure keyring directory exists] ******************************************************************
ok: [web1]

TASK [travelmemory : Install NodeSource signing key] *******************************************************************
ok: [web1]

TASK [travelmemory : Set NodeSource signing key permissions] ***********************************************************
ok: [web1]

TASK [travelmemory : Configure Node.js 24 repository] ******************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js and bundled npm] ******************************************************************
changed: [web1]

PLAY RECAP *************************************************************************************************************
web1                       : ok=8    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -m ansible.builtin.command -a "node --version"
web1 | CHANGED | rc=0 >>
v24.22.1
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -m ansible.builtin.command -a "npm --version"
web1 | CHANGED | rc=0 >>
11.19.1
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook test-travelmemory-role.yml

PLAY [Test TravelMemory role on web server] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js repository prerequisites] *********************************************************
ok: [web1]

TASK [travelmemory : Download Node.js repository signing key] **********************************************************
ok: [web1]

TASK [travelmemory : Ensure keyring directory exists] ******************************************************************
ok: [web1]

TASK [travelmemory : Install NodeSource signing key] *******************************************************************
ok: [web1]

TASK [travelmemory : Set NodeSource signing key permissions] ***********************************************************
ok: [web1]

TASK [travelmemory : Configure Node.js 24 repository] ******************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js and bundled npm] ******************************************************************
ok: [web1]

TASK [travelmemory : Create TravelMemory backend directory] ************************************************************
ok: [web1]

TASK [travelmemory : Deploy TravelMemory backend source files] *********************************************************
changed: [web1]

PLAY RECAP *************************************************************************************************************
web1                       : ok=10   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -m ansible.builtin.command \
  -a "find /opt/travelmemory/backend -maxdepth 3 -type f"
web1 | CHANGED | rc=0 >>
/opt/travelmemory/backend/package-lock.json
/opt/travelmemory/backend/routes/trip.routes.js
/opt/travelmemory/backend/index.js
/opt/travelmemory/backend/controllers/trip.controller.js
/opt/travelmemory/backend/conn.js
/opt/travelmemory/backend/models/trip.model.js
/opt/travelmemory/backend/package.json
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook test-travelmemory-role.yml
[WARNING]: Collection community.general does not support Ansible version 2.16.3

PLAY [Test TravelMemory role on web server] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js repository prerequisites] *********************************************************
ok: [web1]

TASK [travelmemory : Download Node.js repository signing key] **********************************************************
ok: [web1]

TASK [travelmemory : Ensure keyring directory exists] ******************************************************************
ok: [web1]

TASK [travelmemory : Install NodeSource signing key] *******************************************************************
ok: [web1]

TASK [travelmemory : Set NodeSource signing key permissions] ***********************************************************
ok: [web1]

TASK [travelmemory : Configure Node.js 24 repository] ******************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js and bundled npm] ******************************************************************
ok: [web1]

TASK [travelmemory : Create TravelMemory backend directory] ************************************************************
ok: [web1]

TASK [travelmemory : Deploy TravelMemory backend source files] *********************************************************
ok: [web1]

TASK [travelmemory : Install TravelMemory backend dependencies] ********************************************************
changed: [web1]

PLAY RECAP *************************************************************************************************************
web1                       : ok=11   changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook test-travelmemory-role.yml --ask-vault-pass
Vault password:
[WARNING]: Collection community.general does not support Ansible version 2.16.3

PLAY [Test TravelMemory role on web server] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js repository prerequisites] *********************************************************
ok: [web1]

TASK [travelmemory : Download Node.js repository signing key] **********************************************************
ok: [web1]

TASK [travelmemory : Ensure keyring directory exists] ******************************************************************
ok: [web1]

TASK [travelmemory : Install NodeSource signing key] *******************************************************************
ok: [web1]

TASK [travelmemory : Set NodeSource signing key permissions] ***********************************************************
ok: [web1]

TASK [travelmemory : Configure Node.js 24 repository] ******************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js and bundled npm] ******************************************************************
ok: [web1]

TASK [travelmemory : Create TravelMemory backend directory] ************************************************************
ok: [web1]

TASK [travelmemory : Deploy TravelMemory backend source files] *********************************************************
ok: [web1]

TASK [travelmemory : Install TravelMemory backend dependencies] ********************************************************
changed: [web1]

TASK [travelmemory : Configure TravelMemory backend environment] *******************************************************
changed: [web1]

PLAY RECAP *************************************************************************************************************
web1                       : ok=12   changed=2    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0

hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -m ansible.builtin.command \
  -a "stat -c '%U:%G %a %n' /opt/travelmemory/backend/.env"
web1 | CHANGED | rc=0 >>
root:root 600 /opt/travelmemory/backend/.env
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -b -m ansible.builtin.command \
  -a "cut -d= -f1 /opt/travelmemory/backend/.env"
web1 | CHANGED | rc=0 >>
PORT
MONGO_URI
```

```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook test-travelmemory-role.yml --ask-vault-pass
Vault password:
[WARNING]: Collection community.general does not support Ansible version 2.16.3

PLAY [Test TravelMemory role on web server] ****************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js repository prerequisites] *********************************************************
ok: [web1]

TASK [travelmemory : Download Node.js repository signing key] **********************************************************
ok: [web1]

TASK [travelmemory : Ensure keyring directory exists] ******************************************************************
ok: [web1]

TASK [travelmemory : Install NodeSource signing key] *******************************************************************
ok: [web1]

TASK [travelmemory : Set NodeSource signing key permissions] ***********************************************************
ok: [web1]

TASK [travelmemory : Configure Node.js 24 repository] ******************************************************************
ok: [web1]

TASK [travelmemory : Install Node.js and bundled npm] ******************************************************************
ok: [web1]

TASK [travelmemory : Create TravelMemory backend directory] ************************************************************
ok: [web1]

TASK [travelmemory : Deploy TravelMemory backend source files] *********************************************************
ok: [web1]

TASK [travelmemory : Install TravelMemory backend dependencies] ********************************************************
changed: [web1]

TASK [travelmemory : Create TravelMemory service group] ****************************************************************
changed: [web1]

TASK [travelmemory : Create TravelMemory service user] *****************************************************************
changed: [web1]

TASK [travelmemory : Configure TravelMemory backend environment] *******************************************************
changed: [web1]

TASK [travelmemory : Install TravelMemory backend systemd service] *****************************************************
changed: [web1]

RUNNING HANDLER [travelmemory : Restart TravelMemory backend] **********************************************************
changed: [web1]

PLAY RECAP *************************************************************************************************************
web1                       : ok=16   changed=6    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

App deployment status:
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -m ansible.builtin.uri \
  -a "url=http://127.0.0.1:3001/hello method=GET status_code=200"
web1 | SUCCESS => {
    "access_control_allow_origin": "*",
    "changed": false,
    "connection": "close",
    "content_length": "12",
    "content_type": "text/html; charset=utf-8",
    "cookies": {},
    "cookies_string": "",
    "date": "Thu, 22 Oct 2026 18:50:12 GMT",
    "elapsed": 0,
    "etag": "W/\"c-Lve95gjOVATpfV8EL5X4nxwjKHE\"",
    "msg": "OK (12 bytes)",
    "redirected": false,
    "status": 200,
    "url": "http://127.0.0.1:3001/hello",
    "x_powered_by": "Express"
}
```
service logs
```
i@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -b -m ansible.builtin.command \
  -a "journalctl -u travelmemory-backend.service -n 30 --no-pager"
web1 | CHANGED | rc=0 >>
Oct 22 18:47:46 ip-10-20-1-78 systemd[1]: Started travelmemory-backend.service - TravelMemory Node.js Backend.
Oct 22 18:47:47 ip-10-20-1-78 node[16737]: Server started at http://localhost:3001
```
INstall nginx:
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible-playbook test-nginx.yml

PLAY [Deploy TravelMemory frontend and Nginx] **************************************************************************

TASK [Gathering Facts] *************************************************************************************************
ok: [web1]

TASK [nginx : Install Nginx] *******************************************************************************************
changed: [web1]

TASK [nginx : Create TravelMemory web root] ****************************************************************************
changed: [web1]

TASK [nginx : Deploy React production build] ***************************************************************************
changed: [web1]

TASK [nginx : Install TravelMemory Nginx configuration] ****************************************************************
changed: [web1]

TASK [nginx : Disable default Nginx site] ******************************************************************************
changed: [web1]

TASK [nginx : Enable TravelMemory Nginx site] **************************************************************************
changed: [web1]

TASK [nginx : Ensure Nginx is enabled and running] *********************************************************************
ok: [web1]

RUNNING HANDLER [nginx : Reload Nginx] *********************************************************************************
changed: [web1]

PLAY RECAP *************************************************************************************************************
web1                       : ok=9    changed=7    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -b -m command -a "nginx -t"
web1 | CHANGED | rc=0 >>
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
```
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -b -m shell -a \
  "stat -c '%a %U:%G %n' /var/www/travelmemory/index.html"
web1 | CHANGED | rc=0 >>
644 root:root /var/www/travelmemory/index.html
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -b -m uri -a \
  "url=http://127.0.0.1/ status_code=200 return_content=no"
web1 | SUCCESS => {
    "accept_ranges": "bytes",
    "changed": false,
    "connection": "close",
    "content_length": "1062",
    "content_type": "text/html",
    "cookies": {},
    "cookies_string": "",
    "date": "Thu, 22 Oct 2026 19:40:51 GMT",
    "elapsed": 0,
    "etag": "\"6ada62ad-426\"",
    "last_modified": "Thu, 22 Oct 2026 19:23:25 GMT",
    "msg": "OK (1062 bytes)",
    "redirected": false,
    "server": "nginx/1.24.0 (Ubuntu)",
    "status": 200,
    "url": "http://127.0.0.1/"
}
hi@USER:~/projects/herovired/assignments/MERN-Terraform-Ansible/TravelMemory/ansible$ ansible web -b -m uri -a \
  "url=http://127.0.0.1/trip/ status_code=200 return_content=yes"
web1 | SUCCESS => {
    "access_control_allow_origin": "*",
    "changed": false,
    "connection": "close",
    "content": "[]",
    "content_length": "2",
    "content_type": "application/json; charset=utf-8",
    "cookies": {},
    "cookies_string": "",
    "date": "Thu, 22 Oct 2026 19:41:01 GMT",
    "elapsed": 0,
    "etag": "W/\"2-l9Fw4VUO7kr8CvBlt4zaMCqXZ0w\"",
    "json": [],
    "msg": "OK (2 bytes)",
    "redirected": false,
    "server": "nginx/1.24.0 (Ubuntu)",
    "status": 200,
    "url": "http://127.0.0.1/trip/",
    "x_powered_by": "Express"
}
```

###common — prepare both servers.

###database — configure MongoDB on the private DB server.

###travelmemory — deploy the backend on the web server.

###nginx — deploy the frontend and configure the reverse proxy.

###Play 1 — Prepare all servers: common prerequisites on both EC2 instances.

###Play 2 — Configure database server: MongoDB setup on db1.

###Play 3 — Deploy TravelMemory application on web server: backend deployment first, followed by Nginx and the frontend.

```
-------------------------------------------------------------------------------------------------------------------------------------------------
|                                                               DescribeInstances                                                               |
+---------------------+----------------------------+-------------------+--------------+----------------+-----------+----------------------------+
|     InstanceId      |        LaunchTime          |       Name        |  PrivateIP   |   PublicIP     |   State   |          Subnet            |
+---------------------+----------------------------+-------------------+--------------+----------------+-----------+----------------------------+
|  i-0d9c10401b236ed91|  2026-10-23T12:36:18+00:00 |  travelmemory-web |  10.20.1.109 |  44.195.88.225 |  running  |  subnet-0d7fbe94f60ac89ee  |
|  i-0599b6841dc355028|  2026-10-23T12:36:18+00:00 |  travelmemory-db  |  10.20.2.244 |  None          |  running  |  subnet-0b73db5c3ed6ac5ce  |
+---------------------+----------------------------+-------------------+--------------+----------------+-----------+----------------------------+
```
## **#NAT-Gateway** and Outbound Connectivity
The NAT Gateway was initially provisioned by Terraform and later deleted manually from AWS, together with its Elastic IP, to remove the associated cost. This was performed after MongoDB server that residing in private subnet configured and tested. THe objective is to reduce the cost assiciated with a NAT gateway.
The application continued working because ordinary web requests use the Internet Gateway to reach the public web server, while the backend connects to MongoDB through private VPC networking.



`.env` file to work with the backend after creating a database in mongodb: 

```
MONGO_URI='ENTER_YOUR_URL'
PORT=3001
```

Data format to be added: 

```json
{
    "tripName": "Incredible India",
    "startDateOfJourney": "19-03-2022",
    "endDateOfJourney": "27-03-2022",
    "nameOfHotels":"Hotel Namaste, Backpackers Club",
    "placesVisited":"Delhi, Kolkata, Chennai, Mumbai",
    "totalCost": 800000,
    "tripType": "leisure",
    "experience": "Lorem Ipsum, Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum,Lorem Ipsum, ",
    "image": "https://t3.ftcdn.net/jpg/03/04/85/26/360_F_304852693_nSOn9KvUgafgvZ6wM0CNaULYUa7xXBkA.jpg",
    "shortDescription":"India is a wonderful country with rich culture and good people.",
    "featured": true
}
```


For frontend, you need to create `.env` file and put the following content (remember to change it based on your requirements):
```bash
REACT_APP_BACKEND_URL=http://localhost:3001
```

## How to run BE

Note: Make sure you have the .env file already added
```bash
cd backend
npm install
node index.js
```

## How to run FE
Note: Make sure you have the .env file already added
```bash
cd frontend
npm install
npm start
```
