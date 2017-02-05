require 'retrospectives'
require 'json'
include Retrospectives

def success?(typhoeus_response)
  unless typhoeus_response.code.to_s.start_with?('2')
    puts "Response code #{typhoeus_response.code}"
    puts "Response body #{typhoeus_response.body}"
    false
  else
    true
  end
end

STORY_POINT_CUSTOM_FIELD = 'customfield_10004'

jira_options = {
  username: 'gagandeep.singh@kickdrumtech.com',
  password: 'gagan1dinesh',
  site: 'https://copperegg.atlassian.net'
}

members_username_mapping = { 'Gagan' => 'gagandeep.singh',
  'Neelakshi' => 'Neelakshi',
  'Sweta' => 'SwetaSharma',
  'Dinesh' => 'DineshYadav',
  'Ankit' => 'ankit'
}

retro = RetroSetup.new

google_client = retro.authenticate_google_drive('../config.json')
jira_client = retro.authenticate_simple_jira(jira_options)

sprint_sheet_key = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'
ws = google_client.spreadsheet_by_key(sprint_sheet_key).worksheets[2]

(1..50).each do |row_index|
  next unless ws[row_index, 1].include?('CE-')

  ticket = ws[row_index, 1]
  sp = ws[row_index, 5]
  assignee = members_username_mapping[ws[row_index, 6]]

  next("incomplete data in row #{row_index}") if(ticket.nil? || ticket.empty? || sp.to_s.nil? ||
                                                 sp.empty? || assignee.nil? || assignee.empty?)

  resp1 = jira_client.update_assignee(assignee, ticket)
  resp2 = jira_client.update_custom_field({ STORY_POINT_CUSTOM_FIELD => sp.to_i}, ticket)

  puts "Success !  [#{ticket}]" if (success?(resp1) && success?(resp2))
end
