require 'sisimai'
require 'sisimai/message'
require 'sisimai/data'

module Embulk
  module Parser

    class SisimaiAnalyzer < ParserPlugin
      Plugin.register_parser("sisimai_analyzer", self)

      def self.transaction(config, &control)
        # configuration code:
        task = {
          "format" => config.param("format", :string, default: "json")
        }

        columns = [
          Column.new(0, "result", :json),
        ]

        yield(task, columns)
      end

      def init
        # initialization code:
#        @format = task["format"]
      end

      def run(file_input)
        while file = file_input.next_file
          mesg = Sisimai::Message.new( data: file.read )
          data = Sisimai::Data.make( data: mesg )
          page_builder.add([ data[0].dump ])
        end
        page_builder.finish
      end
    end

  end
end
