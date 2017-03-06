require 'retrospectives'
require 'json'
require 'date'
include Retrospectives

if(ARGV[0].to_s.empty? || ARGV[1].to_s.empty? || ARGV[2].to_s.empty? || ARGV[3].to_s.empty?)
  puts("Usage: ruby #{__FILE__} raw_data_file_path days_old jira_username jira_password. Example :")
  abort("\nruby #{__FILE__} /home/ubuntu/timesheet_data 2 email@domain.com password")
end

raw_data = File.read(ARGV[0])
days = ARGV[1].to_i
username = ARGV[2]
password = ARGV[3]

date = Date.parse(Time.at(((Time.now.to_i / 86400) * 86400) - (86400 * days)).to_s).to_s
parameters = { 'timeSpentSeconds' => nil,
 'started' => "#{date}T12:00:00.00+0000", # UTC 12:00:00 PM of that particular day
 'comment'=> nil
}

puts "Logging hours for #{date} ..."

sleep 2

jira_options = {
  username: username,
  password: password,
  site: 'https://copperegg.atlassian.net'
}

jira_client = RetroSetup.new.authenticate_simple_jira(jira_options)

raw_data.split("\n").each do |line|
  line = line.split(' ')
  ticket_id = line.first
  hours = line.last.to_f
  description = line[1..-2].join(" ")

  next("Ignoring for #{ticket_id}, starts with TG-") if ticket_id.start_with?('TG-')
  next("Ignoring for #{ticket_id}, time not integer") if(hours.nil? || hours == 0.0)

  puts "Logging #{hours} hours for #{ticket_id} with comment #{description}"

  parameters['timeSpentSeconds'] = hours * 3600.0
  parameters['comment'] = description

  typhoeus_response = jira_client.add_worklog(parameters, ticket_id)
  unless typhoeus_response.code.to_s.start_with?('2')
    puts "Response code #{typhoeus_response.code}"
    puts "Response body #{typhoeus_response.options[:response_body]}"
  else
    puts "    Success !    [#{ticket_id}]  [#{description}]  [#{hours}]"
  end
end

