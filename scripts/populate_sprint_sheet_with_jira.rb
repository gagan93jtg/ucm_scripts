require 'retrospectives'
require 'json'
include Retrospectives

HEADERS = ['Key', 'Summary', 'Type', 'Status', 'Owner']

STORY_POINT_CUSTOM_FIELD = 'customfield_10004'
SPRINT_SHEET_KEY = '1UCBgSJkOJvMBZfAqAtlyQWakxkCqZ7kLO1nTCFX-GYA'
UPTIME_CLOUD_MONITOR_BOARD_ID = 1
TICKET_COUNT = 25


def get_member_name(username)
  members_username_mapping = { 'gagandeep.singh' => 'Gagan',
    'Neelakshi' => 'Neelakshi',
    'SwetaSharma' => 'Sweta',
    'DineshYadav' => 'Dinesh',
    'ankit' => 'Ankit',
    'ogkosal' => 'Kosal',
    'shankar' => 'Shankar' }

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
      else
        header_key = {}
        header_key[header] = subsheet[row, column + 1]
        if old_data_row[key].nil?
          old_data_row[key] = header_key
        else
          old_data_row[key].merge!(header_key)
        end
      end
    end

    old_data.push(old_data_row)
  end

  old_data
end


def merge_jira_data_with_existing_data(jira_data_array, sprint_sheet_data_array)
  return if sprint_sheet_data_array.nil? || sprint_sheet_data_array.empty?

  sprint_sheet_tickets_only = []
  sprint_sheet_data_array.each { |element| sprint_sheet_tickets_only.push(*element.keys) }

  jira_data_array.each_with_index do |jira_row, row|
    issue_key = jira_row.first
    if sprint_sheet_tickets_only.include?(issue_key)
      issue = sprint_sheet_data_array.select {|ticket| ticket.values if ticket.keys == [issue_key]}
      issue_attrs = issue.first[issue_key]
      jira_data_array[row][1] = issue_attrs['Summary']
      jira_data_array[row][2] = issue_attrs['Type']
      jira_data_array[row][3] = issue_attrs['Status']
      jira_data_array[row][4] = issue_attrs['Ticket owner']
      jira_data_array[row][5] = issue_attrs['Reviewer']
      jira_data_array[row][6] = issue_attrs['Poker/Assigned SPs']
      jira_data_array[row][7] = issue_attrs['Estimation owner']
    end
  end
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

#
google_client = retro.authenticate_google_drive(google_json_path)
jira_client = retro.authenticate_jira(jira_options)

if sprint_id == 'backlog'
  simple_jira_client = retro.simple_jira_wrapper
  issues = simple_jira_client.get_tickets_from_backlog(UPTIME_CLOUD_MONITOR_BOARD_ID, TICKET_COUNT)
else
  issues = jira_client.Issue.jql("Sprint in (#{sprint_id}) ORDER BY Rank")
end
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

sprint_sheet_existing_tickets = get_sprint_sheet_tickets(subsheet)

subsheet.update_cells(1, 1, [HEADERS])

issues.each do |issue|
  if issue.respond_to?('attrs')
    issue_state =  issue.attrs['fields']['status']['name']
    puts "Issue state : #{issue_state} for #{issue.attrs['key']}"
    next if issue_state == 'Closed' || issue_state == 'Accepted' || issue_state == 'Defer' ||
            issue_state == 'Resolved'
    key = issue.attrs['key']
    summary = issue.attrs['fields']['summary']
    type = issue.attrs['fields']['issuetype']['name']
    status = 'Open'
    ticket_owner = ''
    reviewer = ''
    sps = issue.attrs['fields'][STORY_POINT_CUSTOM_FIELD]
  else
    issue_state =  issue['fields']['status']['name']
    next if issue_state == 'Closed' || issue_state == 'Accepted' || issue_state == 'Defer' ||
            issue_state == 'Resolved'
    key = issue['key']
    summary = issue['fields']['summary']
    type = issue['fields']['issuetype']['name']
   status = 'Open'
    ticket_owner = get_member_name(issue['fields']['assignee']['name'])
    reviewer = ''
    sps = issue['fields'][STORY_POINT_CUSTOM_FIELD]
  end

  row = [key, summary, type, status, ticket_owner, reviewer, sps]
  all_rows.push(row)
end

merge_jira_data_with_existing_data(all_rows, sprint_sheet_existing_tickets)

subsheet.update_cells(2, 1, all_rows)
subsheet.save
