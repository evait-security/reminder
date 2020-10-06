require "option_parser"
require "db"
require "sqlite3"

action = ""
message = ""
db_path = "#{Path.home}/.reminder/db.sqlite3"

OptionParser.parse do |parser|
  parser.banner = "cli reminder"

  parser.on "add", "Adds a new reminder" do
    parser.banner = "Example usage: reminder add -m \"tee time in 1h\""
    action = "add"
    parser.on("-m", "--message=MESSAGE", "Set the message text for the reminder including the first time span matched followed by a whitespace or end of string (e.g. 1h or 2d)") { |m| message = m }
  end
  parser.on("show", "Show all upcoming reminders") { action = "show" }
  parser.on("run", "Checks reminder status and execute") { action = "run"}
  parser.on "-h", "--help", "Show help - get more help for a specific action e.g. -a add" do
    puts parser
    exit
  end
end

if action.empty?
  puts "[-] no action defined, check out -h, --help to get all options"
  exit
end

def check_db(db_path)
  unless File.exists?(db_path)
    puts "[-] DB does not exist"
    init_db(db_path)
  end
end

def init_db(db_path)
  puts "[*] initializing database"
  unless Dir.exists?(File.dirname(db_path))
    puts "[*] create parent directory"
    begin
      Dir.mkdir(File.dirname(db_path))
    rescue e
      puts "[-] #{e}"
      exit
    end
  end
  begin
    puts "[*] create sqlite database"
    DB.open "sqlite3://#{db_path}" do |db|
      db.exec "create table reminders (message text, time string)"
    end
  rescue e
    puts "[-] Error while creating the database: #{e}"
    exit
  end
end

def show(db_path)
  DB.open "sqlite3://#{db_path}" do |db|
    db.query "select message,time from reminders" do |rs|
      puts "#{rs.column_name(0)} | #{rs.column_name(1)}"
      puts "---------------------------------------"
      rs.each do
        puts "#{rs.read(String)} | #{rs.read(String)}"
        end
    end
  end
end

def add(db_path, message)
  reminder_time = Time.local
  match = /([0-9]+)([smhdMY]+\b)/.match(message)
  unless match.nil?
    modifier_number = match.not_nil![1].strip.to_i
    modifier_char = match.not_nil![2].strip
    modifier_string = match.not_nil![0]

    # remove the regex match from the original message
    reminder_message = message.gsub(modifier_string, "").strip

    case modifier_char
    when "s"
      reminder_time = reminder_time + modifier_number.seconds
    when "m"
      reminder_time = reminder_time + modifier_number.minutes
    when "h"
      reminder_time = reminder_time + modifier_number.hours
    when "d"
      reminder_time = reminder_time + modifier_number.days
    when "M"
      reminder_time = reminder_time + modifier_number.months
    when "Y"
      reminder_time = reminder_time + modifier_number.years
    else
      puts "[-] to timespan detected. Exiting ..."
      exit
    end
  else
    puts "[-] to timespan detected. Exiting ..."
    exit
  end
  DB.open "sqlite3://#{db_path}" do |db|
    args = [] of DB::Any
    args << reminder_message
    args << reminder_time.to_s
    begin
      db.exec "insert into reminders values (?, ?)", args: args
      puts "[+] Reminder added"
    rescue e
      puts "[-] Error while adding the reminder: #{e}"
    end
  end
end

def run(db_path)
  reminder_to_delete = [] of Int64

  DB.open "sqlite3://#{db_path}" do |db|
    db.query "select rowid,message,time from reminders" do |rs|
      rs.each do
        reminder_id = rs.read(Int)
        reminder_message = rs.read(String)
        reminder_time = Time.parse!(rs.read(String), "%Y-%m-%d %H:%M:%S %z")
        time_span = reminder_time - Time.local
        if time_span.to_i < 0
          Process.new("notify-send", ["-i", "alarm", reminder_message])
          reminder_to_delete << reminder_id
        end
      end
    end
    reminder_to_delete.each do |reminder_id|
      db.exec "delete from reminders where rowid = #{reminder_id}"
    end
  end
end

check_db(db_path)

case action
when "show"
  show(db_path)
when "add"
  add(db_path, message)
when "run"
  run(db_path)
else
  puts "[-] nothing to do..."
  exit
end
