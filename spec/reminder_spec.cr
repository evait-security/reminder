require "spec"
require "./spec_helper"

describe "Reminder" do
  it "nothing" do
    no_db_fixture(cleanup: true) do
      stdout, stderr, exit_code = capture(CRYSTAL, ["reminder.cr"])
      stderr.should eq ""
      stdout.should eq "[-] no action defined, check out -h, --help to get all options\n"
      exit_code.should eq 0
      File.exists?(ENV["REMINDER_DB"]).should be_false
    end
  end

  it "list the nothing" do
    no_db_fixture(cleanup: true) do
      stdout, stderr, exit_code = capture(CRYSTAL, ["reminder.cr", "show"])
      stderr.should eq ""
      stdout.should eq "[-] DB does not exist\n[*] initializing database\n[*] create sqlite database\nmessage | time\n---------------------------------------\n"
      exit_code.should eq 0
      File.exists?(ENV["REMINDER_DB"]).should be_true
      # TODO: should the database create when the user sends a "show" command without adding a reminder first?
    end
  end

  it "add entry" do
    no_db_fixture(cleanup: true) do
      stdout, stderr, exit_code = capture(CRYSTAL, ["reminder.cr", "add", "-m", "alarm 1s"])
      stderr.should eq ""
      stdout.should eq "[-] DB does not exist\n[*] initializing database\n[*] create sqlite database\n[+] Reminder added\n"
      exit_code.should eq 0
      File.exists?(ENV["REMINDER_DB"]).should be_true
      # TODO look into the database to check if the data was added as expected?

      stdout, stderr, exit_code = capture(CRYSTAL, ["reminder.cr", "add", "-m", "another one 1s"])
      stderr.should eq ""
      stdout.should eq "[+] Reminder added\n"
      exit_code.should eq 0
      File.exists?(ENV["REMINDER_DB"]).should be_true

      stdout, stderr, exit_code = capture(CRYSTAL, ["reminder.cr", "show"])
      stderr.should eq ""
      stdout.should contain("message | time\n---------------------------------------\n")
      stdout.should match(/alarm \| \d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/)
      stdout.should match(/another one \| \d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d/)
      exit_code.should eq 0
      File.exists?(ENV["REMINDER_DB"]).should be_true
    end
  end

end

