proxmox.conf:
  file.managed:
    - name: /etc/salt/cloud.providers.d/proxmox.conf
    - user: root
    - group: root
    - mode: '0644'
    - contents_pillar: proxmox:provider