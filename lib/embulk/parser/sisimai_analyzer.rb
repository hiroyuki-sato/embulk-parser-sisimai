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

        format = task["format"]
        columns = case format
        when "json"
          [ Column.new(0, "result", :json) ]
        when "column"
          [
            Column.new(0, "action", :string),
            Column.new(1, "alias", :string),
            Column.new(2, "deliverystatus", :string),
            Column.new(3, "destination", :string),
            Column.new(4, "diagnosticcode", :string),
            Column.new(5, "diagnostictype", :string),
            Column.new(6, "feedbacktype", :string),
            Column.new(7, "lhost", :string),
            Column.new(8, "listid", :string),
            Column.new(9, "messageid", :string),
            Column.new(10, "reason", :string),
            Column.new(11, "recipient", :string),
            Column.new(12, "replycode", :string),
            Column.new(13, "senderdomain", :string),
            Column.new(14, "smtpagent", :string),
            Column.new(15, "smtpcommand", :string),
            Column.new(16, "softbounce", :integer),
            Column.new(17, "subject", :string),
            Column.new(18, "timestamp", :long),
            Column.new(19, "timezoneoffset", :string),
            Column.new(20, "token", :string),
          ]
        else
          raise ArgumentError,"Unkown format type: #{format}"
        end

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
