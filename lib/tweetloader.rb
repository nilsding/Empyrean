# tweetloader.rb - loads tweet files
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

require 'json'
require 'empyrean/defaults'

module Empyrean
  class TweetLoader

    ##
    # Returns a list of file names in a directory.
    def self.read_directory(directory)
      files = []
      entries = Dir.entries(directory)
      entries.each do |e|
        if e =~ /^\d{4}_\d{2}\.js$/
          files << File.expand_path(e, directory)
        end
      end
      files.sort
    end

    ##
    # Reads a tweet file
    def self.read_file(file)
      puts "reading file #{file}"
      fh = File.open(file)
      contents = fh.read
      contents.sub! /Grailbird\.data\.tweets_\d{4}_\d{2} =/, '' # get rid of the JS assignment
      json_tweets = JSON.parse(contents)
    end
  end
end

# kate: indent-width 2