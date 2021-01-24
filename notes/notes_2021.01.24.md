# Env Variables

*2021.01.24*


### Windows

```
    set LUA_PATH=./src/?.lua
    set | findstr "LUA_PATH"
```

Unfortunately the above does not work in Powershell.
For Powershell another method is required.

```
    $env:LUA_PATH='./src/?.lua'
    dir env: | findstr "LUA_PATH"
```

### Linux

```
    export LUA_PATH=./src/?.lua
    printenv | grep "LUA_PATH"
```

