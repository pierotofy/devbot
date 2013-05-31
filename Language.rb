# Language support
require 'yaml'

module PLanguageSupport
  # Load a language file
  def loadlanguage(language)
    $language = []
    #begin
      $language = YAML::load(File.open("languages/#{language}.yaml",'r')) || Hash.new
    #rescue
    #  puts "Invalid language file specified: languages/#{language}.yaml, exiting..."
    #  exit
    #end
  end

  # Translate a string
  def t(string, *args)
    if $language.has_key?(string)
      ret = $language[string]
      c = 0
      args.each do |arg|
        ret = ret.gsub /\#\{#{c}\}/,arg.to_s
        c += 1
      end

      ret
    else
      string
    end
  end
end
