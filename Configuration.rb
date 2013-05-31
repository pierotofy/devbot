# Configuration file

require './ArgumentParser.rb'

module PDevBot
  class Configuration

    # Set default values, then merge with command line arguments, then create accessors for each
    def initialize
      conf = {'server' => '192.168.1.254',
              'port' => '6669',
              'channel' => '#pierotofy.it',
              'botname' => 'DevBot',
              'password' => 'botpassword',
              'language' => 'en',
              'svnurl' => 'https://192.168.1.254/svn/test',
              'svnuser' => 'guestsvn',
              'svnpass' => 'guestsvn',
              'svncheckfreq' => '6'
              }
       params = ArgumentParser.parse(ARGV)
       conf = conf.merge(params);

      # Define runtime accessors method for each entry
       conf.each do |key, value|
         self.class.send(:define_method, key) do
           value
         end
       end
    end
  end
end
