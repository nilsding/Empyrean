# optparser.rb - parses CLI options using Ruby's OptionParser
#
# This file is part of RubyTwitterStats 
# Copyright (C) 2014 nilsding
# Copyright (C) 2014 pixeldesu
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

require 'optparse'
require 'ostruct'

class OptParser

  def self.parse(args)
    options = OpenStruct.new
    options.jsondir = ""
    options.outfile = "output.html"
    options.config = File.expand_path('.', "config.yml")
    options.template = File.expand_path('.', "template/default.html.erb")
    options.verbose = false

    opts = OptionParser.new do |opts|
      opts.banner = "Usage: stats.rb [options]"
      
      opts.separator ""
      opts.separator "Specific options:"
      
      opts.on("-c", "--config CONFIG", "The configuration file to use (default: #{options.config})") do |config|
        options.config = config
      end
      
      opts.on("-d", "--jsondir DIRECTORY", "Directory with tweet files (containing 2014_07.js etc.)") do |dir|
        dir = File.expand_path('.', dir)
        unless File.exist?(dir) && File.directory?(dir)
          STDERR.puts "not a directory: #{dir}"
          exit 1
        end
        
        entries = Dir.entries(dir)
        entries.each do |e|
          # the file names of the tweet archive are in the format /^\d{4}_\d{2}\.js$/
          unless e =~ /^\d{4}_\d{2}\.js$|\.+?/
            STDERR.puts "not a tweets directory: #{dir}"
            exit 1
          end
        end
        
        options.jsondir = dir
      end
      
      opts.on("-o", "--outfile OUTFILE", "Output HTML file (default: #{options.outfile})") do |outfile|
        options.output = outfile
      end
      
      opts.on("-t", "--template TEMPLATE", "Template to use (default: #{options.template})") do |template|
        options.template = template
      end
      
      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options.verbose = v
      end
      # No argument, shows at tail.  This will print an options summary.
      # Try it and see!
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end
      
      # Another typical switch to print the version.
      opts.on_tail("--version", "Show version") do
        puts RTS_VERSION_STR
        exit
      end
    end.parse!(args)

    if options.jsondir.empty?
      STDERR.puts "missing argument: --jsondir, see --help for more"
      exit 1
    end
    
    options
  end # parse()
end

# kate: indent-width 2