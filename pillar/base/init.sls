#!yaml
# set our mine functions
mine_functions:
  # we build our /etc/hosts file off the private IP's
  network.ip_addrs:
    interface: eth1

motd:
  content: |

           #########################################################################################################
           #                                                                                                       #
           #            This host is managed by Salt. Configuration changes made directly will be lost.            #
           #                                                                                                       #
           #########################################################################################################
