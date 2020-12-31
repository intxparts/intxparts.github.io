# Github SSH session setup

*2020.12.30*

Check to see if the ssh-agent is running. (Needs to be run in git-bash installed with [Git for Windows](https://gitforwindows.org/) on Windows.) In most Linux distributions these commands should already be available.

```
eval $(ssh-agent -s)
```

Adds the ssh private key to the ssh-agent.

```
ssh-add ~/.ssh/id_file
```

After running these two commands, normal commands such as git fetch, git push, git pull should work.

If experiencing issues check the task list to ensure an ssh-agent is not already running.

```
tasklist /NH | findstr /I "ssh-agent"
```

Command line method for killing any ssh-agent process.

```
taskkill /IM ssh-agent.exe /F
```

In case you want to use git-bash with [Windows Terminal](https://github.com/Microsoft/Terminal), here is an example of a profile to add.

```
{
	...
    "profiles":
    {
		... 
	    "list":
        [
			...
			{
				"guid": "{INSERT GUID}",
				"hidden": false,
				"name": "Git-Bash",
				"commandline": "\"%PROGRAMFILES%\\git\\usr\\bin\\bash.exe\" -i -l",
				"icon": "C:\\Program Files\\Git\\mingw64\\share\\git\\git-for-windows.ico",
				"startingDirectory": "C:\\StartingDirectory\\"
			}
        ]
    },
	...
}
```

If setting up ssh for the first time a private key file needs to be generated:

```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

