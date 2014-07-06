# templaterenderer.rb - renders a ERB template
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

require 'erb'

class TemplateRenderer
  
  ##
  # Initializes a new TemplateRenderer
  # 
  # template: The template to use (i.e. not the file name)
  # parsed_tweets: The dict that gets returned by TweetParser::merge_parsed
  def initialize(template, parsed_tweets)
    @template = template
    @parsed = parsed_tweets
  end
  
  ##
  # Renders @template.
  def render
    mentions = @parsed[:mentions].slice(0, 10) # top 10 mentions
    erb = ERB.new @template
    erb.result binding
  end
  
end

# kate: indent-width 2