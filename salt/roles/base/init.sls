include:
  - motd


/etc/foo.txt:
  file.managed:
    - user: root
    - group: root
    - mode: '0754'
    - contents_pillar: pillarenv
