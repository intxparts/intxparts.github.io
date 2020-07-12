# Github Actions \[Windows speed up\]

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

