class SshKey < ActiveRecord::Base
  belongs_to :user

  # extract the login from the pasted key and insert it in the db
  def extract_login
    if self.valid
      key_pieces = self.key.split(" ")
      self.login = key_pieces[2] if key_pieces.size == 3
    end
    self.save
  end

  # return the ssh key (without the username@host)
  def short
    if self.valid
      key_pieces = self.key.split(" ")
      return key_pieces[0] + " " + key_pieces[1]
    end
  end

  # check validity of the key
  def valid
    if self.key
      key_pieces = self.key.split(" ")
      small_key = key_pieces[0] + " " + key_pieces[1]
      if small_key =~ /^(ssh-\w+ [a-zA-Z0-9\/\+]+==?).*$/
        return true
      else
        return false
      end
    else
      return false
    end
  end

  # prepare the command for the export to the filesystem
  def command
    if self.valid
      command = ["command=\"#{Settings.application.aq_shell} #{self.login}\"",
                  "no-port-forwarding", "no-X11-forwarding", "no-agent-forwarding"]
      command.join(",")
    end
  end

  # export to the user directory ssh folder
  def export_to_sys
    if self.valid
      #auth_keys_file = Settings.application.root_dir + "/" + Settings.application.repo_user + "/.ssh/authorized_keys"
      auth_keys_file = "/tmp/authorized_keys"
      ssh_line = "#{command} #{self.short}"
      #ssh_line = "#{self.short}"
      File.open(auth_keys_file, "w+") { |akf| akf.write ssh_line}
    end
  end
end
