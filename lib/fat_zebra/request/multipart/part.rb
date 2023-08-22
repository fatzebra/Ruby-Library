# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Request \Multipart \Part
  #
  # Define one part
  class Request
    module Multipart
      module Part

        LINE_BREAK = "\r\n"

        def boundary
          '----FatZebraMultipartPost'
        end

        def length
          @io.length
        end

        def to_io
          @io
        end

      end

    end
  end
end
