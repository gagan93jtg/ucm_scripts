#!/usr/bin/env ruby

require 'retrospectives'
require_relative '../utils/load_jira_auth.rb'

include Retrospectives

(0..2).each do |index|
  if(ARGV[index].to_s.empty?)
    puts("Usage: ruby #{__FILE__} sprint_index time_start time_end. Example :")
    abort("\nruby #{__FILE__} 1 20170216 20170228")
  end
end

# this is index of sprint sheet in sprint plans sheet (index starts from are from 0)
SPRINT_INDEX = ARGV[0].to_i

jira_options = {
  username: JiraAuth::USERNAME,
  password: JiraAuth::PASSWORD,
  site: JiraAuth::SITE
  context_path: '',
  auth_type: :basic
}

members = [{name: 'Gagan', username: 'gagandeep.singh', sheet_key: '1bitkGbG_o5XbmTFD385Yn61d6oM6p8vJcondhh1pFjM'},
 {name: 'Neelakshi', username: 'Neelakshi', sheet_key: '1iYqA1irBBpktV3ssvxeZRuzkzAZ9RFqYcqI26kJUrSI'},
 {name: 'Dinesh', username: 'DineshYadav', sheet_key: '1qwx--iJ14ZI9hUgumdixove9aeoQU-oZibKi80QLICQ'}]
 {name: 'SwetaSharma', sheet_key: '1SyX2-62EQxSjvehcYMSknXM0HsPuoOv4_e-s2LBkbJU'}]

#
total_hours_spent_per_person = Hash.new(0)

retro = RetroSetup.new
retro.authenticate_google_drive(ENV['HOME'] + '/google_auth.json')
retro.authenticate_jira(jira_options)
retro.time_frame = "#{ARGV[1]} - #{ARGV[2]}"
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
