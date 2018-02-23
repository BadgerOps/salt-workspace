#!pyobjects

# the purpose of this builder is to create a hostfile in the following format:
# 1.2.3.4    hostname    hostname.domain
# we have a couple custom grains that register the domain, and the IP of minions
# we'll use salt-mine to grab these grains and use them to build the host file

# first, set the network dictionary (key/value stores) from information stored in salt-mine
# the syntax is mine('host or grain lookup' 'mine_function')
# in this case we're matching on '*' for all hosts
# example of the dictionary are as follows:
# network = {'saltmaster': ['192.168.50.4'], 'linux-1': ['192.168.50.5']}

# minion_mine_update:
#   local.mine.update:
#     - tgt: {{ data['id'] }}
__salt__['mine.update']('*')

network = mine('*', 'network.ip_addrs')

for hostname in network.keys():
    hostname_short = hostname.split('.')[0] # set the non-fqdn hostname
    domain = hostname.split('.')[1] # pull out the domain, does not include .com
    # finally, build the hostfile
    Host.only(
      #hostname_short,
      name=network[hostname], # network.ip_addrs returns a list of IP's, even if its only 1 addr
      hostnames=[
            '%s-int.%s.com' % (hostname_short, domain), # hostname.domain aka FQDN
            '%s-int' % hostname_short, # just hostname
            hostname_short
            ]
    )
