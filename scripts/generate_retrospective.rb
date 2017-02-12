require 'retrospectives'

include Retrospectives

members =
  [{name: 'ankit', sheet_key: '16R3PBB-Z6diji3Yxsh_V4EskSZYkDdw7SFtoXXkYUrk'},
   {name: 'gagandeep.singh', sheet_key: '1bitkGbG_o5XbmTFD385Yn61d6oM6p8vJcondhh1pFjM'},
   {name: 'Neelakshi', sheet_key: '1iYqA1irBBpktV3ssvxeZRuzkzAZ9RFqYcqI26kJUrSI', sheet_index: 0},
   {name: 'DineshYadav', sheet_key: '1qwx--iJ14ZI9hUgumdixove9aeoQU-oZibKi80QLICQ'},
   {name: 'marutinandan.pandya', 'sheet_key': '11l0LrnzNCAAm4OZGMEWVuUdakj52IZIgdYTgLm9--KQ', sheet_index: 1},
   {name: 'SwetaSharma', sheet_key: '1SyX2-62EQxSjvehcYMSknXM0HsPuoOv4_e-s2LBkbJU'}]

#tickets =
#  ['CE-1095', 'CE-1066', 'CE-1210', 'CE-1211', 'CE-1400', 'CE-1511', 'CE-1520']

jira_options = {
  username: 'gagandeep.singh@kickdrumtech.com',
  password: 'gagan1dinesh',
  site: 'https://copperegg.atlassian.net/',
  context_path: '',
  auth_type: :basic
}

retro = RetroSetup.new

retro.authenticate_google_drive('/home/josh/Desktop/copperegg docs/config.json')
  retro.authenticate_jira(jira_options)
#retro.tickets = tickets
retro.members = members
retro.ignore_issues_starting_with=('TR,TG,MISC,TI')
retro.time_frame = '20170102 - 20170117'
retro.retrospective_sheet_key = '10gXrYfaQv31v2tUW2z0esm4PPkxy05OTvQrf7fLpluE'
retro.sprint_id = '93'
retro.include_other_tickets = true

rows = retro.generate!
