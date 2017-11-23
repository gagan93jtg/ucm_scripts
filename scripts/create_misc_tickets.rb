#!/usr/bin/env ruby

require 'retrospectives'
require_relative '../utils/load_jira_auth.rb'

include Retrospectives

if(ARGV[0].to_s.empty?)
  puts("Usage: ruby #{__FILE__} jira_sprint_number Example:")
  abort("\nruby #{__FILE__} 72")
end

sprint_number = ARGV[0].to_i

PROJECT_ID = 10000
ISSUE_TYPE = {
  'self' =>  'https://copperegg.atlassian.net/rest/api/2/issuetype/3',
  'id' => '3',
  'description' => 'A task that needs to be done.',
  'iconUrl' => 'https://copperegg.atlassian.net/secure/viewavatar?size=xsmall&avatarId=10818&avatarType=issuetype',
  'name' => 'Task',
  'subtask' => false,
  'avatarId' => 10818
}

jira_options = {
  username: JiraAuth::USERNAME,
  password: JiraAuth::PASSWORD,
  site: JiraAuth::SITE,
  context_path: '',
  auth_type: :basic
}

puts jira_options

retro = RetroSetup.new

jira_client = retro.authenticate_jira(jira_options)

summaries = ['MISC Ticket', 'Standup hours', 'Staging Deployment', 'Production Deployment']

sprint_number -= 37 # sprint id and number are different


summaries.each do |summary|
  t_summary = summary + " - Sprint #{sprint_number}"
  issue_hash = {
    'fields'=>
    {
      'summary' => t_summary,
      'project' => {'id' => PROJECT_ID},
      'issuetype' => ISSUE_TYPE,
      'customfield_10007' => sprint_number + 37
     }
  }
  issue = jira_client.Issue.build
  response = issue.save(issue_hash)

  p "Created issue #{t_summary} #{response.inspect}"
end
