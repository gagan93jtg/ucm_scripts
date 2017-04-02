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

if(ARGV[0].to_s.empty? || ARGV[1].to_s.empty? || ARGV[2].to_s.empty?)
  puts("Usage: ruby #{__FILE__} jira_username jira_password google_config_json_file_path. Example:")
  abort("\nruby #{__FILE__} email@domain.com password ~/config.json")
end

username = ARGV[0]
password = ARGV[1]
google_json_path = ARGV[2]

STORY_POINT_CUSTOM_FIELD = 'customfield_10004'
SPRINT_SHEET_KEY = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'

jira_options = {
  username: username,
  password: password,
  site: 'https://copperegg.atlassian.net'
}

members_username_mapping = { 'Gagan' => 'gagandeep.singh',
  'Neelakshi' => 'Neelakshi',
  'Sweta' => 'SwetaSharma',
  'Dinesh' => 'DineshYadav',
}

retro = RetroSetup.new

google_client = retro.authenticate_google_drive(google_json_path)
jira_client = retro.authenticate_simple_jira(jira_options)

ws = google_client.spreadsheet_by_key(SPRINT_SHEET_KEY).worksheets[0]

puts "worksheet : #{ws.title}"
(1..23).each do |row_index|
  next unless ws[row_index, 1].include?('CE-')
  ticket = ws[row_index, 1]
  sp = ws[row_index, 7]
  assignee = members_username_mapping[ws[row_index, 5]]

  next("incomplete data in row #{row_index}") if(ticket.nil? || ticket.empty? || sp.to_s.nil? ||
                                                 sp.empty? || assignee.nil? || assignee.empty?)
  resp1 = jira_client.update_assignee(assignee, ticket)
  resp2 = jira_client.update_custom_field({ STORY_POINT_CUSTOM_FIELD => sp.to_i}, ticket)
  resp3 = jira_client.update_custom_field({'timetracking'=>{'originalEstimate'=>"#{sp.to_i * 4}h"}}, ticket)

  puts "Success !  [#{ticket}]" if (success?(resp1) && success?(resp2) && success?(resp3))
end
