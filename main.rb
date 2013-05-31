# PDevBot main file
# Entry point, arguments parsing, class instantiation

require './Configuration'
require './DevBot'
require './Language'
include PLanguageSupport
  
module PDevBot
  conf = Configuration.new
  loadlanguage(conf.language)

  # Check SVN path
  begin
  	`svn --version`
  rescue
  	puts t(:subversion_not_found)
  	exit 1
  end

  bot = DevBot.new(conf.botname, conf.svnurl, conf.svnuser, conf.svnpass, conf.svncheckfreq)
  bot.connect(conf.server, conf.port, conf.channel, conf.botname, conf.password)
  
end