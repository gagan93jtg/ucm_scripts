require 'retrospectives'
require 'json'
include Retrospectives

HEADERS = ['Key', 'Summary', 'Status', 'Estimation owner', 'Poker/Assigned SPs', 'Ticket owner',
 'Reviewer', 'Comment']

 STORY_POINT_CUSTOM_FIELD = 'customfield_10004'
 SPRINT_SHEET_KEY = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'

 def get_member_name(username)
  members_username_mapping = { 'gagandeep.singh' => 'Gagan',
    'Neelakshi' => 'Neelakshi',
    'SwetaSharma' => 'Sweta',
    'DineshYadav' => 'Dinesh',
    'ankit' => 'Ankit',
    'ogkosal' => 'Kosal',
    'shankar' => 'Shankar'
  }
  members_username_mapping[username] ||
  username.gsub('.', ' ').gsub('_', ' ').gsub('-', ' ').split.map(&:capitalize)*' '
end

def row_is_blank?(subsheet, row)
  blank = true

  (1..HEADERS.count).each do |index|
    blank = false unless subsheet[row, index].to_s.empty?
  end
  blank
end

def get_sprint_sheet_tickets(subsheet)
  old_data = Array.new

  (2..200).each do |row|
    next if row_is_blank?(subsheet, row)

    old_data_row = {}
    key = nil
    HEADERS.each_with_index do |header, column|
      if header == 'Key'
        key = subsheet[row, column + 1]
        #puts "jey h #{key}"
      else
        header_key = {}
        header_key[header] = subsheet[row, column + 1]
        if old_data_row[key].nil?
          old_data_row[key] = header_key
        else
          old_data_row[key].merge!(header_key)
        end
        #puts "header_key : #{header_key}, old_data_row[key] : #{old_data_row[key]}"
      end
    end

    old_data.push(old_data_row)
  end

  old_data
end


if(ARGV[0].to_s.empty? || ARGV[1].to_s.empty? || ARGV[2].to_s.empty? || ARGV[3].to_s.empty? ||
 ARGV[4].to_s.empty? || ARGV[5].to_s.empty?)
puts("Usage: ruby #{__FILE__} jira_username jira_password google_config_json_file_path sprint_id sprint_name. Example:")
abort("\nruby #{__FILE__} email@domain.com password ~/config.json 96 Feb II")
end

jira_username = ARGV[0]
jira_password = ARGV[1]
google_json_path = ARGV[2]
sprint_id = ARGV[3]
sprint_name = ARGV[4] + ' ' + ARGV[5]

all_rows = Array.new
subsheet_index = nil
sprint_sheet_tickets = Array.new
retro = RetroSetup.new

jira_options = { username: jira_username,
 password: jira_password,
 site: 'https://copperegg.atlassian.net',
 context_path: '',
 auth_type: :basic }

 google_client = retro.authenticate_google_drive(google_json_path)
 jira_client = retro.authenticate_jira(jira_options)

 issues = jira_client.Issue.jql("Sprint in (#{sprint_id}) ORDER BY Rank")
 all_subsheets = google_client.spreadsheet_by_key(SPRINT_SHEET_KEY).worksheets

 all_subsheets.each_with_index do |subsheet, index|
  subsheet_index = index if(subsheet.title == sprint_name)
end

if subsheet_index.nil?
  abort("Create a subsheet with name '#{sprint_name}' in this sheet : #{all_subsheets.first.human_url}")
else
  puts "Using subsheet no. #{subsheet_index + 1} [index starts from 1]"
end
subsheet = all_subsheets[subsheet_index]

sprint_sheet_tickets = get_sprint_sheet_tickets(subsheet)

p sprint_sheet_tickets.inspect
abort("done")

all_rows.push(HEADERS)

issues.each do |issue|
  key = issue.attrs['key']
  summary = issue.attrs['fields']['summary']
  status = 'Open'
  estimation_owner = ''
  sps = issue.attrs['fields'][STORY_POINT_CUSTOM_FIELD]
  ticket_owner = get_member_name(issue.attrs['fields']['assignee']['name'])
  reviewer = ''
  comments = ''

  row = [key, summary, status, estimation_owner, sps, ticket_owner, reviewer, comments]
  all_rows.push(row)
end

subsheet.update_cells(1, 1, all_rows)
subsheet.save
