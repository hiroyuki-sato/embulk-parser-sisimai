require 'sisimai'
require 'sisimai/message'
require 'sisimai/data'
require 'digest/sha1'

module Embulk
  module Parser

    class Sisimai < ParserPlugin
      Plugin.register_parser("sisimai", self)

      def self.transaction(config, &control)
        task = {
          "format" => config.param("format", :string, default: "column"),
          "extract_mail_address" => config.param("extract_mail_address", :bool, default: false),
          "include_delivered" => config.param("include_delivered", :bool, default: false)
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
        when "sisito"
          c = [
            Column.new(0, "timestamp", :timestamp),
            Column.new(1, "lhost", :string),
            Column.new(2, "rhost", :string),
            Column.new(3, "alias", :string),
            Column.new(4, "listid", :string),
            Column.new(5, "reason", :string),
            Column.new(6, "action", :string),
            Column.new(7, "subject", :string),
            Column.new(8, "messageid", :string),
            Column.new(9, "smtpagent", :string),
            Column.new(10, "softbounce", :long),
            Column.new(11, "smtpcommand", :string),
            Column.new(12, "destination", :string),
            Column.new(13, "senderdomain", :string),
            Column.new(14, "feedbacktype", :string),
            Column.new(15, "diagnostictype", :string),
            Column.new(16, "deliverystatus", :string),
            Column.new(17, "timezoneoffset", :string),
            Column.new(18, "addresser",:string),
            Column.new(19, "recipient", :string),
            Column.new(20, "addresseralias",:string),
            Column.new(21, "digest",:string),
            Column.new(22, "created_at",:timestamp),
            Column.new(23, "updated_at",:timestamp),
          ]
        else
          raise ArgumentError,"Unkown format type: #{format}"
        end

        format = task["format"]
        inc_delivered = task["include_delivered"]
        extract_mail_address = task["extract_mail_address"]
        Embulk.logger.info "sisimai format: #{format} include_delivered: #{inc_delivered}, extract_mail_address: #{extract_mail_address}"
        yield(task, columns)
      end

      def init
        # initialization code:
        @format = task["format"]
        @inc_delivered = task["include_delivered"]
        @extract_mail_address = task["extract_mail_address"]
      end

      def run(file_input)
        while file = file_input.next_file
          begin
            # Sisimai expects input data is UTF-8 string.
            src = file.read.force_encoding(Encoding::UTF_8)
            mesg = ::Sisimai::Message.new( data: src )
            datas = ::Sisimai::Data.make( data: mesg, delivered: @inc_delivered )
          rescue
            Embulk.logger.error "Error #{$!} #{src}"
            raise
          end
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
            when "sisito"
              column_data = make_sisito_array(data)
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

      def make_sisito_array(data)
        #data.diagnostictype,
        #data.replycode,
        #data.token,

        addresseralias = data.addresser.alias
        addresseralias = data.addresser.to_s if addresseralias.empty?

        now = Time.now
        row = [
          data.timestamp.to_time.utc,
          data.lhost,
          data.rhost,
          data.alias,
          data.listid,
          data.reason,
          data.action,
          data.subject,
          data.messageid,
          data.smtpagent,
          data.softbounce,
          data.smtpcommand,
          data.destination,
          data.senderdomain,
          data.feedbacktype,
          data.diagnosticcode,
          data.deliverystatus,
          data.timezoneoffset,
          data.addresser.to_json,
          data.recipient.to_json,
          addresseralias,
          Digest::SHA1.hexdigest(data.recipient.to_s),
          now,
          now
        ]
      end
    end
  end
end
