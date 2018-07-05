# == Class: wireguard
#
# Installs and configures wireguard.
#
# === Parameters

class wireguard (
  Hash[String, Hash] $tunnels = {},
  Hash[String, Hash] $simple_tunnels = {},
  $install_only = false,
) {
  include wireguard::packages

  unless $install_only  {
    $tunnels.each |$name, $params| {
      wireguard::tunnel { $name:
        * => $params,
      }
    }
    $simple_tunnels.each |$name, $params| {
      wireguard::simple_tunnel { $name:
        * => $params,
      }
    }
  }
}
