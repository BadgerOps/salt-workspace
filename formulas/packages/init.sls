# packages formula - Install common system packages
#
# This formula installs a configurable list of packages defined in pillar.
# It demonstrates how to use pillar data with loops in Salt states.
#
# Usage:
#   Include this formula in your role and configure packages in pillar.
#
# Pillar example:
#   packages:
#     install:
#       - vim
#       - curl
#       - wget

{% set packages = salt['pillar.get']('packages:install', []) %}

{% if packages %}
install_common_packages:
  pkg.installed:
    - pkgs:
      {% for pkg in packages %}
      - {{ pkg }}
      {% endfor %}
{% endif %}

# Remove unwanted packages if specified
{% set packages_remove = salt['pillar.get']('packages:remove', []) %}

{% if packages_remove %}
remove_unwanted_packages:
  pkg.removed:
    - pkgs:
      {% for pkg in packages_remove %}
      - {{ pkg }}
      {% endfor %}
{% endif %}
