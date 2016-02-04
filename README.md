# Sisimai Analyzer parser plugin for Embulk

Embulk parser plugin for Sisimai bounce mail analyzer. 

## Overview

* **Plugin type**: parser
* **Guess supported**: no

## Configuration

- **format**: output format (`column` or `json`, default: `column`)

## Example

## column format

```yaml
in:
  type: any file input plugin type
  parser:
    type: sisimai_analyzer
    format: column
```

Example output

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
  senderdomain (   string) : example.jp
     smtpagent (   string) : Sendmail
   smtpcommand (   string) : 
    softbounce (     long) : 0
       subject (   string) : MULTIBYTE CHARACTERS HAVE BEEN REMOVED
     timestamp (timestamp) : 2008-09-18 08:54:04 UTC
timezoneoffset (   string) : +0900
         token (   string) : d059e55e074333fe59001b1d30d27da85a1a9c1d
```


## json format

```yaml
in:
  type: any file input plugin type
  parser:
    type: sisimai_analyzer
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

## Install

```
$ embulk gem install embulk-parser-sisimai_analyzer
```

## Build

```
$ rake
```
