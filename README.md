# Sisimai parser plugin for Embulk

Embulk parser plugin for [Sisimai](https://github.com/sisimai/rb-Sisimai)
bounce mail analyzing interface(A successor to bounceHammer).

## Overview

* **Plugin type**: parser
* **Guess supported**: no

## Configuration

- **format**: output format (`column`,`json` or `sisito`, default: `column`)
- **extract_mail_address**: extract mail_address into user, host and verp parts(bool, default: false).
- **include_delivered**: include delivered mail Status: 2.X.Y, (boolean, default: `false`)

The ``extract_mail_address`` parameter is `column` format mode only.
And the `include_delivered` parameter can't use format `sisito`.

## Example

### format: column

```yaml
in:
  type: any file input plugin type
  parser:
    type: sisimai
    format: column
```

Example output

``extract_mail_address``: ``false`` (default)

```
        action (   string) : failed
     addresser (   string) : user1@example.jp
         alias (   string) : 
deliverystatus (   string) : 5.1.2
   destination (   string) : example.gov
diagnosticcode (   string) : 550 Host unknown
diagnostictype (   string) : SMTP
  feedbacktype (   string) : 
         lhost (   string) : 192.0.2.97
        listid (   string) : 
     messageid (   string) : AA406E7E18714AB2927DAACC24B47C4A@USER-PC97
        reason (   string) : hostunknown
     recipient (   string) : domain-does-not-exist@example.gov
     replycode (   string) : 550
         rhost (   string) : example.gov
  senderdomain (   string) : example.jp
     smtpagent (   string) : Sendmail
   smtpcommand (   string) : 
    softbounce (     long) : 0
       subject (   string) : MULTIBYTE CHARACTERS HAVE BEEN REMOVED
     timestamp (timestamp) : 2008-09-18 08:54:04 UTC
timezoneoffset (   string) : +0900
         token (   string) : d059e55e074333fe59001b1d30d27da85a1a9c1d
```

``extract_mail_address``: ``true``

```
        action (   string) : failed
     addresser (   string) : user1@example.jp
         alias (   string) : 
deliverystatus (   string) : 5.1.2
   destination (   string) : example.gov
diagnosticcode (   string) : 550 Host unknown
diagnostictype (   string) : SMTP
  feedbacktype (   string) : 
         lhost (   string) : 192.0.2.97
        listid (   string) : 
     messageid (   string) : AA406E7E18714AB2927DAACC24B47C4A@USER-PC97
        reason (   string) : hostunknown
     recipient (   string) : domain-does-not-exist@example.gov
     replycode (   string) : 550
         rhost (   string) : example.gov
  senderdomain (   string) : example.jp
     smtpagent (   string) : Sendmail
   smtpcommand (   string) : 
    softbounce (     long) : 0
       subject (   string) : MULTIBYTE CHARACTERS HAVE BEEN REMOVED
     timestamp (timestamp) : 2008-09-18 08:54:04 UTC
timezoneoffset (   string) : +0900
         token (   string) : d059e55e074333fe59001b1d30d27da85a1a9c1d
addresser_user (   string) : user1
addresser_host (   string) : example.jp
addresser_vrep (   string) : 
recipient_user (   string) : domain-does-not-exist
recipient_host (   string) : example.gov
recipient_vrep (   string) : 
```


### format: json

```yaml
in:
  type: any file input plugin type
  parser:
    type: sisimai
    format: json
```

```
result (json) : { "token": "d059e55e074333fe59001b1d30d27da85a1a9c1d", "lhost": "192.0.2.97", "rhost": "example.gov", "listid": "", "alias": "", "reason": "hostunknown", "subject": "MULTIBYTE CHARACTERS HAVE BEEN REMOVED", "messageid": "AA406E7E18714AB2927DAACC24B47C4A@USER-PC97", "smtpagent": "Sendmail", "smtpcommand": "", "destination": "example.gov", "diagnosticcode": "550 Host unknown", "senderdomain": "example.jp", "deliverystatus": "5.1.2", "timezoneoffset": "+0900", "feedbacktype": "", "diagnostictype": "SMTP", "action": "failed", "replycode": "550", "softbounce": 0, "addresser": "user1@example.jp", "recipient": "domain-does-not-exist@example.gov", "timestamp": 1221728044 }
```


```json
{
  "token": "d059e55e074333fe59001b1d30d27da85a1a9c1d",
  "lhost": "192.0.2.97",
  "rhost": "example.gov",
  "listid": "",
  "alias": "",
  "reason": "hostunknown",
  "subject": "MULTIBYTE CHARACTERS HAVE BEEN REMOVED",
  "messageid": "AA406E7E18714AB2927DAACC24B47C4A@USER-PC97",
  "smtpagent": "Sendmail",
  "smtpcommand": "",
  "destination": "example.gov",
  "diagnosticcode": "550 Host unknown",
  "senderdomain": "example.jp",
  "deliverystatus": "5.1.2",
  "timezoneoffset": "+0900",
  "feedbacktype": "",
  "diagnostictype": "SMTP",
  "action": "failed",
  "replycode": "550",
  "softbounce": 0,
  "addresser": "user1@example.jp",
  "recipient": "domain-does-not-exist@example.gov",
  "timestamp": 1221728044
}
```

### format: sisimai

[sisito](https://github.com/winebarrel/sisito) is the GUI interface for libsisimai.
The following cofiguration import bounce mails into sisito database.

```yaml
in:
  path_prefix: path/to/maildir
  type: file
  parser:
    type: sisimai
    format: sisito
out:
  type: mysql
  host: localhost
  user: user
  password: password
  mode: replace
  database: maillog_test
  table: bounce_mails # Don't change. sisito use this table name
  column_options:
    created_at: { type: datetime }
    updated_at: { type: datetime }
```


## Install

```
$ embulk gem install embulk-parser-sisimai
```

## Build

```
$ rake
```
