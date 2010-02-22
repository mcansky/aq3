class SshKey < ActiveRecord::Base
  belongs_to :user
  
  def extract_login
    if self.key
      key_pieces = self.key.split(" ")
      self.login = key_pieces[2] if key_pieces.size == 3
    end
    self.save
  end
end
