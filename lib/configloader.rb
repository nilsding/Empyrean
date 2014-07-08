# configloader.rb - loads a config file
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

require 'yaml'

class ConfigLoader
  
  ##
  # Loads a YAML file, parses it and returns a hash with symbolized keys.
  def self.load(file)
    symbolize_keys(YAML.load_file(File.expand_path('.', file)))
  end
  
  ##
  # Loads a YAML file, parses it and checks if all values are given.  If a
  # value is missing, it will be set with the default value.
  def self.load_config(file)
    config = self.load(file)
    config[:timezone_difference] = 0        if config[:timezone_difference].nil?
    config[:mentions]            = {}       if config[:mentions].nil?
    config[:mentions][:enabled]  = true     if config[:mentions][:enabled].nil?
    config[:mentions][:top]      = 10       if config[:mentions][:top].nil?
    config[:mentions][:notop]    = 20       if config[:mentions][:notop].nil?
    config[:clients]             = {}       if config[:clients].nil?
    config[:clients][:enabled]   = true     if config[:clients][:enabled].nil?
    config[:clients][:top]       = 10       if config[:clients][:top].nil?
    config[:clients][:notop]     = 20       if config[:clients][:notop].nil?
    config[:hashtags]            = {}       if config[:hashtags].nil?
    config[:hashtags][:enabled]  = true     if config[:hashtags][:enabled].nil?
    config[:hashtags][:top]      = 10       if config[:hashtags][:top].nil?
    config[:hashtags][:notop]    = 20       if config[:hashtags][:notop].nil?
    config
  end
  
  private
    ##
    # Symbolizes the keys of a hash, duh.
    def self.symbolize_keys(hash)
      hash.inject({}) do |result, (key, value)|
        new_key = case key
                  when String then key.to_sym
                  else key
                  end
        new_value = case value
                    when Hash then symbolize_keys(value)
                    else value
                    end
        result[new_key] = new_value
        result
      end
    end
end

# kate: indent-width 2