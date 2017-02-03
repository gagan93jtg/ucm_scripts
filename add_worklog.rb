require 'json'
require 'typhoeus'

abort("Usage: #{__FILE__} raw_data_file_path")if ARGV[0].nil?

raw_data = File.read(ARGV[0])

parameters = { 'timeSpentSeconds' => '',
 'started' => '2017-02-01T12:00:00.00+0000',
 'comment'=> ''
}

headers = {'content-type' => 'application/json'}
auth = 'gagandeep.singh@kickdrumtech.com:gagan1dinesh'


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

