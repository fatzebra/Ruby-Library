# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Request \Multipart \FileIO
  #
  # Add file to the multipart
  class Request
    module Multipart
      class FileIO
        include Part

        attr_reader :length, :stream

        def initialize(options)
          @filename     = options[:filename]
          @file         = options[:file]
          @content_type = options[:content_type]
          @options      = options
          @file_size    = File.size(@file)
          @footer       = LINE_BREAK
          @length       = header.bytesize + @file_size + @footer.length
          @io           = Stream.new(StringIO.new(header), @file, StringIO.new(@footer))
        end

        def header
          part = []
          part << "--#{boundary}"
          part << "Content-Disposition: form-data; name=\"#{@filename}\"; filename=\"#{@filename}\""
          part << "Content-Length: #{@size}"
          part << "Content-Type: #{@content_type}"
          part << 'Content-Transfer-Encoding: binary'
          part << LINE_BREAK

          part.join(LINE_BREAK)
        end

      end

    end
  end
end
