disable_firewall:
  win_firewall.disabled: []

disable-automatic-updates:
  windows_updates.settings:
    - level: {{ salt['pillar.get']('windows_update_level', 3) }}

npp:
  pkg.installed:
    - version: '6.8.8'

7zip:
  pkg.installed:
    - version: '9.20.00.0'

