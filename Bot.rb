# Bot class
# This class implements most of the behavior of the chat bot

require './IrcSocket'
require './User'
require './Language'
include PLanguageSupport

module PDevBot

class Bot
  # Constructor
  def initialize(name, adminpassword)
    @name = name
    @channel = ""
    @adminpassword = adminpassword

    # Users hash table (dynamically computed each time) {nickname => User}
    @users = {}
  end

  def connect(server, port, channel, username, password)
    begin
      @channel = channel
      @username = username
      @password = password

      puts t(:connecting_to,server,port)
      @sock = IrcSocket.new(server, port)
    rescue Exception=>e
      puts e
    else
      # We're in!
      @sock.authenticate(@username)
      sleep 5
      @sock.joinchannel(@channel)

      exitSignalReceived = false

      while !exitSignalReceived
        incoming = @sock.readline.chomp
        
        puts t(:parsing,incoming)

        parseincomingmessage(incoming)

        #Notice message?
        if result = /:([^!]+)![^ ]+ NOTICE #{@username} :([^$]+)$/.match(incoming)
          sender = result[1]
          msg = result[2]
          puts t(:notice_message_from,sender,msg)

          noticereceived(sender, msg)
        end
        
        #Private message?
        if result = /:([^!]+)![^ ]+ PRIVMSG #{@username} :([^$]+)$/.match(incoming)
          sender = result[1]
          msg = result[2].chomp.upcase
          puts t(:private_message_from, sender, msg)

          privatemessagereceived(sender, msg)
        end
      end

      sleep 5
      @sock.close
    end
  end

  def parseincomingmessage(incoming)
     #Need to authenticate? This user needs to be created in advance by an administrator
    if incoming =~ /This nickname is registered/
      @sock.sendmessage("NickServ", "IDENTIFY " + @password)
      puts t(:authenticating)
    end

    #Did we fail to join the channel?
    if incoming =~ /451 JOIN :You have not registered/
      sleep 2
      @sock.joinchannel(@channel)
    end

    #Ping? Pong!
    if result = /PING ([^$ ]+)[ ]*[^$]*$/.match(incoming)
      host = result[1]
      @sock.puts("PONG " + host)
      puts "PONG " + host
    end

    #User disconnect
    # :pierotofy!uiedrosuplfgj@131.212.77.65 QUIT :Connection closed
    if result = /:([^!]+)![^ ]+ QUIT/.match(incoming)
      puts t(:disconnected,result[1])
      @users.delete(result[1]) if (@users.has_key?(result[1]))
    end

    #User join
    #:lightIRC_3305!uiedrosuplfgj@131.212.77.65 JOIN :#pierotofy.it
    if result = /:([^!]+)![^ ]+ JOIN/.match(incoming)
      puts t(:joined, result[1])
      @users.store(result[1],User.new(result[1])) unless (@users.has_key?(result[1]))

      @sock.retrieveuserinfo(result[1])
    end

    #User change nick
    #:lightIRC_3305!uiedrosuplfgj@131.212.77.65 NICK pierotofy
    if result = /:([^!]+)![^ ]+ NICK ([^$]+)$/.match(incoming)
      puts t(:changed_nick_into, result[1],result[2])
      @users.delete(result[1]) if (@users.has_key?(result[1]))
      @users.store(result[2],User.new(result[2]))

      @sock.retrieveuserinfo(result[2])
    end

    #Getting a list of users?
    if result = /:([^ ]+) 353 #{@username} = ([^ ]+) :([^$]+)$/.match(incoming)
      puts t(:parsing_list_of_users,result[3])

      result[3].split.each do |nick|
        nick = nick.sub(/[@]/, '')

        @users.store(nick,User.new(nick)) unless (@users.has_key?(nick))
        @sock.retrieveuserinfo(nick)

        puts t(:retrieving_user_info, nick)
      end
    end

    if result = /:([^!]+)![^ ]+ PRIVMSG #{@channel} :([^$]+)$/.match(incoming)
      sender = result[1]
      msg = result[2].chomp

      channelmessagereceived(sender, msg)
    end
  end

  def channelmessagereceived(sender, msg)
    
  end

  def privatemessagereceived(sender, msg)
    if result = /AUTH ([^$]+)$/.match(msg)
      if result[1] == @adminpassword.upcase
        if @users.has_key?(sender)
          @users[sender].is_admin = true

          @sock.sendnotice(sender, t(:you_are_now_authenticated))
          puts t(:user_authenticated,sender)
        end
      end
    end
  end

  def noticereceived(sender, msg)
    # Is an user logged in with the nickserv?
    if result = /([^ ]+) is currently online./.match(msg)
       nick = result[1]
       userregistered(nick)
    end
  end

  def userregistered(nick)
    @users[nick].registered = true if @users.has_key?(nick)

    puts t(:nick_is_registered, nick)
  end

  attr_accessor :name;
end
end