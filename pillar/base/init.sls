motd:
  content: |

           #########################################################################################################
           #                                                                                                       #
           #            This host is managed by Salt. Configuration changes made directly will be lost.            #
           #                                                                                                       #
           #########################################################################################################

proxmox:
  provider: |
          proxmox-config:
            user: <user>
            password: password
            #token: <token>
            url: <url>
            driver: proxmox
  
profile: |
         almalinux_small:
          - web1:
              minion:
                log_level: debug
              grains:
                foo: bar
        test-almalinux:
          - web1:
              minion:
                log_level: debug
              grains:
                foo: bar
        test-almalinux:
          provider: proxmox-config
          image: local:iso/AlmaLinux-9.3-x86_64-minimal.iso
          technology: qemu
          host: <host>
          password: <password>
          minion:
            master: salt
          script: bootstrap-salt
