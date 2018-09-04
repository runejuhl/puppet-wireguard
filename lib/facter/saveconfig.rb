=begin
If a wireguard config file contains saveconfig directive then
there is no point in updating it as puppet and wireguard both keep changing
the file. This creates custom facts that are used to decide whether puppet
should update a particular file.
=end
Facter.add(:wireguard_saveconfig_custom) do
  setcode do
    Dir.glob('/etc/wireguard/*.conf').reduce({})  do |acc, conf_file|
      varname=File.basename(conf_file, '.conf')
      acc[varname] = !File.readlines(conf_file).grep(/^ *SaveConfig *= *true/i).empty?
      acc
    end
  end
end
