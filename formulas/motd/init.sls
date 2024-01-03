motd:
  file.managed:
    - name: /etc/motd
    - user: root
    - group: root
    - mode: '0644'
    - contents_pillar: motd:content
