require 'sisimai'
require 'sisimai/message'
require 'sisimai/data'
require 'pp'

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
            Column.new(1, "addresser",:string),
            Column.new(2, "alias", :string),
            Column.new(3, "deliverystatus", :string),
            Column.new(4, "destination", :string),
            Column.new(5, "diagnosticcode", :string),
            Column.new(6, "diagnostictype", :string),
            Column.new(7, "feedbacktype", :string),
            Column.new(8, "lhost", :string),
            Column.new(9, "listid", :string),
            Column.new(10, "messageid", :string),
            Column.new(11, "reason", :string),
            Column.new(12, "recipient", :string),
            Column.new(13, "replycode", :string),
            Column.new(14, "senderdomain", :string),
            Column.new(15, "smtpagent", :string),
            Column.new(16, "smtpcommand", :string),
            Column.new(17, "softbounce", :long),
            Column.new(18, "subject", :string),
            Column.new(19, "timestamp", :timestamp),
            Column.new(20, "timezoneoffset", :string),
            Column.new(21, "token", :string),
          ]
        else
          raise ArgumentError,"Unkown format type: #{format}"
        end

        yield(task, columns)
      end

      def init
        # initialization code:
        @format = task["format"]
      end

      def run(file_input)
        while file = file_input.next_file
          mesg = Sisimai::Message.new( data: file.read )
          datas = Sisimai::Data.make( data: mesg )
          datas.each do |data|
            case @format
            when "json"
              page_builder.add([ data.dump ])
            when "column"
              column_data = make_column_array(data)

              page_builder.add(column_data)
            else
              raise RuntimeError,"Invalid format #{@format}"
            end
          end
        end
        page_builder.finish
      end
      private
      def make_column_array(data)
        result = [
          data.action,
          data.addresser.to_json,
          data.alias,
          data.deliverystatus,
          data.destination,
          data.diagnosticcode,
          data.diagnostictype,
          data.feedbacktype,
          data.lhost,
          data.listid,
          data.messageid,
          data.reason,
          data.recipient.to_json,
          data.replycode,
          data.senderdomain,
          data.smtpagent,
          data.smtpcommand,
          data.softbounce,
          data.subject,
          data.timestamp.to_time.utc,
          data.timezoneoffset,
          data.token
        ]
      end
    end

  end
end
