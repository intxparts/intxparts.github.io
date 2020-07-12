# C++ Cross Platform Casting

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


