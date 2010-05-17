namespace :sshkeys do
  desc "export ssh keys to authorized_keys file"
  task(:export => :environment) do
    puts "Exporting ssh keys"
    keys = SshKey.find(:all)
    auth_keys_file = "/tmp/authorized_keys"
    keys.each do |key|
      if key.valid
        File.open(auth_keys_file, "a") { |keyfile| keyfile.puts(key.export) }
      end
    end
  end
end
