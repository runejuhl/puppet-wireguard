# The wireguard::simple tunnel resource is a wireguard::tunnel with only one
# peer. It uses wireguard::tunnel internally.
#
# @param private_key the private key used here
#
# @param listen_port on which port wireguard should listen for incoming
# connections. Chosen randomly if not specified.
#
# @param peer_public_key The public key of the one and only peer @param
#
# @param peer_allowed_ips An array of IP (v4 or v6) addresses with CIDR
# masks from which this peer is allowed to send incoming traffic and to which
# outgoing traffic for this peer is directed. Defaults to 0.0.0.0/0 and ::/0.
#
# @param peer_endpoint An endpoint IP or hostname, followed by a colon, and
# then a port number. This endpoint will be updated automatically to the most
# recent source IP address and port of correctly authenticated packets from the
# peer. Optional.

define wireguard::simple_tunnel (
  Wireguard::Base64                $private_key,
  Stdlib::Port                     $listen_port,
  Wireguard::Base64                $peer_public_key,
  Enum['present','absent']         $ensure           = 'present',
  Optional[Stdlib::Host]           $address          = undef,
  Optional[Array[Wireguard::CIDR]] $peer_allowed_ips = undef,
  Optional[String]                 $peer_endpoint    = undef,
) {

  wireguard::tunnel { $title:
    ensure      => $ensure,
    private_key => $private_key,
    listen_port => $listen_port,
    address     => $address,
    peers       => {
      other => {
        public_key  => $peer_public_key,
        allowed_ips => $peer_allowed_ips,
        endpoint    => $peer_endpoint,
      },
    },
  }
}
