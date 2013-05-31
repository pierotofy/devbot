# DevBot class. This object implements the Dev functionalities of a bot

require './Bot'


module PDevBot

class DevBot < Bot
  def initialize(name, svnurl, svnuser, svnpass, svncheckfreq)
    super(name, "")

    @svnurl = svnurl
    @svnuser = svnuser
    @svnpass = svnpass
    @svncheckfreq = svncheckfreq.to_i

    initsvn
  end

  def connect(server, port, channel, username, password)
    Thread.new do
      while true
        sleep(@svncheckfreq)
        new_commit_list = getcommitlist

        # Diff
        new_commit_list.each do |rev, text|
          if @commit_list[rev].nil?

            # Found new
            @sock.sendmessage(@channel, t(:new_commit_made, @svnurl))
            text.split("\n").each do |line|
              @sock.sendmessage(@channel, line)
            end
          end
        end

        @commit_list = new_commit_list
      end
    end

    super(server, port, channel, username, password)
  end

  def initsvn
    @commit_list = getcommitlist
  end

  def checkerrormessage(line)
  end

  def getcommitlist
    cmd = "svn log #{@svnurl} --username #{@svnuser} --password #{@svnpass} --limit 3 -v"
    result = `#{cmd}`

    lines = result.split("\n")
    ret = {}
    current_revision = nil
    text = ""
    lines.each do |line|
      line.strip!
      checkerrormessage(line)
      if line =~ /^[\-]+$/
        if not current_revision.nil?
          ret[current_revision] = text
          text = ""
        end
      else
        matches = line.match(/^r(?<revision>[\d]+) \| /)
        if matches
          current_revision = matches['revision'].to_i
          text += " <b>#{line}</b>\n"
          text += " \n"
        else
          text += "   #{line}\n"
        end
      end
    end

    ret
  end

  def privatemessagereceived(sender, msg)
    super(sender, msg)

    if msg == "HELP"
      @sock.sendnotice(sender, t(:name_no_help_is_available,@name))
    end
  end

  def channelmessagereceived(sender, msg)
    super(sender, msg)

    # Single question requested?
    #if msg.upcase == "!ULTIMICOMMIT"

    #end
  end
end
end