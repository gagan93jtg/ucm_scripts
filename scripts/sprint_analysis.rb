require 'retrospectives'

include Retrospectives

(0..5).each do |index|
  if(ARGV[index].to_s.empty?)
    puts("Usage: ruby #{__FILE__} jira_username jira_password sprint_index time_start time_end google_config_json. Example :")
    abort("\nruby #{__FILE__} my_username password 1 20170216 20170228 /home/ubuntu/config.json")
  end
end

# this is index of sprint sheet in sprint plans sheet (indexes are from 0)
SPRINT_INDEX = ARGV[2].to_i

jira_options = {
  username: ARGV[0],
  password: ARGV[1],
  site: 'https://copperegg.atlassian.net/',
  context_path: '',
  auth_type: :basic
}


members = [{name: 'gagandeep.singh', sheet_key: '1bitkGbG_o5XbmTFD385Yn61d6oM6p8vJcondhh1pFjM'},
 {name: 'Neelakshi', sheet_key: '1iYqA1irBBpktV3ssvxeZRuzkzAZ9RFqYcqI26kJUrSI'},
 {name: 'DineshYadav', sheet_key: '1qwx--iJ14ZI9hUgumdixove9aeoQU-oZibKi80QLICQ'},
 {name: 'SwetaSharma', sheet_key: '1SyX2-62EQxSjvehcYMSknXM0HsPuoOv4_e-s2LBkbJU'}]

#
total_hours_spent_per_person = Hash.new(0)

retro = RetroSetup.new
retro.authenticate_google_drive(ARGV[5])
retro.authenticate_jira(jira_options)
retro.time_frame = "#{ARGV[3]} - #{ARGV[4]}"
retro.members = members
sheet = retro.get_sheet('1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA', SPRINT_INDEX)
retro.get_tickets(sheet)

FetchHours.from_jira(retro)

retro.members.each do |member|
  total_hours_spent_per_person[member.name] = member.hours_spent_jira.values.inject(:+)
end

total_hours_spent_per_person.each do |k, v|
  v ||= 0
  puts "Hours spent by #{k} on JIRA : #{v.round(2)}"
end
