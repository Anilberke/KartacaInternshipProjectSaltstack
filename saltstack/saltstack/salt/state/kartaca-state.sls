# saltstack/salt/kartaca-state.sls

{% set kartaca_password = salt['pillar.get']('kartaca:password') %}

# Her iki sunucuda ortak işlemler
create_kartaca_user:
  user.present:
    - name: kartaca
    - uid: 2023
    - gid: 2023
    - home: /home/krt
    - shell: /bin/bash
    - password: {{ kartaca_password }}

grant_sudo_privileges:
  cmd.run:
    - name: |
        if [ -f /etc/sudoers.d/kartaca ]; then
          echo "kartaca ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/kartaca
        fi

set_timezone:
  timezone.system:
    - name: Europe/Istanbul

enable_ip_forwarding:
  sysctl.persist:
    - name: net.ipv4.ip_forward
    - value: 1

install_required_packages:
  pkg.installed:
    - names:
      - htop
      - tcptraceroute
      - iputils
      - bind-utils
      - sysstat
      - mtr

add_hashicorp_repo:
  cmd.run:
    - name: curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    - unless: test -f /etc/apt/sources.list.d/hashicorp.list
  file.managed:
    - name: /etc/apt/sources.list.d/hashicorp.list
    - source: salt://files/hashicorp.list
    - template: jinja

install_terraform:
  pkg.installed:
    - name: terraform
    - version: 1.6.4
    - fromrepo: hashicorp

add_hosts_entries:
  file.blockreplace:
    - name: /etc/hosts
    - marker_start: "# Salt added entries"
    - marker_end: "# Salt added entries end"
    - content: |
        192.168.168.128/28 kartaca.local
    - append_if_not_found: True

{% if grains['os_family'] == 'Debian' %}
  include:
    - kartaca-state-ubuntu
{% elif grains['os_family'] == 'RedHat' %}
  include:
    - kartaca-state-centos
{% endif %}
