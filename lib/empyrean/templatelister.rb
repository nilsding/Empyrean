# templatelister.rb - lists available templates
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

require 'empyrean/defaults'

module Empyrean
  class TemplateLister
    class << self
      # Returns an array of available templates.
      def list
        Dir[File.join TEMPLATE_DIR, "*.html.erb"].map{ |t| File.basename t }
      end
      
      # Prints the available templates to stdout.
      def print_list
        puts list
      end
    end
  end
end