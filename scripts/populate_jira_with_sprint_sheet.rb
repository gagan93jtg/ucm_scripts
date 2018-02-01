#!/usr/bin/env ruby

require 'retrospectives'
require_relative '../utils/load_jira_auth.rb'

include Retrospectives

def success?(typhoeus_response)
  return unless typhoeus_response

  unless typhoeus_response.code.to_s.start_with?('2')
    puts "Response code #{typhoeus_response.code}"
    puts "Response body #{typhoeus_response.body}"
    false
  else
    true
  end
end

STORY_POINT_CUSTOM_FIELD = 'customfield_10004'
SPRINT_SHEET_KEY = '1ARZ8RqHeNtj7lEdawCm1PX6HPXICMo3BnZ88bPXrUXA'

jira_options = {
  username: JiraAuth::USERNAME,
  password: JiraAuth::PASSWORD,
  site: JiraAuth::SITE
}

members_username_mapping = { 'Gagan' => 'gagandeep.singh',
  'Neelakshi' => 'Neelakshi',
  'Sweta' => 'SwetaSharma',
  'Dinesh' => 'DineshYadav',
}

retro = RetroSetup.new

google_client = retro.authenticate_google_drive(ENV['HOME'] + '/google_auth.json')
jira_client = retro.authenticate_simple_jira(jira_options)

ws = google_client.spreadsheet_by_key(SPRINT_SHEET_KEY).worksheets[0]

puts 'Hope you have added correct status (carry fwd/pcr) in front of carry fwd tickets to avoid SP change'
puts 'Press any key to continue'
temp = $stdin.gets

puts "worksheet : #{ws.title}"
(1..40).each do |row_index|
  next unless ws[row_index, 1].include?('CE-')
  ticket = ws[row_index, 1]
  sp = ws[row_index, 7]
  status = ws[row_index, 4].downcase
  assignee = members_username_mapping[ws[row_index, 5].split("(")[0]]

  next("incomplete data in row #{row_index}") if(ticket.nil? || ticket.empty? || sp.to_s.nil? ||
                                                 sp.empty? || assignee.nil? || assignee.empty?)
  resp1 = jira_client.update_assignee(assignee, ticket)
  if !(status.include?('carry') || status.include?('pcr'))
    resp2 = jira_client.update_custom_field({ STORY_POINT_CUSTOM_FIELD => sp.to_i}, ticket)
  end
  resp3 = jira_client.update_custom_field({'timetracking'=>{'originalEstimate'=>"#{sp.to_i * 4}h"}}, ticket)

  puts "Success !  [#{ticket}]" if (success?(resp1) && success?(resp2) && success?(resp3))
end
