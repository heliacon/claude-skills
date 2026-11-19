# Linux hardening checklist

Read when bringing up a new host or auditing an existing one. Apply before any workload runs. Each
section ends with the command that proves it.

## Contents
- SSH
- Firewall
- Users and sudo
- System and kernel
- CIS Level 1 extras
- Audit

## SSH

In `/etc/ssh/sshd_config` or a drop-in under `/etc/ssh/sshd_config.d/`:

```
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
AllowUsers deploy alice        # or AllowGroups ssh-users
MaxAuthTries 3
```

Order of work: add your key, test `sshd -t` (syntax), reload, then open a NEW session to confirm you
can still log in, and only then close the old one.

Prove it: `sshd -T | grep -Ei 'permitrootlogin|passwordauthentication|allowusers|maxauthtries'`.

## Firewall

- Default deny inbound. Allow only the ports the service needs, from source ranges where possible.
- Restrict outbound to known destinations for hosts that hold sensitive data (egress filtering limits
  what a compromised host can reach).
- Allow SSH BEFORE enabling the firewall (`ufw allow OpenSSH` then `ufw enable`).
- Cloud security groups and the host firewall are two layers. Keep both, and keep them consistent.

Prove it: `ufw status verbose` or `nft list ruleset`, plus a port scan from outside (`nmap -Pn <host>`)
showing only the expected ports.

## Users and sudo

- One account per person and per service. No shared logins.
- Sudo through groups, with `visudo` validation. No blanket `NOPASSWD: ALL` for people.
- Service accounts get `/usr/sbin/nologin` as shell and no home directory unless they need one.
- Remove accounts the day someone leaves, and rotate any credential they could reach (see the `devops`
  skill's secret rotation notes).

Prove it: `getent passwd | awk -F: '$7 !~ /nologin|false/'` lists only people who should log in.

## System and kernel

- Automatic security updates (unattended-upgrades or dnf-automatic), with a plan for reboots: kernel
  fixes do nothing until the host reboots.
- `net.ipv4.ip_forward = 0` unless the host routes. `net.ipv4.tcp_syncookies = 1`.
- `/tmp` and `/var/tmp` mounted `noexec,nosuid,nodev` where the workload allows.
- Time synchronised (chrony or systemd-timesyncd). Logs and tokens depend on it.

Prove it: `sysctl net.ipv4.ip_forward net.ipv4.tcp_syncookies`, `findmnt /tmp`, `timedatectl`.

## CIS Level 1 extras

The Center for Internet Security publishes a free benchmark per OS release. Use the one for the exact
distribution and version. Level 1 highlights:
- Disable services and network protocols the host does not use.
- `sshd_config` and `sudoers` readable only by root.
- `auditd` recording authentication, sudo use and changes to key files.
- Password policy for local accounts, even on key-only hosts.
- Restrict cron to an allow-list.
- Disable USB storage where physical access is a risk.

## Audit

```bash
lynis audit system
```

Read the warnings and suggestions, fix every High before production and save the report with the
change. Re-run after major upgrades.
