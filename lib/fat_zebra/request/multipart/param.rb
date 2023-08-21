# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Request \Multipart \Param
  #
  # Add param to the multipart
  class Request
    module Multipart
      class Param
        include Part

        def initialize(name, value)
          @name  = name
          @value = value
          @io    = StringIO.new(part)
        end

        def length
          part.bytesize
        end

        private

        def part
          part = []
          part << "--#{boundary}"
          part << "Content-Disposition: form-data; name=\"#{@name}\""
          part << ''
          part << @value

          part.join(LINE_BREAK)
        end

      end

    end
  end
end
