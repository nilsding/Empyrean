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

require 'rubygems'
require 'nokogiri'
require 'digest'
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
      clients: {},
      tweet_count: 0,
      retweet_count: 0,
      selftweet_count: 0,
    }
    tweets.each do |tweet|
      parsed_tweet = self.parse_one tweet
      
      if parsed_tweet[:retweet] # the tweet was a retweet
        # increase retweeted tweets count
        retdict[:retweet_count] += 1
      else # add mentions to the mentions dict
        parsed_tweet[:mentions].each do |user, data|
          retdict[:mentions][user] ||= { count: 0 }
          retdict[:mentions][user][:count] += data[:count]
          retdict[:mentions][user][:examples] ||= []
          retdict[:mentions][user][:examples] << data[:example]
        end
        # increase self tweeted tweets count
        retdict[:selftweet_count] += 1
      end
      
      # add client to the clients dict      
      client_sha1 = Digest::SHA1.hexdigest(parsed_tweet[:client][:name])
      retdict[:clients][client_sha1] ||= { count: 0 }
      retdict[:clients][client_sha1][:count] += 1
      retdict[:clients][client_sha1][:name] = parsed_tweet[:client][:name]
      retdict[:clients][client_sha1][:url] = parsed_tweet[:client][:url]
      
      # increase tweet count
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
      retweet: false,
      client: {
        name: "",
        url: "",
      }
    }
    
    # check if the tweet is actually a retweet and ignore the status text
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
    
    # Tweet source (aka. the client the (re)tweet was made with)
    doc = Nokogiri::HTML(tweet['source'])
    retdict[:client][:name] = doc.css('a').children.first.text
    retdict[:client][:url]  = doc.css('a').first.attributes['href'].value
    
    retdict
  end
  
  ##
  # Merges an array which contains dicts returned by self.parse()
  # Increases all counters.
  def self.merge_parsed(parsed)
    retdict = {
      mentions: {},
      clients: {},
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
      
      elem[:clients].each do |client_sha1, data|
        retdict[:clients][client_sha1] ||= { count: 0 }
        retdict[:clients][client_sha1][:count] += data[:count]
        retdict[:clients][client_sha1][:name] = data[:name]
        retdict[:clients][client_sha1][:url] = data[:url]
      end
    end
    
    # take only one mention example
    retdict[:mentions].each do |user, data|
      retdict[:mentions][user][:example] = retdict[:mentions][user][:examples].sample
      retdict[:mentions][user].delete(:examples)
    end
    
    retdict[:mentions] = retdict[:mentions].sort_by { |k, v| v[:count] }.reverse
    retdict[:clients]  = retdict[:clients].sort_by  { |k, v| v[:count] }.reverse
    retdict
  end
end

# kate: indent-width 2