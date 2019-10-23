# Notes

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

- GCC: 0
- Clang: 0
- MSVC: 1


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
 

