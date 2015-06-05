# tweetparser.rb - parses tweets
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
  class TweetParser
    def initialize(options, config)
      @options = options
      @config = config
    end
    
    # Parses an array of tweets
    #
    # Returns a dict of things
    def parse(tweets)
      retdict = {
        mentions: {},
        hashtags: {},
        clients: {},
        smileys: {},
        times_of_day: [0] * 24,
        tweet_count: 0,
        retweet_count: 0,
        selftweet_count: 0,
      }
      tweets.each do |tweet|
        parsed_tweet = self.parse_one tweet

        if parsed_tweet[:retweet]  # the tweet was a retweet
          # increase retweeted tweets count
          retdict[:retweet_count] += 1
        else
          parsed_tweet[:mentions].each do |user, data|  # add mentions to the mentions dict
            retdict[:mentions][user] ||= { count: 0 }
            retdict[:mentions][user][:count] += data[:count]
            retdict[:mentions][user][:name] ||= data[:name]
            retdict[:mentions][user][:examples] ||= []
            retdict[:mentions][user][:examples] << data[:example]
          end
          parsed_tweet[:hashtags].each do |hashtag, data|  # add hashtags to the hashtags dict
            retdict[:hashtags][hashtag] ||= { count: 0 }
            retdict[:hashtags][hashtag][:count] += data[:count]
            retdict[:hashtags][hashtag][:hashtag] ||= data[:hashtag]
            retdict[:hashtags][hashtag][:examples] ||= []
            retdict[:hashtags][hashtag][:examples] << data[:example]
          end

          parsed_tweet[:smileys].each do |smile, data|
            retdict[:smileys][smile] ||= { count: 0 }
            retdict[:smileys][smile][:frown] ||= data[:frown]
            retdict[:smileys][smile][:count] += data[:count]
            retdict[:smileys][smile][:smiley] ||= data[:smiley]
            retdict[:smileys][smile][:examples] ||= []
            retdict[:smileys][smile][:examples] << data[:example]
          end

          # increase self tweeted tweets count
          retdict[:selftweet_count] += 1
        end

        # add client to the clients dict
        client_dict = parsed_tweet[:client][:name]
        retdict[:clients][client_dict] ||= { count: 0 }
        retdict[:clients][client_dict][:count] += 1
        retdict[:clients][client_dict][:name] = parsed_tweet[:client][:name]
        retdict[:clients][client_dict][:url] = parsed_tweet[:client][:url]

        retdict[:times_of_day][parsed_tweet[:time_of_day]] += 1

        # increase tweet count
        retdict[:tweet_count] += 1
      end

      retdict
    end

    # Parses a single tweet object
    #
    # Returns a dict of things.
    def parse_one(tweet)
      puts "==> #{tweet['id']}" if @options.verbose
      retdict = {
        mentions: {},
        hashtags: {},
        time_of_day: 0,
        retweet: false,
        client: {
          name: "",
          url: "",
        },
        smileys: {}
      }

      # check if the tweet is actually a retweet and ignore the status text
      unless tweet['retweeted_status'].nil?
        retdict[:retweet] = true
      else
        # scan for mentions
        tweet['text'].scan USERNAME_REGEX do |user|
          hash_user = user[0].downcase
          puts "===> mentioned: #{user[0]}" if @options.verbose
          unless @config[:ignored_users].include? hash_user
            if @config[:renamed_users].include? hash_user.to_sym
              hash_user = @config[:renamed_users][hash_user.to_sym]
            end
            retdict[:mentions][hash_user] ||= {}
            retdict[:mentions][hash_user][:name] ||= user[0]
            retdict[:mentions][hash_user][:count] = retdict[:mentions][hash_user][:count].to_i.succ
            retdict[:mentions][hash_user][:example] ||= { text: tweet['text'], id: tweet['id'] }
          end
        end

        # scan for hashtags
        tweet['text'].scan HASHTAG_REGEX do |hashtag|
          hash_hashtag = hashtag[0].downcase
          puts "===> hashtag: ##{hashtag[0]}" if @options.verbose
          retdict[:hashtags][hash_hashtag] ||= {}
          retdict[:hashtags][hash_hashtag][:hashtag] ||= hashtag[0]
          retdict[:hashtags][hash_hashtag][:count] = retdict[:hashtags][hash_hashtag][:count].to_i.succ
          retdict[:hashtags][hash_hashtag][:example] ||= { text: tweet['text'], id: tweet['id'] }
        end

        # Smileys :^)
        eyes = "[xX8;:=%]"
        nose = "[-oc*^]"
        smile_regex = /(>?#{eyes}'?#{nose}[\)pPD\}\]>]|[\(\{\[<]#{nose}'?#{eyes}<?|[;:][\)pPD\}\]\>]|\([;:]|\^[_o-]*\^[';]|\\[o.]\/)/
        frown_regex = /(#{eyes}'?#{nose}[\(\[\\\/\{|]|[\)\]\\\/\}|]#{nose}'?#{eyes}|[;:][\(\/]|[\)D]:|;_+;|T_+T|-[._]+-)/

        unescaped_tweet = tweet['text'].gsub("&amp;", "&").gsub("&lt;", "<").gsub("&gt;", ">")

        unescaped_tweet.scan smile_regex do |smile|
          smile = smile[0]
          puts "===> smile: #{smile}" if @options.verbose
          retdict[:smileys][smile] ||= {frown: false}
          retdict[:smileys][smile][:smiley] ||= smile
          retdict[:smileys][smile][:count] = retdict[:smileys][smile][:count].to_i.succ
          retdict[:smileys][smile][:example] ||= { text: tweet['text'], id: tweet['id'] }
        end

        unescaped_tweet.scan frown_regex do |frown|
          break unless unescaped_tweet !~ /\w+:\/\// # http:// :^)
          frown = frown[0]
          puts "===> frown: #{frown}" if @options.verbose
          retdict[:smileys][frown] ||= {frown: true}
          retdict[:smileys][frown][:smiley] ||= frown
          retdict[:smileys][frown][:count] = retdict[:smileys][frown][:count].to_i.succ
          retdict[:smileys][frown][:example] ||= { text: tweet['text'], id: tweet['id'] }
        end
      end

      # Tweet source (aka. the client the (re)tweet was made with)
      source_matches = tweet['source'].match SOURCE_REGEX
      retdict[:client][:url]  = source_matches[1]
      retdict[:client][:name] = source_matches[2]

      # Time of day
      retdict[:time_of_day] = (tweet['created_at'].match(/^\d{4}-\d{2}-\d{2} (\d{2})/)[1].to_i + @config[:timezone_difference]) % 24

      retdict
    end

    class << self
      # Merges an array which contains dicts returned by self.parse()
      # Increases all counters.
      def merge_parsed(parsed)
        retdict = {
          mentions: {},
          hashtags: {},
          clients: {},
          smileys: {},
          times_of_day: [0] * 24,
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
            retdict[:mentions][user][:name] = data[:name]
            retdict[:mentions][user][:examples] ||= []
            retdict[:mentions][user][:examples] += data[:examples]
          end

          elem[:hashtags].each do |hashtag, data|
            retdict[:hashtags][hashtag] ||= { count: 0 }
            retdict[:hashtags][hashtag][:count] += data[:count]
            retdict[:hashtags][hashtag][:hashtag] = data[:hashtag]
            retdict[:hashtags][hashtag][:examples] ||= []
            retdict[:hashtags][hashtag][:examples] += data[:examples]
          end

          elem[:smileys].each do |smile, data|
            retdict[:smileys][smile] ||= { count: 0 }
            retdict[:smileys][smile][:frown] ||= data[:frown]
            retdict[:smileys][smile][:count] += data[:count]
            retdict[:smileys][smile][:smiley] ||= data[:smiley]
            retdict[:smileys][smile][:examples] ||= []
            retdict[:smileys][smile][:examples] += data[:examples]
          end

          elem[:clients].each do |client, data|
            retdict[:clients][client] ||= { count: 0 }
            retdict[:clients][client][:count] += data[:count]
            retdict[:clients][client][:name] = data[:name]
            retdict[:clients][client][:url] = data[:url]
          end

          elem[:times_of_day].each_with_index do |count, index|
            retdict[:times_of_day][index] += elem[:times_of_day][index]
          end
        end

        # take only one example
        retdict[:mentions].each do |user, data|
          retdict[:mentions][user][:example] = retdict[:mentions][user][:examples].sample
          retdict[:mentions][user].delete(:examples)
        end
        retdict[:hashtags].each do |hashtag, data|
          retdict[:hashtags][hashtag][:example] = retdict[:hashtags][hashtag][:examples].sample
          retdict[:hashtags][hashtag].delete(:examples)
        end
        retdict[:smileys].each do |smile, data|
          retdict[:smileys][smile][:example] = retdict[:smileys][smile][:examples].sample
          retdict[:smileys][smile].delete(:examples)
        end

        retdict[:mentions] = retdict[:mentions].sort_by { |k, v| v[:count] }.reverse
        retdict[:hashtags] = retdict[:hashtags].sort_by { |k, v| v[:count] }.reverse
        retdict[:clients]  = retdict[:clients].sort_by  { |k, v| v[:count] }.reverse
        retdict[:smileys]  = retdict[:smileys].sort_by  { |k, v| v[:count] }.reverse

        retdict
      end
    end
  end
end

# kate: indent-width 2