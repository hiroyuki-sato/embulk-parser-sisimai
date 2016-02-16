require 'sisimai'
require 'sisimai/message'
require 'sisimai/data'

module Embulk
  module Parser

    class Sisimai < ParserPlugin
      Plugin.register_parser("sisimai", self)

      def self.transaction(config, &control)
        task = {
          "format" => config.param("format", :string, default: "column"),
          "extract_mail_address" => config.param("extract_mail_address", :bool, default: false)
        }

        format = task["format"]
        columns = case format
        when "json"
          [ Column.new(0, "result", :json) ]
        when "column"
          c = [
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
            Column.new(14, "rhost", :string),
            Column.new(15, "senderdomain", :string),
            Column.new(16, "smtpagent", :string),
            Column.new(17, "smtpcommand", :string),
            Column.new(18, "softbounce", :long),
            Column.new(19, "subject", :string),
            Column.new(20, "timestamp", :timestamp),
            Column.new(21, "timezoneoffset", :string),
            Column.new(22, "token", :string),
          ]
          if task['extract_mail_address'] == true
            c += [
              Column.new(23, "addresser_user", :string),
              Column.new(24, "addresser_host", :string),
              Column.new(25, "addresser_vrep", :string),
              Column.new(26, "recipient_user", :string),
              Column.new(27, "recipient_host", :string),
              Column.new(28, "recipient_vrep", :string),
            ]
          end
          c
        else
          raise ArgumentError,"Unkown format type: #{format}"
        end

        yield(task, columns)
      end

      def init
        # initialization code:
        @format = task["format"]
        @extract_mail_address = task["extract_mail_address"]
      end

      def run(file_input)
        while file = file_input.next_file
          mesg = ::Sisimai::Message.new( data: file.read )
          datas = ::Sisimai::Data.make( data: mesg )
          if datas.nil?
            Embulk.logger.info "This file does not contaion bounce mail. skip."
            next
          end
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
        row = [
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
          data.rhost,
          data.senderdomain,
          data.smtpagent,
          data.smtpcommand,
          data.softbounce,
          data.subject,
          data.timestamp.to_time.utc,
          data.timezoneoffset,
          data.token,
        ]
        if @extract_mail_address
          row += [
            data.addresser.user,
            data.addresser.host,
            data.addresser.verp,
            data.recipient.user,
            data.recipient.host,
            data.recipient.verp,
          ]
        end
        row
      end
    end
  end
end
