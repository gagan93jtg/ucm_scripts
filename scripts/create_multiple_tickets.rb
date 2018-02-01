#!/usr/bin/env ruby

require 'retrospectives'
require_relative '../utils/load_jira_auth.rb'

include Retrospectives

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

retro = RetroSetup.new

jira_client = retro.authenticate_jira(jira_options)

summaries = ['Summary 1',
  'Summary 2',
  'Summary n'
]
sps = [1, 2, 3]
summaries.each_with_index do |summary, index|
  issue_hash = {
    'fields'=>
    {
      'summary' => summary,
      'project' => {'id' => PROJECT_ID},
      'issuetype' => ISSUE_TYPE,
      'customfield_10004' => sps[index]
     }
  }
  issue = jira_client.Issue.build
  response = issue.save(issue_hash)

  p "Created issue #{summary} #{response.inspect}"
end
