# users formula - Manage system users and groups
#
# This formula creates and manages system users defined in pillar data.
# It demonstrates user management, SSH key deployment, and sudo access.
#
# Usage:
#   Include this formula in your role and configure users in pillar.

{% set users = salt['pillar.get']('users:managed', {}) %}

# Ensure required groups exist
{% for username, user in users.items() %}
{% if user.get('groups') %}
{% for group in user.get('groups', []) %}
{{ group }}_group:
  group.present:
    - name: {{ group }}
{% endfor %}
{% endif %}
{% endfor %}

# Create managed users
{% for username, user in users.items() %}
{{ username }}_user:
  user.present:
    - name: {{ username }}
    - shell: {{ user.get('shell', '/bin/bash') }}
    - home: {{ user.get('home', '/home/' + username) }}
    - createhome: True
    {% if user.get('uid') %}
    - uid: {{ user.uid }}
    {% endif %}
    {% if user.get('gid') %}
    - gid: {{ user.gid }}
    {% endif %}
    {% if user.get('groups') %}
    - groups: {{ user.groups }}
    {% endif %}
    {% if user.get('fullname') %}
    - fullname: {{ user.fullname }}
    {% endif %}

# Create .ssh directory
{{ username }}_ssh_dir:
  file.directory:
    - name: {{ user.get('home', '/home/' + username) }}/.ssh
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0700'
    - require:
      - user: {{ username }}_user

# Deploy SSH authorized keys if specified
{% if user.get('ssh_keys') %}
{{ username }}_authorized_keys:
  file.managed:
    - name: {{ user.get('home', '/home/' + username) }}/.ssh/authorized_keys
    - user: {{ username }}
    - group: {{ username }}
    - mode: '0600'
    - contents: |
        # Managed by Salt - do not edit manually
        {% for key in user.get('ssh_keys', []) %}
        {{ key }}
        {% endfor %}
    - require:
      - file: {{ username }}_ssh_dir
{% endif %}

# Configure sudo access if specified
{% if user.get('sudo') %}
{{ username }}_sudoers:
  file.managed:
    - name: /etc/sudoers.d/{{ username }}
    - user: root
    - group: root
    - mode: '0440'
    - contents: |
        # Managed by Salt
        {{ username }} ALL=(ALL) {% if user.get('sudo_nopasswd', False) %}NOPASSWD:{% endif %}ALL
    - require:
      - user: {{ username }}_user
{% endif %}
{% endfor %}

# Remove users that should be absent
{% set users_absent = salt['pillar.get']('users:absent', []) %}
{% for username in users_absent %}
{{ username }}_absent:
  user.absent:
    - name: {{ username }}
    - purge: True
{% endfor %}
