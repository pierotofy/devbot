# User class, represents a user connected to the IRC chat

module PDevBot

class User
  attr_accessor :nickname, :is_admin, :registered, :userdata

  def initialize(nickname, is_admin = false, registered = false)
    self.nickname = nickname
    self.is_admin = is_admin
    self.registered = registered
    self.userdata = nil
  end
end
end
