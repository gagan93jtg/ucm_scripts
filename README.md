# ucm_scripts
Cool scripts to automate work and save time ;)

# Requirements
ruby - 2.3.0

# Usage

1. To use script(s) which use google sheets, you must setup google drive authentication and place a file called `google\_auth.json` to home directory of user who is executing any of these scripts. Here refresh token and scope are optional and are regenerated when you use these credentials.
2. To use script(s) which require JIRA authentication, you must create a file with JIRA credentials / site information and place a file called `jira\_auth.json` in home directory of user who is executing any of these scripts. To get encrypted password, either manually encode your password into base64 string or use utils/enc_dec.rb as follows
```
ruby utils/end_dec.rb encrypt my_jira_password
```
3. You also need to define two files (used by most but not all the scripts), i.e. `members.json` and `members_mapping.json`. First JSON file is an array of members and has basic information about all the members (eg. Name, JIRA Username, bandwidth, days_worked in sprint, timesheet key and sheet index of current timesheet). Second JSON file is a simple Name and JIRA username map structure. Because this piece of information is confidential and not of any use unless you have access to google account, I am adding the original files in `examples\_json` directory
4. All the example json file strcutres are present in `example_json` subdirectory.
5. All the scripts are present in `scripts` subdirectory and name of each script specifies it's purpose. Some of the scripts are legacy ones because we no more log hours on JIRA so `add_worklog.rb` and `sprint_analysis.rb` are of no use right now but I've still kept them for future use (if we again start logging hours).
