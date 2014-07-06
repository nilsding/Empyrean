# tweetparser.rb - parses tweets
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

require 'json'

USERNAME_REGEX = /[@]([a-zA-Z0-9_]{1,16})/

class TweetParser
  
  ##
  # Parses an array of tweets
  #
  # Returns a dict of things
  def self.parse(tweets)
    retdict = {
      mentions: {},
      tweet_count: 0,
      retweet_count: 0,
      selftweet_count: 0,
    }
    tweets.each do |tweet|
      parsed_tweet = self.parse_one tweet
      
      if parsed_tweet[:retweet]
        retdict[:retweet_count] += 1
      else
        parsed_tweet[:mentions].each do |user, data|
          retdict[:mentions][user] ||= { count: 0 }
          retdict[:mentions][user][:count] += data[:count]
          retdict[:mentions][user][:examples] ||= []
          retdict[:mentions][user][:examples] << data[:example]
        end
        retdict[:selftweet_count] += 1
      end
      
      retdict[:tweet_count] += 1
    end
    
    retdict
  end
  
  ##
  # Parses a single tweet object
  #
  # Returns a dict of things.
  def self.parse_one(tweet)
    puts "==> #{tweet['id']}" if OPTIONS.verbose
    retdict = {
      mentions: {},
      retweet: false
    }
    
    # check if the tweet is actually a retweet
    unless tweet['retweeted_status'].nil?
      retdict[:retweet] = true
    else
      tweet['text'].scan USERNAME_REGEX do |user|
        user = user[0].downcase
        puts "===> mentioned: #{user}" if OPTIONS.verbose
        retdict[:mentions][user] ||= {}
        retdict[:mentions][user][:count] = retdict[:mentions][user][:count].to_i.succ
        retdict[:mentions][user][:example] ||= tweet['text']
      end
    end
    
    retdict
  end
  
  ##
  # Merges an array which contains dicts returned by self.parse()
  # Increases all counters.
  def self.merge_parsed(parsed)
    retdict = {
      mentions: {},
      tweet_count: 0,
      retweet_count: 0,
      selftweet_count: 0,
    }
    parsed.each do |elem|
      retdict[:tweet_count] += elem[:tweet_count]
      retdict[:retweet_count] += elem[:retweet_count]
      retdict[:selftweet_count] += elem[:selftweet_count]
      
      elem[:mentions].each do |user, data|
        retdict[:mentions][user] ||= { count: 0 }
        retdict[:mentions][user][:count] += data[:count]
        retdict[:mentions][user][:examples] ||= []
        retdict[:mentions][user][:examples] += data[:examples]
      end
    end
    
    # take only one mention example
    retdict[:mentions].each do |user, data|
      retdict[:mentions][user][:example] = retdict[:mentions][user][:examples].sample
      retdict[:mentions][user].delete(:examples)
    end
    
    retdict[:mentions] = retdict[:mentions].sort_by { |k, v| v[:count] }.reverse
    retdict
  end
end

# kate: indent-width 2