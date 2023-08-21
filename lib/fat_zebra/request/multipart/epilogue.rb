# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Request \Multipart \Epilogue
  #
  # Add the epilogue to the multipart
  class Request
    module Multipart
      class Epilogue
        include Part

        def initialize
          @io = StringIO.new(footer)
        end

        private

        def footer
          "--#{boundary}--#{LINE_BREAK}"
        end
      end
    end
  end
end
