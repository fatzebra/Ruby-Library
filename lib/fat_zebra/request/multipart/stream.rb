module FatZebra
  ##
  # == FatZebra \Request \Multipart \Stream
  #
  # Steam the multipart
  class Request
    module Multipart
      class Stream

        BINARY_ENCODING = 'BINARY'.freeze

        def initialize(*ios)
          @ios   = ios.flatten
          @index = 0
        end

        # rubocop:disable Metrics/CyclomaticComplexity
        # rubocop:disable Metrics/PerceivedComplexity
        def read(length = nil, outbuf = nil)
          got_result = false
          outbuf = outbuf ? outbuf.replace('') : ''

          while current_io
            result = current_io.read(length)

            if result
              got_result ||= !result.nil?
              result.force_encoding(BINARY_ENCODING) if result.respond_to?(:force_encoding)
              outbuf << result

              length -= result.length if length
              break if length == 0
            end

            next_io
          end

          !got_result && length ? nil : outbuf
        end
        # rubocop:enable Metrics/CyclomaticComplexity
        # rubocop:enable Metrics/PerceivedComplexity

        private

        def current_io
          @ios[@index]
        end

        def next_io
          @index += 1
        end

      end

    end
  end
end
