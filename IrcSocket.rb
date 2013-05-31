# IRC Client library
# This class enbraces the TCP Socket class and adds IRC specific methods

require 'socket'

module PDevBot
class IrcSocket < TCPSocket
  def initialize(server, port)
    super(server, port)

    @_formatCodes = {
      "off" => "\x0f",
      "bold" => "\x02",
      "color" => "\x03",
      "reverse" => "\x16",
      "underline" => "\x1f"
    }

    @_colorCodes = { # Not defined by the IRC standard but supported by most IRC Clients
      "white" => "00",
      "black" => "01",
      "darkblue" => "02",
      "darkgreen" => "03",
      "red" => "04",
      "darkred" => "05",
      "darkpurple" => "06",
      "orange" => "07",
      "yellow" => "08",
      "green" => "09",
      "darkcyan" => "10",
      "cyan" => "11",
      "blue" => "12",
      "purple" => "13",
      "darkgray" => "14",
      "gray" => "15"
    }
  end

  def authenticate(username)
    self.puts "NICK #{username}"
    self.puts "USER #{username} 0 * #{username}"

  end

  def joinchannel(channel)
    self.puts "JOIN #{channel}"
  end

  def sendmessage(receiver,message)
    message = formatmessage(message)
    self.puts "PRIVMSG #{receiver} :#{message}"
  end

  def retrieveuserinfo(nickname)
    sendmessage("NickServ","info #{nickname}")
  end

  def sendnotice(receiver, notice)
    notice = formatmessage(notice)
    self.puts "NOTICE #{receiver} :#{notice}"
  end

  # This socket class accepts messages that are defined in HTML style
  # converting <b>,</b> into bold, <u></u> underlined, etc.
  def formatmessage(msg)
     msg = msg.gsub /(.*)<b>(.*)<\/b>(.*)/,'\1' + @_formatCodes['bold'] + '\2' + @_formatCodes['bold'] + '\3' while msg=~/<b>/
     msg = msg.gsub /(.*)<u>(.*)<\/u>(.*)/,'\1' + @_formatCodes['underline'] + '\2' + @_formatCodes['underline'] + '\3' while msg=~/<u>/

     # Detect font color tag
     if msg =~/<font color/
       @_colorCodes.each_pair do |color, code|
         msg = msg.gsub /<font color="#{color}">/,"\x03" + code while msg=~/<font color="#{color}">/
         msg = msg.gsub /<\/font>/,'' while msg=~/<\/font>/
       end
     end
     
    return msg
  end

  def close
    self.puts "QUIT Goodbye!" 
    sleep 2 # Give time for the message to reach destination
    super
  end
end
end