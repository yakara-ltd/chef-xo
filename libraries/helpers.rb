#
# Author:: James Le Cuirot <james.le-cuirot@yakara.com>
# Cookbook Name:: xo
# Library:: helpers
#
# Copyright (C) 2016 Yakara Ltd
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  module XO
    module Helpers
      def nginx_directives(hash)
        return unless hash

        for key, value in hash
          case value
          when nil
          when true
            yield "#{key} on;"
          when false
            yield "#{key} off;"
          when Array
            case key
            when 'allow', 'deny'
              value.each do |v|
                yield "#{key} #{v};"
              end
            when 'ssl_ciphers'
              yield "#{key} " + value.join(':') + ';'
            else
              yield "#{key} " + value.join(' ') + ';'
            end
          else
            yield "#{key} #{value};"
          end
        end
      end
    end
  end
end
