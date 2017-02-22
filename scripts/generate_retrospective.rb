require 'retrospectives'

include Retrospectives

(0..1).each do |index|
  if(ARGV[index].to_s.empty?)
    puts("Usage: ruby #{__FILE__} jira_username jira_password . Example :")
    abort("\nruby #{__FILE__} my_username password")
  end
end

members =  [{name: 'ankit', sheet_key: '16R3PBB-Z6diji3Yxsh_V4EskSZYkDdw7SFtoXXkYUrk'},
            {name: 'gagandeep.singh', sheet_key: '1bitkGbG_o5XbmTFD385Yn61d6oM6p8vJcondhh1pFjM'},
            {name: 'Neelakshi', sheet_key: '1iYqA1irBBpktV3ssvxeZRuzkzAZ9RFqYcqI26kJUrSI'},
            {name: 'DineshYadav', sheet_key: '1qwx--iJ14ZI9hUgumdixove9aeoQU-oZibKi80QLICQ'},
            {name: 'SwetaSharma', sheet_key: '1SyX2-62EQxSjvehcYMSknXM0HsPuoOv4_e-s2LBkbJU'}]

jira_options = {
  username: ARGV[0],
  password: ARGV[1],
  site: 'https://copperegg.atlassian.net/',
  context_path: '',
  auth_type: :basic
}


###################################################################################################
## YOU MAY WANT TO CHANGE THESE PARAMETERS AS THE SPRINT CHANGES OR IF YOU CHANGE GOOGLE SHEETS ###
###################################################################################################

google_drive_config_file = '/home/cuegg/copperegg docs/config.json'
ignore_tickets_starting_with = 'TR,TG,MISC,TI'
time_frame = '20170117 - 20170201'
retrospective_sheet_key = '10gXrYfaQv31v2tUW2z0esm4PPkxy05OTvQrf7fLpluE'
sprint_sheet_key = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'
sprint_sub_sheet_title = 'Jan II'
sprint_id = '94'
include_other_tickets = true


###################################################################################################
#### DON'T TOUCH CODE BELOW UNLESS YOU WANT TO CHANGE THE THINGS WHICH ARE GENERATED IN A RETRO ###
###################################################################################################


retro = RetroSetup.new
retro.authenticate_google_drive(google_drive_config_file)
retro.authenticate_jira(jira_options)
retro.members = members
retro.ignore_issues_starting_with=(ignore_tickets_starting_with)
retro.time_frame = time_frame
retro.retrospective_sheet_key = retrospective_sheet_key
retro.sprint_id = sprint_id
retro.include_other_tickets = include_other_tickets
retro.get_tickets_from_sprint_sheet(sprint_sheet_key, sprint_sub_sheet_title)
rows = retro.generate!
