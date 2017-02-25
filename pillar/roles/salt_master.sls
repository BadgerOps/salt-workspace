#!yaml
salt:
  master:
    hash_type: sha256
    file_roots:
      base:
        - /srv/salt
        - /srv/formulas
        - /srv/formulas/salt-formula
        - /srv/formulas/consul-formula
        - /srv/salt/roles
    pillar_roots:
      base:
        - /srv/pillar
    auto_accept: True
