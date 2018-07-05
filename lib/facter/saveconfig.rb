=begin
If a wireguard config file contains saveconfig directive then
there is no point in updating it as puppet and wireguard both keep changing
the file. This creates custom facts that are used to decide whether puppet
should update a particular file.
=end
Facter.add(:wireguard_saveconfig_custom) do
  setcode do
    saveconfig = {}
    Dir.glob('/etc/wireguard/*.conf') do |conf_file|
      varname=File.basename(conf_file,".conf")
      if File.readlines(conf_file).grep(/\A.*#.*SaveConfig/i).size >0
        saveconfig[varname]=false
      else
        if File.readlines(conf_file).grep(/SaveConfig/i).size >0
          saveconfig[varname]=true
        end
      end
    end
    saveconfig
  end
end
