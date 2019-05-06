# The wireguard::tunnel resource creates a wireguard interface with given
# private key, listen port and peer list. This is done by adding a
# configuration file inside /etc/wireguard, and enabling and starting the
# wg-quick@ service, installed by wireguard::packages.
#
# === Parameters
#
# [*private_key*]
# String - the private key for the tunnel interface
#
# [*address*]
# String - Interface address.
#
# [*listen_port*] (optional)
# Integer - port on which port wireguard should listen for incoming
#           connections.  Chosen randomly if not specified.
#
# [*dns_servers*] (optional)
# String - Comma separated list of IPv4, IPv6 addresses to use as nameservers
#          for the interface.
#
# [*preup_command*] (optional)
# String - Script snipplets that will be executed by bash(1) before the interface
#          is brought up
#
# [*postup_command*] (optional)
# String - Script snipplets that will be executed by bash(1) after the interface
#          is brought up
#
# [*predown_command*] (optional)
# String - Script snipplets that will be executed by bash(1) before the interface
#          is taken down
#
# [*postdown_command*] (optional)
# String - Script snipplets that will be executed by bash(1) after the interface
#          is taken down
#
# [*mtu*] (optional)
# Integer - Override the default MTU for the interface.
#
# [*save_config*] (optional)
# Boolean - When enabled save the interface config to the config file When
#           the interface is stopped. If this is set to true it makes no sense
#           to manage the config file using puppet so the file will not be
#           changed once this is enabled.
#
# [*table*] (optional)
# String - Set the routingtable to add routes to.
#          Off - disable route creation
#          Auto - (default) use default table
#
# [*fwmark*] (optional)
# Integer - 32bit integer to use as an fwmark on outgoing packets. Prefix with
#           0x for hexadecimal
#
# [*peers*] (optopnal)
# Array of peers each can contain
#
# [*peer*]
#         [*public_key*]
#         String - Pblic key of the peer.
#
#         [allowed_ips] (optional)
#         Array - an array of IPv4 / IPv6 addresses with CIDR masks from which
#                 incoming traffic for this peer is allowed and to which
#                 outgoing traffic for this peer is directed.
#
#         [*endpoint*] (optional)
#         String - An endpoint IP or hostname, followed by a colon, and then
#                  a port number. This endpoint will be updated automatically to
#                  the most recent source IP address and port of correctly
#                  authenticated packets from the peer.
#
#         [*preshared_key*] (optional)
#         String - a base64 preshared key generated by wg genpsk.
#
#         [*comment*] (optional)
#         String - A comment to add to the file.
#
#         [*persistent_keepalive*] (optional)
#         Integer - a seconds interval, between 1 and 65535 inclusive default 25
#
define wireguard::tunnel (
  Wireguard::Base64                    $private_key,
  Stdlib::Host                         $address,
  Optional[Stdlib::Port]               $listen_port      = undef,
  Optional[Array[Stdlib::IP::Address]] $dns_servers      = undef,
  Optional[String]                     $preup_command    = undef,
  Optional[String]                     $postup_command   = undef,
  Optional[String]                     $predown_command  = undef,
  Optional[String]                     $postdown_command = undef,
  Optional[Integer[0,default]]         $mtu              = undef,
  Optional[Integer]                    $fwmark           = undef,
  Optional[String]                     $table            = undef,
  Boolean                              $save_config      = false,
  Enum['present','absent']             $ensure           = 'present',
  Hash[String, Struct[
    {
      public_key           => Wireguard::Base64,
      endpoint             => Optional[String],
      allowed_ips          => Optional[Array[Wireguard::CIDR]],
      preshared_key        => Optional[String],
      comment              => Optional[String],
      persistent_keepalive => Optional[Integer[0-65535]],
    }
  ]]                                   $peers            = {},
) {

  include wireguard::packages

  $peers.each |$key, $value| {
    if($value['public_key'] == undef) {
      fail('public key is mandatory for each peer')
    }
  }

  # It makes no sense to update a config file it contains the SaveConfig
  # directive so do nothing if this is the case, except if we are explicityly
  # removing the directive.
  unless $facts.dig('wireguard_saveconfig_custom', $title) and $save_config {
    file { "/etc/wireguard/${title}.conf":
      ensure  => $ensure,
      content => epp('wireguard/config.epp', {
        private_key => $private_key,
        listen_port => $listen_port,
        address     => $address,
        save_config => $save_config,
        dns_servers => $dns_servers,
        preup       => $preup_command,
        postup      => $postup_command,
        predown     => $predown_command,
        postdown    => $postdown_command,
        mtu         => $mtu,
        fwmark      => $fwmark,
        table       => $table,
        peers       => $peers.map |$key, $value| {
          {
            'public_key'           => $value['public_key'],
            'endpoint'             => $value['endpoint'],
            'allowed_ips'          => ($value['allowed_ips'] != undef) ? { true => $value['allowed_ips'], default => '0.0.0.0/0, ::/0'},
            'preshared_key'        => $value['preshared_key'],
            'comment'              => $value['comment'],
            'persistent_keepalive' => ($value['persistent_keepalive'] != undef) ? { true => $value['persistent_keepalive'], default => 25},
          }
        },
      }),
                    notify  => Service["wg-quick@${title}.service"],
                    }
                    service { "wg-quick@${title}.service":
                    ensure  => if $ensure { 'running' } else { 'stopped' },
                    enable  => if $ensure { true } else { false },
                    require => File["/etc/wireguard/${title}.conf"],
                    }
  }
  else {
    file { "/etc/wireguard/${title}.conf":
      ensure  => $ensure,
    }
  }
}
