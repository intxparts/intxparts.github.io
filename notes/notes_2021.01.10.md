# Add reference to dll in .Net Core project

*2021.01.10*


As of .Net Core 3.1 there is no option through the **dotnet** CLI to add a reference directly to a dll. Only projects and nuget packages have support currently.

To add a direct reference to a dll, edit the csproj file directly adding:

```
  <ItemGroup>
    <Reference Include="dllname">
      <HintPath>path\to\my\dllname.dll</HintPath>
    </Reference>
  </ItemGroup>
```


