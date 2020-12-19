# intxparts.github.io

Personal programming projects website hosted on github.

## Building

### Dependencies

- requires Lua 5.3.x or higher to be in the path
- requires Pandoc to be in the path
- requires the latest from the [LuaModules](https://github.com/intxparts/LuaModules) repository
- requires LuaModules repository to be accessible from LUA_PATH

*build.lua* provides several commands: "new dev note", "new math note" and "build".


### New Dev Note

This will create a new dev note markdown file under the notes directory with filename: 'notes_YYYY.MM.DD.md'.


```bat

lua build.lua -nd "New Note"

```

### New Math Note

This will create a new dev note markdown file under the notes directory with filename: 'mathNotes_YYYY.MM.DD.md'.


```bat

lua build.lua -nm "New Note"

```

### Build

This will perform a full rebuild of the site - generating all the appropriate html files from the markdown files.

```bat

lua build.lua -b

```

