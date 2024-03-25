Pip pkg:
  pkg.installed:
    - name: python3-pip

Podman pkg:
  pkg.installed:
    - name: podman

Podman service:
  file.managed:
    - name: /etc/systemd/system/podman.service
    - source: salt://podman/podman.service

Podman socket:
  file.managed:
    - name: /etc/systemd/system/podman.socket
    - source: salt://podman/podman.socket
  service.running:
    - name: podman.socket
    - enable: true

Docker socket:
  file.symlink:
    - name: /var/run/docker.sock
    - target: /var/run/user/1000/podman/podman.sock

Docker python:
  pip.installed:
    - bin_env: /usr/bin/pip3
    - reload_modules: true
    - pkgs:
        - docker-py

restart_salt_minion:
  cmd.run:
    - name: 'salt-call service.restart salt-minion'
    - bg: true
    - onchanges:
      - pip: Docker python