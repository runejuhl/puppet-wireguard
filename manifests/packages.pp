# Install wireguard packages for kernel module and tools
class wireguard::packages (
  # Wireguard tools only work with the kernel module with the same version; take
  # care if using `latest` as it may break the tools until the module has been
  # reloaded
  Variant[Enum['installed', 'latest', 'present'], String] $ensure = 'installed',
  # Containers (e.g. LXC) can use wireguard but usually have no way of loading
  # kernel modules and hence doesn't need the dkms packages
  Boolean $tools_only = false,
) {
  if $facts['osfamily'] == 'debian' {
    include apt

    $osname = $facts['os']['name']

    case $osname {
      'ubuntu' : {
        apt::source { 'wireguard' :
          location => "http://ppa.launchpad.net/wireguard/wireguard/${osname}",
          release  => $facts['lsbdistcodename'],
          repos    => 'main',
          key      => {
            'id'     => 'E1B39B6EF6DDB96564797591AE33835F504A1A25',
            'server' => 'pgp.mit.edu',
          },
          include  => {
            'src' => false,
          },
        }
        [Apt::Source['wireguard'], Class['apt::update']] -> Package<| title == 'wireguard-tools' |>
        [Apt::Source['wireguard'], Class['apt::update']] -> Package<| title == 'wireguard-dkms' |>
      }
      default : {
        apt::pin {'wireguard':
          packages => ['wireguard-dkms', 'wireguard-tools'],
          release  => 'experimental',
          priority => 501,
          require  => Apt::Source['debian_unstable'],
        }

        [Apt::Pin['wireguard'], Class['apt::update']] -> Package<| title == 'wireguard-dkms' |>
        [Apt::Pin['wireguard'], Class['apt::update']] -> Package<| title == 'wireguard-tools' |>
      }
    }
  }
  elsif $facts['osfamily'] == 'RedHat' {
    $os_version=$facts['os']['release']['major'] + 0
    if $os_version >= 7 {
      yumrepo { 'wireguard':
        baseurl  => 'https://copr-be.cloud.fedoraproject.org/results/jdoss/wireguard/epel-7-$basearch/',
        descr    => 'Copr repo for wireguard owned by jdoss',
        enabled  => '1',
        gpgcheck => '1',
        gpgkey   => 'https://copr-be.cloud.fedoraproject.org/results/jdoss/wireguard/pubkey.gpg',
      }

      package { 'epel-release':
        ensure => installed,
      }
    }
    else {
        fail ('Incorrect OS Version, 7 or greater required')
      }
  }

  unless $tools_only {
    package { 'wireguard-dkms':
      ensure => $ensure,
    }
  }

  package { 'wireguard-tools':
    ensure => $ensure,
  }

  file { '/etc/wireguard':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    purge   => true,
    recurse => true,
    require => Package['wireguard-tools'],
  }

}
