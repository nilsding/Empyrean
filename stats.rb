#!/usr/bin/env ruby19
# stats.rb - generate a statistics page from your Twitter archive
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

$:.unshift File.expand_path './lib', File.dirname(__FILE__)
RTS_VERSION_STR = "RubyTwitterStats 0.0.1"

require 'optparser'
require 'tweetloader'
require 'tweetparser'
require 'templaterenderer'

OPTIONS = OptParser.parse(ARGV)
tweet_files = TweetLoader.read_directory(OPTIONS.jsondir)
parsed = []
tweet_files.each do |file|
  tweet = TweetLoader.read_file file
  parsed << TweetParser.parse(tweet)
end
parsed = TweetParser.merge_parsed parsed

puts "Analyzed #{parsed[:tweet_count]} tweets"
puts "  - #{(parsed[:retweet_count] * 100 / parsed[:tweet_count].to_f).round(2)}% retweets\n"

puts "You send most mentions to:"
(0...10).each do |i|
  puts "#{sprintf "%2d", i + 1}. #{parsed[:mentions][i][0]} (#{parsed[:mentions][i][1][:count]} tweets)"
end

puts "Generating HTML"
template_file = File.open OPTIONS.template
template = template_file.read
renderer = TemplateRenderer.new template, parsed
File.open(OPTIONS.outfile, 'w') do |outfile|
  outfile.write renderer.render
  outfile.flush
end


# kate: indent-width 2