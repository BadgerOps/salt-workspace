include:
  - roles.base
{% for role in salt['grains.get']('roles', []) %}
  - roles.{{ role }}
{% endfor %}
