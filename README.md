# cli reminder

This small software uses the `notify-send` command in combination with a small sqlite database and systemd-timers in order to create text based reminders.

## Example usage

```bash
reminder add -m "go to bed 1h" # reminds you in one hour with the message "go to bed"
reminder add -m "10m call bob back" # reminds you in 10 minutes to re-call bob
reminder show # show all upcoming reminders
reminder run # execute all overdue reminders (should be used with systemd-timers or cron)
```
## bash / zsh alias

You can create a small alias for your favorite shell. Edit your `.bashrc` or `.zshrc` and add the following function:

```
rme () {
  reminder add -m "$*"
}
```

Now reminders can be added with a minimum of parameter usage, e.g.:

```bash
rme 10m make a break # reminds you in 10 minutes to take a break
```

## creating a systemd timer (user)

In order to receive notifications you have to create a service / cronjob that executes reminders `run` method at least once every minute.

User services are located in the  `~/.config/systemd/user/` directory.

Create a file in this directory called `reminder.service` with the following content and replace `[USERNAME]` with your username:

```bash
[Unit]
Description=reminder

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/reminder run
WorkingDirectory=/home/[USERNAME]
```

After that a timer is needed. Simply create the file `reminder.timer` in the same directory with the following content:

```
[Unit]
Description=reminder

[Timer]
OnCalendar=*:0/1
Persistent=true

[Install]
WantedBy=timers.target
```

In order to enable the timer simply run the following command:

```bash
systemctl --user enable reminder.timer && systemctl --user start reminder.timer
```

## creating a crontab (user)

Coming soon, PR welcome.

## building from source

Clone the repository and run:

```bash
shards install
shards build --production --release --no-debug
```

The executable will then be located in `./bin/reminder`
