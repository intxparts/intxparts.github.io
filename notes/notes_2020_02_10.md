# Github Actions \[speed up\]

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


