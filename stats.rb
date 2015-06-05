#!/usr/bin/env ruby
# stats.rb - generate a statistics page from your Twitter archive
#
# This file is part of Empyrean
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

$:.unshift File.expand_path './lib', File.dirname(__FILE__)

require 'empyrean/defaults'
require 'empyrean/optparser'
require 'empyrean/configloader'
require 'empyrean/tweetloader'
require 'empyrean/tweetparser'
require 'empyrean/templaterenderer'

OPTIONS = Empyrean::OptParser.parse(ARGV)
CONFIG = Empyrean::ConfigLoader.load_config(OPTIONS.config)

tweet_files = Empyrean::TweetLoader.read_directory(OPTIONS.jsondir)
parsed = []
tweet_files.each do |file|
  tweet = Empyrean::TweetLoader.read_file file
  parsed << Empyrean::TweetParser.parse(tweet)
end
parsed = Empyrean::TweetParser.merge_parsed parsed

puts "Analyzed #{parsed[:tweet_count]} tweets"
puts "  - #{(parsed[:retweet_count] * 100 / parsed[:tweet_count].to_f).round(2)}% retweets\n"

if CONFIG[:mentions][:enabled]
  puts "You send most mentions to:"
  begin
    CONFIG[:mentions][:top].times do |i|
      puts "#{sprintf "%2d", i + 1}. #{parsed[:mentions][i][1][:name]} (#{parsed[:mentions][i][1][:count]} times)"
    end
  rescue
  end
end

if CONFIG[:clients][:enabled]
  puts "Most used clients:"
  begin
    CONFIG[:clients][:top].times do |i|
      puts "#{sprintf "%2d", i + 1}. #{parsed[:clients][i][1][:name]} (#{parsed[:clients][i][1][:count]} tweets)"
    end
  rescue
  end
end

if CONFIG[:hashtags][:enabled]
  puts "Your most used hashtags:"
  begin
    CONFIG[:hashtags][:top].times do |i|
      puts "#{sprintf "%2d", i + 1}. ##{parsed[:hashtags][i][1][:hashtag]} (#{parsed[:hashtags][i][1][:count]} times)"
    end
  rescue
  end
end

if CONFIG[:smileys][:enabled]
  puts "Your most used smileys:"
  begin
    CONFIG[:smileys][:top].times do |i|
      puts "#{sprintf "%2d", i + 1}. #{parsed[:smileys][i][1][:smiley]} (#{parsed[:smileys][i][1][:count]} times)"
    end
  rescue
  end
end

puts "Generating HTML"
template_file = File.open OPTIONS.template
template = template_file.read
renderer = Empyrean::TemplateRenderer.new template, parsed
File.open(OPTIONS.outfile, 'w') do |outfile|
  outfile.write renderer.render
  outfile.flush
end

# kate: indent-width 2
