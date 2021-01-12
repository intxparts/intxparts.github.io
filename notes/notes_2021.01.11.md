# Failed to restore; Cycle detected

*2021.01.11*

With .Net Core's unit tests, you may come across a cyclic reference if you name the project the same name as the testing framework. A simple rename of the project will fix the issue.

```
Running 'dotnet restore' on NUnit\NUnit.csproj...
  Determining projects to restore...
C:\_Dev\DotNet\NUnit\NUnit.csproj : error NU1108: Cycle detected.
C:\_Dev\DotNet\NUnit\NUnit.csproj : error NU1108:   NUnit -> nunit (>= 3.12.0).
  Failed to restore C:\_Dev\DotNet\NUnit\NUnit.csproj (in 423 ms).

Restore failed.
Post action failed.
```


