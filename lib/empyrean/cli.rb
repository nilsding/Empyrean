# cli.rb
#
# This file is part of Empyrean
# Copyright (C) 2015 nilsding, pixeldesu
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

require 'empyrean/defaults'
require 'empyrean/optparser'
require 'empyrean/configloader'
require 'empyrean/tweetloader'
require 'empyrean/tweetparser'
require 'empyrean/templatelister'
require 'empyrean/templaterenderer'

module Empyrean
  class CLI
    def initialize(*argv)
      @options = OptParser.parse(argv)
      @config = ConfigLoader.new(@options).load_config
      
      parsed = analyze_tweets
      print_stats(parsed)
      generate_html(parsed)
    end
    
    def analyze_tweets
      tweet_files = TweetLoader.read_directory(@options.jsondir)
      parsed = []
      parser = TweetParser.new(@options, @config)
      tweet_files.each do |file|
        tweet = TweetLoader.read_file file
        parsed << parser.parse(tweet)
      end
      TweetParser.merge_parsed parsed
    end
    
    def print_stats(parsed)
      puts "Analyzed #{parsed[:tweet_count]} tweets"
      puts "  - #{(parsed[:retweet_count] * 100 / parsed[:tweet_count].to_f).round(2)}% retweets\n"

      headers = {
        mentions: ["You send most mentions to:", "times" ],
        clients:  ["Most used clients:",         "tweets"],
        hashtags: ["Your most used hashtags:",   "times"],
        smileys:  ["Your most used smileys:",    "times"]
      }
      
      headers.each do |k, v|
        if @config[k][:enabled]
          puts v[0]
          begin
            @config[k][:top].times do |i|
              puts "#{sprintf "%2d", i + 1}. #{parsed[k][i][1][:name]} (#{parsed[k][i][1][:count]} #{v[1]})"
            end
          rescue => _
          end
        end
      end
    end
    
    def generate_html(parsed)
      puts "Generating HTML"
      template = File.read template_file
      renderer = TemplateRenderer.new @config, template, parsed
      File.open(@options.outfile, 'w') do |outfile|
        outfile.write renderer.render
        outfile.flush
      end
    end
    
    def template_file
      if File.exist? File.join(Dir.pwd, @options.template)
        File.join(Dir.pwd, @options.template)
      elsif TemplateLister.list.include? @options.template
        File.join TEMPLATE_DIR, @options.template
      else
        @options.template
      end
    end
  end
end

# kate: indent-width 2