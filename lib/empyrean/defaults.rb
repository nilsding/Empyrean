# defaults.rb - some constants
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

module Empyrean
  # Application name
  APP_NAME = "Empyrean"

  # Version
  VERSION = "0.1.0"

  # Combined version string
  VERSION_STR = "#{APP_NAME} #{VERSION}"

  # Regexp for matching user names
  USERNAME_REGEX = /[@]([a-zA-Z0-9_]{1,16})/

  # Regexp for matching the client source
  SOURCE_REGEX = /^<a href=\"(https?:\/\/\S+|erased_\d+)\" rel=\"nofollow\">(.+)<\/a>$/

  # Regexp for matching hashtags
  HASHTAG_REGEX = /[#]([^{}\[\]().,\-:!*_?#\s]+)/
  
  # Path to the templates
  TEMPLATE_DIR = File.expand_path "../templates", __FILE__
  
  # The default template to use
  DEFAULT_TEMPLATE = "default.html.erb"
end
