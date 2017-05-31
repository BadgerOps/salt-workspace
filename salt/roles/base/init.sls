include:
  - motd


/tmp/encrypted_file.txt:
  file.managed:
    - contents: {{ salt['pillar.get']('encrypted:file') }}
