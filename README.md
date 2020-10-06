# cli reminder - by arcc

## creating a systemd timer (user)
In order to recieve notifications you have to create a service / cronjob that executes reminders run method at least every minute.

User services are located in the  `~/.config/systemd/user/` directory.

Create a file in this directory called `reminder.service` with the following content and replace `[USERNAME]` with your username.

```bash
[Unit]
Description=reminder

[Service]
Type=oneshot
ExecStart=/usr/local/sbin/reminder run
WorkingDirectory=/home/[USERNAME]
```
After that a timer is needed. Simply create the file `reminder.timer` in the same directory with the following content.

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
Comming soon, PR welcome.