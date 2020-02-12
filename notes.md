# Notes

---

### Github Actions \[Windows speed up\]

*2020.02.11*

Yesterday after I finished writing up the notes on the speed up for the [LuaModules](https://github.com/intxparts/LuaModules) CI process, my curiosity was piqued. It is time to try and override the default Windows shell (Powershell) in Github actions. To be frank, I do not like Powershell. It is slow, too verbose, command creation is irritating, and the syntax is only slightly better than writing \*.bat files. I am confident switching the default shell over to cmd.exe will speed up the build time immensely. 11 seconds to start a shell is absolutely ridiculous. Having worked at companies specializing in 3D geometry software, even some of those applications start up faster and they are dealing with a lot more than text.

Looking through the [documentation](https://help.github.com/en/actions/reference/workflow-syntax-for-github-actions#about-yaml-syntax-for-workflows), there is a way to override the default shell. Since we were able to define a variable for our OS strategy matrix for the Lua binary file path, I tried the same thing with the shell for the respective OS.

```yml
    ...
        include:
        - os: ubuntu-latest
          LUA_BIN_PATH: ./bin/Linux/lua-5.3.5/
          SHELL: bash
        - os: windows-latest
          LUA_BIN_PATH: .\bin\Windows\lua-5.3.4\
          SHELL: cmd
    env:
      LUA_PATH: ./src/?.lua

    steps:
    - uses: actions/checkout@v1
    - name: Run tests
      run: ${{matrix.LUA_BIN_PATH}}lua ./src/utest_runner.lua -d ./tests -et efail
      shell: ${{matrix.SHELL}}
```

Unfortunately this does not work. Ended up receiving the following:

		Your workflow file was invalid: The pipeline is not valid. 
		.github/workflows/Build.yml (Line: 25, Col: 14): Unrecognized named-value: 'matrix'. 
		Located at position 1 within expression: matrix.SHELL

Copying and pasting this into duckduckgo and sure enough someone else [confirms](https://github.community/t5/GitHub-Actions/Using-matrix-to-specify-shell-is-it-possible/td-p/39869) that: *the matrix job does not support the ability to set the shell as a configuration option for a Github virtual environment.*

The next thing I decided to try was to just set **shell:** to 'cmd' always to see if Github would notice that this shell is not available in the Linux environment and use the default 'bash' instead. Unfortunately it does not. The Linux build failed and the Windows build passed.

During my duckduckgo searching before, I happened to stumble across someone else using an **if:** statement... perhaps we can do something with that?

I tried several versions of the **if:** statement until I found one that worked. 

```yml
name: Build

on: [push]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
    env:
      LUA_PATH: ./src/?.lua

    steps:
    - uses: actions/checkout@v1
    - name: Run tests on Linux
      if: matrix.os == 'ubuntu-latest'
      run: ./bin/Linux/lua-5.3.5/lua ./src/utest_runner.lua -d ./tests -et efail
      shell: bash
    - name: Run tests on Windows
      if: matrix.os == 'windows-latest'
      run: .\bin\Windows\lua-5.3.4\lua.exe ./src/utest_runner.lua -d ./tests -et efail
      shell: cmd
```

I tried using the **if:** statement within the single step 'run tests', as there is no need to have two steps, but that did not work. I did not try with an **if:** and **else:** as there was no indication of an **else:** in the documentation, so there may be room to clean this up in the future. 

It is a bit irritating that users are unable to utilize the strategy matrix variables for **shell:**, but in the end I got the speed up I was looking for. Now the Windows build only takes 1 second to start a cmd.exe shell and run all of the tests; down from 11 seconds with Powershell. Powershell is neat in what it can do (like running C# .Net code), but cmd.exe is the tool you want to use if you care about performance.


---


### Github Actions \[speed up\]

*2020.02.10*

Last weekend I got the urge to optimize the build for the [LuaModules](https://github.com/intxparts/LuaModules) repo. The idea was to remove the dependency on the Github action 'download and build Lua' as this took a lot of time (~50 seconds). I ended up building the desired Lua version on each supported platform and added the binaries directly in the repo. 

Getting the binary solution working took a bit more effort than expected. The build immediately failed after switching due to a missing dependency. The version of Lua I had compiled on Linux was 5.3.4, but when I had compiled it, it was dependent on libreadline6. This dependency no longer exists on the Github containers. I'm not sure why it was removed, but it was a simple fix to recompile with libreadline7. 

Once that issue was resolved, everything worked smoothly. Since Lua's binaries are so small, the step 'checkout repo' only took a few milliseconds longer. By removing the 'download and build Lua' Github action, that eliminated ~50s from the build time. Now it only takes 3 seconds to run the entire build. The original build was taking ~53 seconds. 

With the build times now much more reasonable I decided to add Windows as an additional OS to run the build on. Setting this up was simple enough, by creating a *strategy* matrix. Since we're using the Lua binaries in the repo, we have two separate paths for each OS. This is something to account for in the \*.yml file. 


```yml
name: Build

on: [push]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, windows-latest]
        include:
        - os: ubuntu-latest
          LUA_BIN_PATH: ./bin/Linux/lua-5.3.5/
        - os: windows-latest
          LUA_BIN_PATH: .\bin\Windows\lua-5.3.4\
    env:
      LUA_PATH: ./src/?.lua

    steps:
    - uses: actions/checkout@v1
    - name: Run tests
      run: ${{matrix.LUA_BIN_PATH}}lua ./src/utest_runner.lua -d ./tests -et efail
```

Naturally the Windows build takes a bit more time to run than Linux with checking out taking 5 seconds instead of 1. One thing that was unusual is the 'run tests' step takes 11 seconds. This is something worth investigating in the future. According to the Lua timer it shows that it only takes 0.002 seconds to run all the tests. The Windows shell being used is powershell, which could explain why it takes 11 seconds. One thing to investigate is whether you can override the default shell to use cmd.exe instead.


---


### Github Actions

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


---


### C++ Cross Platform Casting

*2019.06.04*

Stumbled across this at work when the Linux build failed to compile:

```C++

    unsigned char c = '0';

    if (c == unsigned char(1))
    {
		
    }
```

Compilation results:

- GCC: fail
- Clang: fail
- MSVC: success

I think it is a bit odd that MSVC permits this, but I could just be used to the style of putting the type you are casting to in parentheses.


---


### Building srlua on Windows

*2017.09.19*

[srlua](https://github.com/LuaDist/srlua) is a useful tool for turning lua scripts into standalone executables. Like most Lua projects srlua is more Linux focused in terms of its standard build environment. As a result Cygwin is the usual recommendation for building on Windows. I've had a variety of issues using Cygwin to build cross platform applications in the past, particularly command line applications, so I wanted to make a build script to build natively on Windows. 

My current machine contains a typical Visual Studio 2015 community edition installation with the standard C++ libraries installed. Before starting, ensure you have also downloaded the matching version of Lua's source code and have built the luax.x.lib. If you're not sure how to do this I have created a gist [here](https://gist.github.com/intxparts/847cdd4de54d0ea52bd9d272dead915e) which was adapted from another person's [build script](https://pastebin.com/HjVjFNwK) for Lua on Windows.

To build srlua:

- download the latest [source code](https://github.com/LuaDist/srlua/releases)
- open up the "Developer Command Prompt for 2015" 
- edit the script below inserting your respective paths to the Lua source/libs and the Windows libs
- run the script

        -- Build.bat -- 

        cl /MD /O2 /c /I <path_to_lua_root>\src *.c
        link /OUT:glue.exe glue.obj <path_to_lua_libs>\lua5.3.lib
        link /OUT:srlua.exe srlua.obj "<path_to_lua_libs>\lua5.3.lib" "<path_to_windows_kit_libs>\user32.lib"

**path_to_windows_kit_libs** was the following for my machine, running Windows 10, so you should likely have something similar.

        C:\Program Files (x86)\Windows Kits\8.1\Lib\winv6.3\um\x86\

Recommend doing a quick test such as a hello world script to help you determine if your environment is ready to go or not:

```lua

-- hello_world.lua

print('hello world!')

```

        [> glue.exe srlua.exe hello_world.lua hello_world.exe



---


### Useful learning Vim links

*2017.08.23*

- [Video: How to do 90% of what plugins do (with just Vim)](https://youtu.be/XA2WjJbmmoM)
- [Game: Vim Adventures](https://vim-adventures.com)


---


### Useful WiX Toolset Links

*2017.08.19*

The [WiX Toolset](https://github.com/wixtoolset) is an open source set of tools to help in the creation of Windows Installers.

- [How to get all logs associated with WiX](https://stackoverflow.com/questions/10741139/how-to-set-or-get-all-logs-in-a-custom-bootstrapper-application)
- [How to handle cancel and rollback in a custom Bootstrapper Application](https://stackoverflow.com/questions/15323427/cancel-installation-and-rollback-using-wix-burn-bootstrapper-ui)
- [When signing your WiX bootstrapper, remember to sign the WiX Engine as well](http://www.daves-blog.net/post/2014/08/29/Signing-WIX-Bottstrapper.aspx)
- [Installer variable properties used in determining what install action is being performed](https://stackoverflow.com/questions/320921/how-to-add-a-wix-custom-action-that-happens-only-on-uninstall-via-msi)
- [Useful code for setting properties that define what install action is being performed](https://stackoverflow.com/questions/18531272/how-do-i-distinguish-between-a-normal-install-and-an-upgrade-in-wix)
- [UPGRADINGPRODUCTCODE is set only for the hidden uninstallation of a package](https://stackoverflow.com/questions/11861573/upgradingproductcode-condition-not-working-in-wixui-install-wxs-in-library)
 

