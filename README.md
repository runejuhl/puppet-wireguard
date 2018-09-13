# puppet-wireguard

This module manages wireguard tunnels see https://www.wireguard.com/ and man
wg(8) for details.

This fork is based on
[flokli-wireguard](https://github.com/flokli/puppet-wireguard) with changes from
[IainDouglas/puppet-wireguard](https://github.com/IainDouglas/puppet-wireguard).

## Supported distributions
 - Debian (Jessie and later)
 - Ubuntu (Xenial and later)
 - CentOS/RedHat etc (Version 7 and later)

## General
 The module
 - Manages tunnel config files in the /etc/wiregurad directory.
 - Manages systemd service definitions wg-quick@

## Examples

### Puppet

```puppet
wireguard::tunnel { 'wg0':
  ensure      => 'present',
  private_key => 'tt+t0QwwaCJMEvdadSB/j+y1pB24pZoYZbvY4hVi6H8=',
  listen_port => 9909,
  address     => '192.0.2.1/24',
  peers       => {
    peer1 => {
      public_key  => 'Z+G/H8Zg+nUnLtaFgTDBsBi0ma0GnfIi96t4zMPnZCc=',
      allowed_ips => [
        '192.0.2.101/32',
      ],
      endpoint    => 'example.com:58886',
    }
  }
}
```

### Hiera

```yaml
wireguard::tunnels:
  wg0:
    private_key: 'tt+t0QwwaCJMEvdadSB/j+y1pB24pZoYZbvY4hVi6H8='
    listen_port: 12345
    address: '192.0.2.1/24'
    peers:
      peer1:
        public_key: 'Z+G/H8Zg+nUnLtaFgTDBsBi0ma0GnfIi96t4zMPnZCc='
        allowed_ips:
          - '192.0.2.101/32'

wireguard::simple_tunnels:
  wg20:
    private_key: 'tt+t0QwwaCJMEvdNbSB/j+y1pB29pZoYZbvY4hVi6H8='
    listen_port: 10101
    address: '192.0.2.1/24'
    peer_public_key: 'Z-G/H8Fg+nUnLtaTgfDBsBi0ma08nfIi96t4zMPnZCc='
    ensure: 'present'
    peer_allowed_ips:
      - '0.0.0.0/0'
    peer_endpoint: 'example.com:58886'
```

### Contributors

+ [Florian Klink](https://github.com/flokli)
+ [Iain Douglas](https://github.com/IainDouglas)
+ [Rune Juhl Jacobsen](https://github.com/runejuhl)
