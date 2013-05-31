# Argument parser class
# Takes the ARGV list and returns an hashed item of the form:
# { param1 (without --) : value }
module PDevBot
  class ArgumentParser
      def self.parse(args)
        res = {}
        0.step(args.length, 2).each do |i|
          res.store(String(args[i]).delete("--"), args[i+1])
        end
        return res
      end
  end
end
