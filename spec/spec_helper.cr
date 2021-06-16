require "file_utils"

CRYSTAL = "crystal"

def capture(cmd, params)
    process = Process.new(cmd, params,
        output: Process::Redirect::Pipe,
        error: Process::Redirect::Pipe,
        )

    output = process.output.gets_to_end
    error  = process.error.gets_to_end

    res = process.wait

    return output, error, res.exit_status
end

def no_db_fixture(cleanup = true)
    tempdir = File.tempname
    #puts tempdir
    begin
      FileUtils.mkdir_p(tempdir)
      ENV["REMINDER_DB"] = tempdir + "/data.db"
      yield
    ensure
      if cleanup
         FileUtils.rm_rf(tempdir)
      end
    end
end




