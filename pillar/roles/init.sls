include:
  - roles.base
{%- for role in salt['grains.get']('roles', []) %}
{%- if ( salt['file.file_exists']('/srv/pillar/roles/{0}.sls'.format(role)) or salt['file.directory_exists']('/srv/pillar/roles/{0}'.format(role)) ) %}
  - roles.{{ role }}
{%- endif %}
{%- endfor %}
