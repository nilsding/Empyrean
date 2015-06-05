require 'empyrean/defaults'
require 'empyrean/optparser'
require 'empyrean/configloader'
require 'empyrean/tweetloader'
require 'empyrean/tweetparser'
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
      template_file = File.open @options.template
      template = template_file.read
      renderer = TemplateRenderer.new @config, template, parsed
      File.open(@options.outfile, 'w') do |outfile|
        outfile.write renderer.render
        outfile.flush
      end
    end
  end
end

# kate: indent-width 2