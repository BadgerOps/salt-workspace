consul:
  service: True
  config:
    datacenter: VAGRANT
    {% if grains['nodename'] == 'saltmaster' %}
    server: True
    {% else %}
    server: False
    {% endif %}
    bind_addr: {{ grains['ip4_interfaces']['enp0s8'][0] }}
    start_join:
      - saltmaster
