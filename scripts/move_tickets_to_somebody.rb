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


jira_options = {
  username: JiraAuth::USERNAME,
  password: JiraAuth::PASSWORD,
  site: JiraAuth::SITE
}

members_username_mapping = { 'Gagan' => 'gagandeep.singh',
  'Neelakshi' => 'Neelakshi',
  'Sweta' => 'SwetaSharma',
  'Dinesh' => 'DineshYadav',
  'Shilpa' => 'Shilpa'
}

retro = RetroSetup.new

tickets = []
assignee = members_username_mapping['Shilpa']

tickets.each do |ticket|
  resp1 = jira_client.update_assignee(assignee, ticket)

  puts "Success !  [#{ticket}]" if success?(resp1)
end
