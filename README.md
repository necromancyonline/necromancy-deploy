# necromancy-deploy

https://server.wizardry-online.com

IP:
```
DropletIp: 159.65.228.70
FloatingIp: 159.203.158.107
```

DNS:
```
Record - Host            - Value
A      - server          - 159.65.228.70
A      - www.server      - 159.65.228.70
A      - ssh             - 159.203.158.107
A      - mail            - 159.65.228.70
TXT    - _dmarc          - v=DMARC1; p=reject; adkim=s; aspf=s; pct=100;
TXT    - mail._domainkey - v=DKIM1; p=AAAAB3NzaC1yc2EAAAADAQABAAABAQDRFKMyv1O3UWSNg/mZHLXm6knF2RfTimYflc4IJtkRn3ouVx+MP9nAlvKqpU8vCx0Lj8l5gScXqdh7VqSZV1PQ3lIliiwVLAr2RUFawHBfPshmq1rqnI1YouTJ1+bCsiq34t3HP9bnqBXTf742AO1Lf04eyIClJFpAf5hKdwlVLW5VZzez2mNaxSbGsUOeboJPW1tgYDJlaTPviz+JSK6VXRvmspkZw7GtfCvDdcIS38cZS9jo3ojXkg8wxif9GpdrR4NQfnEWvM0tC4ATTgHVsInsAOHZQUJieJU56cAE7IjfyFEngS+TNfMSXFE6wnhdyCXmDpI5Q4z/G9wx+vp9
TXT    -                 - v=spf1 ip4:159.65.228.70 include:mail.wizardry-online.com -all
MX     - mail            - mail.wizardry-online.com
```

Logs:
```
--view logs
journalctl -u necromancy-server

-- end (displays logs at the end)
journalctl -u necromancy-server -e

-- follow (view logs at end and update with incomming)
journalctl -u necromancy-server -f

-- clear logs
journalctl --rotate
journalctl --vacuum-time=1s
```

Service:
```
systemctl status necromancy-server
systemctl start necromancy-server
systemctl stop necromancy-server
systemctl restart necromancy-server
```

SSH Key

```
ssh-keygen -t rsa -C "your_email@example.com"

--two files should be generated:
C:\Users\YOURNAME\.ssh\id_rsa     -> private key, never share with anyone!
C:\Users\YOURNAME\.ssh\id_rsa.pub -> public key

--will be created after first connection
C:\Users\YOURNAME\.ssh\known_hosts -> includes a list of all servers you trust
```

SSH
```
--connect to the server
ssh root@ssh.wizardry-online.com
```

Add new key to server
```
--this is a list of allowed public keys to connect, add a new key to this file or remove one to manage access
~/.ssh/authorized_keys
```

Vi Editor (https://www.cs.colostate.edu/helpdocs/vi.html)
```
--opens the file with vi
vi ~/file.ext
```

Directory
```
--lists dirs and files
ls

--changes to dir
cd /var/necromancy

--changes to home dir (~ represents home dir)
cd ~
```

Deploy `live` branch to server
```
--1) log into the server
ssh root@ssh.wizardry-online.com

--2) cd into home drive
cd ~

--3) check for 'necromancy-deploy'-folder
ls

--3.A) if 'necromancy-deploy'-folder does *not* exist, clone this repo, else continue with step 4
git clone https://github.com/necromancyonline/necromancy-deploy.git

--4) cd into 'necromancy-deploy'-folder
cd necromancy-deploy

--5) pull latest updates
git pull

--5) run deployment script (as root)
sudo ./deploy.sh

```
