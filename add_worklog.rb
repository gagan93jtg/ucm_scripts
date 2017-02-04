require 'json'
require 'typhoeus'
require 'date'

if(ARGV[0].nil? || ARGV[1].to_i == 0 || ARGV[2].to_s.empty?)
  puts("Usage: ruby #{__FILE__} raw_data_file_path days_old jira_username_colon_password. Example :")
  abort("\nruby #{__FILE__} /home/ubuntu/timesheet_data 2 email@domain.com:password")
end

raw_data = File.read(ARGV[0])
days = ARGV[1].to_i
auth = ARGV[2]
date = Date.parse(Time.at(((Time.now.to_i / 86400) * 86400) - (86400 * days)).to_s).to_s
parameters = { 'timeSpentSeconds' => nil,
 'started' => "#{date}T12:00:00.00+0000", # UTC 12:00:00 PM of that particular day
 'comment'=> nil
}

puts "Logging hours for #{date} ..."

sleep 2

headers = {'content-type' => 'application/json'}

raw_data.split("\n").each do |line|
  line = line.split(' ')
  ticket_id = line.first
  hours = line.last.to_f
  description = line[1..-2].join(" ")

  next("Ignoring for #{ticket_id}, doesn't start with CE-") unless ticket_id.include?('CE-')
  next("Ignoring for #{ticket_id}, time not integer") if(hours.nil? || hours == 0.0)

  puts "Logging #{hours} hours for #{ticket_id} with comment #{description}"

  url = "https://copperegg.atlassian.net/rest/api/2/issue/#{ticket_id}/worklog"
  parameters['timeSpentSeconds'] = hours * 3600.0
  parameters['comment'] = description
  begin
    resp = Typhoeus::Request.post(url, body: parameters.to_json, headers: headers, userpwd: auth)
    puts "Response code for #{ticket_id} : #{resp.code}"
  rescue StandardError => e
    puts "Exception #{e.message} for #{ticket_id}"
  end
end

