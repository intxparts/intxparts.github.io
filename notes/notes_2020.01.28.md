# Github Actions

*2020.01.28*

Recently noticed Github added Actions for CI/CD tied directly to repositories. Setup my [LuaModules](https://github.com/intxparts/LuaModules) repository to run tests when pushing a branch. Thankfully Leafo, an active member of the Lua community and creator of Lapis, had already created a [custom Github Action](https://github.com/leafo/gh-actions-lua) to download and build Lua/Luajit with the desired versions. So the only work on my part was tying in my own Lua test framework into the system.

To run the full set of tests for the repo, it is a simple command line call to Lua.

```
	[> lua test_runner.lua -d ../tests
```

Due to the way I have structured the repo, this command assumes you are working in the 'src' folder. This became an issue when tying in the CI. It was a simple fix to modify the LUA_PATH environment variable so that the Lua modules could be found when not in the same directory.

```
	[> export LUA_PATH=./src/?.lua
	[> printenv
	[> ...
	[> LUA_PATH=./src/?.lua
	[> ...
```

Thankfully Github provides the ability to set environment variables in the container configuration section of the \*.yml file. 

```yml
	name: Build

	on: [push]

	jobs:
	  test:
		runs-on: ubuntu-latest
		env:
		  LUA_PATH: ./src/?.lua
	...
```

One last problem to solve was ensuring that the test action would fail when a test failed. This was also a simple fix, in 'test_runner.lua':

```Lua
	if has_errors then
		os.exit(false)
	end
```

By setting the exit code to non-zero, the CI picks this up and fails appropriately. At first I had tried to write to stderr, but the CI does not observe output to stderr as a failure.

Hence we land on the final CI config:

```yml
	name: Build

	on: [push]

	jobs:
	  test:
		runs-on: ubuntu-latest
		env:
		  LUA_PATH: ./src/?.lua

		steps:
		- uses: actions/checkout@v1
		- uses: leafo/gh-actions-lua@v5
		  with:
			luaVersion: "5.3"
		- name: Run tests
		  run: lua ./src/test_runner.lua -d ./tests -et efail
```

Note: the -et efail in the 'Run tests' action means 'exclude tests' marked with tags 'efail' (expected fail).


While I do appreciate and like how easy it was to use Leafos custom action for downloading and building Lua/Luajit, it is a bit slow. There are some alternatives that would make it much faster:

- add Lua binaries directly to the repo
- create a git submodule and link to a repo containing the Lua binaries

Unfortunately Github Actions does not ship with an 'intialize git submodules' action at the time of writing this, but the community has several solutions for this. If possible I would like to avoid using external Github Actions if I can, just for simplicity and also for the control over the CI process. It is harder to optimize when you do not have control over parts of your system.

One thing that I was really happy to see is that you can run CI for any OS, it just comes at a cost. Free accounts get 2,000 minutes of Github Actions running per month free. There is a multiplier if you want to use something other than Linux.

Minute Multiplier
- Linux: 1
- Windows: 2
- MacOS: 10

Cool software, I really enjoyed setting this up. It took me sometime to figure out this much (an hour or so), but that was mostly digging through Githubs documentation.

