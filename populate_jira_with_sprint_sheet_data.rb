# SPs, assignees only

require 'retrospectives'
require 'json'
include Retrospectives


jira_options = {
  username: 'gagandeep.singh@kickdrumtech.com',
  password: 'gagan1dinesh',
  site: 'https://copperegg.atlassian.net',
  context_path: '',
  auth_type: :basic,
  http_debug: true
}

members = { 'Gagan': 'gagandeep.singh',
  'Neelakshi': 'Neelakshi',
  'Sweta': 'SwetaSharma',
  'Dinesh': 'DineshYadav',
  'Ankit': 'ankit'
}

retro = RetroSetup.new

google_client = retro.authenticate_google_drive('../config.json')
jira_client = retro.authenticate_jira(jira_options)

sprint_sheet_key = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'
ws = google_client.spreadsheet_by_key(sprint_sheet_key).worksheets[2]

update_json = {
  fields:
  {
    customfield_10004:4
  }
}

(1..20).each do |row_index|
  next unless ws[row_index, 1].include?('CE-')

  #puts "#{ws[row_index,1]}, #{ws[row_index,5]}"
  update_json[:fields][:customfield_10004] = ws[row_index, 5]
  parameters = {'fields'=> {'assignee'=> {'name'=> 'Neelakshi'}}}.to_json
  headers = {"content-type" => "application/json"}
  url = "https://copperegg.atlassian.net/rest/api/2/issue/#{ticket}"
  auth = 'gagandeep.singh@kickdrumtech.com:gagan1dinesh'

  Typhoeus::Request.put(url, body: parameters, headers: headers, userpwd: auth, verbose: true)

  break
end




#system("curl -D- -u gagandeep.singh@kickdrumtech.com:gagan1dinesh -X PUT -d $update -H \"Content-Type: application/json\" https://copperegg.atlassian.net/rest/api/2/issue/CE-2653")

