type Wireguard::CIDR = Variant[
  Stdlib::IP::Address::V4::CIDR,
  Wireguard::IP::Address::V6::CIDR,
  Enum['0.0.0.0/0'],
]
