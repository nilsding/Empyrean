# configloader.rb - loads a config file
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

require 'yaml'
require 'empyrean/defaults'

module Empyrean
  class ConfigLoader
    def initialize(options)
      @options = options
    end
    
    ##
    # Loads a YAML file, parses it and returns a hash with symbolized keys.
    def load(file)
      if File.exist? file
        symbolize_keys(YAML.load_file(File.expand_path('.', file)))
      else
        {}
      end
    end

    # Loads a YAML file, parses it and checks if all values are given.  If a
    # value is missing, it will be set with the default value.
    def load_config(file = @options.config)
      config = load(file)
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
      config[:smileys]             = {}       if config[:smileys].nil?
      config[:smileys][:enabled]   = true     if config[:smileys][:enabled].nil?
      config[:smileys][:top]       = 10       if config[:smileys][:top].nil?
      config[:smileys][:notop]     = 0        if config[:smileys][:notop].nil?
      config[:ignored_users]       = []       if config[:ignored_users].nil?
      config[:renamed_users]       = []       if config[:renamed_users].nil?
      args_override config
    end

    def args_override(config)
      config_args = @options.config_values
      config[:timezone_difference] = config_args[:timezone_difference] unless config_args[:timezone_difference].nil?
      config[:mentions][:enabled]  = config_args[:mentions_enabled]    unless config_args[:mentions_enabled].nil?
      config[:mentions][:top]      = config_args[:mentions_top]        unless config_args[:mentions_top].nil?
      config[:mentions][:notop]    = config_args[:mentions_notop]      unless config_args[:mentions_notop].nil?
      config[:clients][:enabled]   = config_args[:clients_enabled]     unless config_args[:clients_enabled].nil?
      config[:clients][:top]       = config_args[:clients_top]         unless config_args[:clients_top].nil?
      config[:clients][:notop]     = config_args[:clients_notop]       unless config_args[:clients_notop].nil?
      config[:hashtags][:enabled]  = config_args[:hashtags_enabled]    unless config_args[:hashtags_enabled].nil?
      config[:hashtags][:top]      = config_args[:hashtags_top]        unless config_args[:hashtags_top].nil?
      config[:hashtags][:notop]    = config_args[:hashtags_notop]      unless config_args[:hashtags_notop].nil?
      config[:smileys][:enabled]   = config_args[:smileys_enabled]     unless config_args[:smileys_enabled].nil?
      config[:smileys][:top]       = config_args[:smileys_top]         unless config_args[:smileys_top].nil?
      config[:smileys][:notop]     = config_args[:smileys_notop]       unless config_args[:smileys_notop].nil?
      config[:ignored_users]       = config_args[:ignored_users]       unless config_args[:ignored_users].nil?
      config[:ignored_users].each do |user|    user.downcase! end
      config[:renamed_users].each do |old, new| new.downcase! end
      config
    end

    private
    
    # Symbolizes the keys of a hash, duh.
    def symbolize_keys(hash)
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
end

# kate: indent-width 2