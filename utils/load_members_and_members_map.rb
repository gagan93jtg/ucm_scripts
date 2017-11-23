require 'json'
require 'base64'

module JiraAuth
  begin
    if File.exists?('../configuration/global_config.rb')
      require_relative('../configuration/global_config.rb')
      MEMBERS_JSON_PATH = GlobalConfig::MEMBERS_JSON_PATH
      MEMBERS_MAPPING_JSON_PATH = GlobalConfig::MEMBERS_MAPPING_JSON_PATH
    else
      MEMBERS_JSON_PATH = ENV['HOME'] + '/members.json'
      MEMBERS_MAPPING_JSON_PATH = ENV['HOME'] + '/members_mapping.json'
    end

    MEMBERS = JSON.parse(File.read(MEMBERS_JSON_PATH))
    MEMBERS_MAP = JSON.parse(File.read(MEMBERS_MAPPING_JSON_PATH))
    puts "[Load Members] Loaded members and members map data"
  rescue Errno::ENOENT
    abort "[Load Members] Error loading file. Probably #{MEMBERS_JSON_PATH} or #{MEMBERS_MAPPING_JSON_PATH}" +
          " is not present on your system"
  rescue StandardError => e
    abort "[Load Members] Some error loading file/data [#{e.message}]"
  end
end
