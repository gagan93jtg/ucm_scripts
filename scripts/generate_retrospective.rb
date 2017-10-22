#!/usr/bin/env ruby

require 'retrospectives'
require_relative '../utils/load_jira_auth.rb'

include Retrospectives

members =  [{name: 'Gagan', username: 'gagandeep.singh', bandwidth: 1, days_worked: 8,
             sheet_key: '1bitkGbG_o5XbmTFD385Yn61d6oM6p8vJcondhh1pFjM', sheet_index: 1},
            {name: 'Neelakshi', username: 'Neelakshi', bandwidth: 1, days_worked: 9,
             sheet_key: '1iYqA1irBBpktV3ssvxeZRuzkzAZ9RFqYcqI26kJUrSI', sheet_index: 1},
            {name: 'Dinesh', username: 'DineshYadav', bandwidth: 1, days_worked: 9,
             sheet_key: '1qwx--iJ14ZI9hUgumdixove9aeoQU-oZibKi80QLICQ', sheet_index: 1},
            {name: 'Sweta', username: 'SwetaSharma', bandwidth: 1, days_worked: 5,
             sheet_key: '1SyX2-62EQxSjvehcYMSknXM0HsPuoOv4_e-s2LBkbJU', sheet_index: 1},
            {name: 'Rohan', username: 'Rohan', bandwidth: 1, days_worked: 9,
             sheet_key: '1tZw7R_b40JogGRhXbVKRXaQpDlOB7JX-gd_DuPg_4tw', sheet_index: 1}]

jira_options = {
  username: JiraAuth::USERNAME,
  password: JiraAuth::PASSWORD,
  site: JiraAuth::SITE,
  context_path: '',
  auth_type: :basic
}


###################################################################################################
## YOU MAY WANT TO CHANGE THESE PARAMETERS AS THE SPRINT CHANGES OR IF YOU CHANGE GOOGLE SHEETS ###
###################################################################################################

google_drive_config_file = ENV['HOME'] + '/google_auth.json'
ignore_tickets_starting_with = 'TR,TG,INTERNAL,RETRO,PROJECT,Story ID,CR'
time_frame = '20171003 - 20171015'
retrospective_sheet_key = '10gXrYfaQv31v2tUW2z0esm4PPkxy05OTvQrf7fLpluE'
sprint_sheet_key = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'
sprint_sub_sheet_title = 'Oct I'
sprint_id = '114'
include_other_tickets = true
get_total_sps = true
get_jira_hours = false
start_row_for_tickets = 24
project_misc_ticket_ids = ['PROJECT', 'P', 'CE-3063', 'CE-3064', 'CE-3065', 'CE-3066']
company_internal_ticket_ids = ['CR', 'INTERNAL', 'I']


###################################################################################################
#### DON'T TOUCH CODE BELOW UNLESS YOU WANT TO CHANGE THE THINGS WHICH ARE GENERATED IN A RETRO ###
###################################################################################################


retro = RetroSetup.new
RetroSetup.debug = true
retro.authenticate_google_drive(google_drive_config_file)
retro.authenticate_jira(jira_options)
retro.members = members
retro.ignore_issues_for_jira_calls=(ignore_tickets_starting_with)
retro.time_frame = time_frame
retro.retrospective_sheet_key = retrospective_sheet_key
retro.sprint_id = sprint_id
retro.include_other_tickets = include_other_tickets
retro.get_tickets_from_sprint_sheet(sprint_sheet_key, sprint_sub_sheet_title)
retro.get_total_sps = get_total_sps
retro.get_jira_hours = get_jira_hours
retro.start_row_for_tickets = start_row_for_tickets
retro.project_misc_ticket_ids = project_misc_ticket_ids
retro.company_internal_ticket_ids = company_internal_ticket_ids
retro.generate!
