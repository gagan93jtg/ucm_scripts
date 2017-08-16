require 'retrospectives'
require 'json'
include Retrospectives

if(ARGV[0].to_s.empty? || ARGV[1].to_s.empty? || ARGV[2].to_s.empty?)
  puts("Usage: ruby #{__FILE__} jira_username jira_password jira_sprint_number Example:")
  abort("\nruby #{__FILE__} email@domain.com password 72")
end

username = ARGV[0]
password = ARGV[1]
sprint_number = ARGV[2].to_i

PROJET_ID = 10000
ISSUE_TYPE = {"self"=> "https://copperegg.atlassian.net/rest/api/2/issuetype/3",
  "id"=>"3",
  "description"=>"A task that needs to be done.",
  "iconUrl"=>"https://copperegg.atlassian.net/secure/viewavatar?size=xsmall&avatarId=10818&avatarType=issuetype",
  "name"=>"Task",
  "subtask"=>false,
  "avatarId"=>10818
}

jira_options = {
  username: username,
  password: password,
  site: 'https://copperegg.atlassian.net',
  context_path: '',
  auth_type: :basic
}

retro = RetroSetup.new

jira_client = retro.authenticate_jira(jira_options)

summaries = ['MISC Ticket', 'Standup Hours', 'Staging Deploy', 'Production Deploy']

sprint_number -= 37 # sprint id and number are different
summaries.each do |summary|
  t_summary = summary + " - Sprint #{sprint_number}"
  issue_hash = {
    "fields"=>
    {
      "summary"=>t_summary,
      "project"=>{"id"=> PROJET_ID},
      "issuetype"=>ISSUE_TYPE
     }
  }
  issue = jira_client.Issue.build
  response = issue.save(issue_hash)

  p "Created issue #{t_summary} #{response.inspect}"
end
