include:
  - salt.minion
{% if grains['kernel'] == 'Windows' %}
  - base.windows
{% else %}
  - base.linux
{% endif %} # End kernel/OS check.
