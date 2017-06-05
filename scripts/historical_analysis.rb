require 'retrospectives'

require 'json'

include Retrospectives

HISTORIC_SHEET_KEY = '14zWEIt4ATkgzWXBeZyWpw_FsABu06h37hbTWr6FgCsE'

retro = RetroSetup.new
task_type = Hash.new(0)
task_category = Hash.new(0)
incidents = Array.new

google_client = retro.authenticate_google_drive('/home/cuegg/copperegg docs/config.json')
all_subsheets = google_client.spreadsheet_by_key(HISTORIC_SHEET_KEY).worksheets

all_subsheets.each do |sheet|
  first_cell = sheet[1, 1]
  next("Skipping #{sheet.title}") unless first_cell == 'Key'

  (2..100).each do |row| # probably not more than 100 tickets in any sprint
    ticket = sheet[row, 1]
    type = sheet[row, 3]
    category = sheet[row, 4]

    next if ticket.nil? || ticket.empty?

    task_type[ticket] = type
    task_category[ticket] = category

  end
end

p "----------------------------------------------------------------------------"

task_category.values.uniq.each do |type|
  p "Unique #{type} task count #{task_category.values.count(type)}"
end

p "----------------------------------------------------------------------------"

task_type.values.uniq.each do |type|
  p "Unique #{type.pluralize} count #{task_type.values.count(type)}"
end

p "----------------------------------------------------------------------------"

task_type.each do |k, v|
  incidents.push(k) if v == 'Incident'
end

p "Unique incidents : #{incidents}"
