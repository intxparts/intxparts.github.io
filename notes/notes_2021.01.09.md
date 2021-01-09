# .Net App loading dependencies from another directory

*2021.01.09*

One question is why would we want to do this? The particular case I experienced this was at work where we have a .Net WPF application for the frontend but a good number of "platform" dll's written in C++ that provide much of our applications high-performance graphics, algorithms, I/O, document management, etc. Most of these dll's are referred to as platform dlls and are distributed with our application in a subdirectory called platform.

To give an idea of the directory structure:

```
    WPFApplication.exe
    CSharpAppLib1.dll
    CSharpAppLib2.dll
    ...
    platform\
    platform\CppAlgorithms.dll
    platform\CppDocumentData.dll
```

This was done I believe to clearly separate between the primary application and the platform. While I do not think this is necessary, this has been in place for a while and it would take a considerable amount of work to change. 

Back to the problem at hand. The problem of loading a dependency from a different directory came about as we introduced a new dll into the mix that is written in the C++/CLI bridge layer between the managed and unmanaged world. The project type was not the issue however. The issue was that the main application will depend directly on this C++/CLI dll, but the C++/CLI dependency depends directly on one of the platform C++ dlls in the platform directoy. It was easier to load the C++/CLI dll from the platform folder rather than distributing the C++/CLI dll in the same directory as the application and loading its C++ dependencies from the platform folder. Hence we have reached the topic of discussion.

### App.Config [probing](https://docs.microsoft.com/en-us/previous-versions/dotnet/netframework-2.0/823z9h8w(v=vs.80)) element

One way to do manage this is to add a **probing** path element to the application config like so:

```
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  ...
  <runtime>
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <probing privatePath="platform"/>
    </assemblyBinding>
  </runtime>
</configuration>
```

This is the same as modifying an [AppDomainSetup.PrivateBinPath](https://docs.microsoft.com/en-us/dotnet/api/system.appdomainsetup.privatebinpath?view=netframework-4.8), which allows you to specify additional search directories to the assembly resolve path for the application. By default .Net primarily looks in the same directory as the running application.

A working example of this solution is available [here](https://github.com/intxparts/MicroProblem_ResolvingAssemblies).

### [AppDomain.AssemblyResolve](https://docs.microsoft.com/en-us/dotnet/api/system.appdomain.assemblyresolve?view=netframework-4.8) Event

Another way to manage this is to hook into the current AppDomain as the application is resolving its dependencies and specify the directories to look up.

Below is an example of using the current AppDomain's AssemblyResolve event to load the dll appropriately. It can be easily pasted into the example project linked in the probing section above.

```csharp
    public partial class App : Application
    {
        private Stopwatch s = new Stopwatch();

        public App()
        {
            s.Start();
            AppDomain.CurrentDomain.AssemblyResolve += CurrentDomain_AssemblyResolve;
        }

        protected override void OnStartup(StartupEventArgs e)
        {
            int i = API.Sum(2, 3);
            s.Stop();
            long result = s.ElapsedMilliseconds;
            File.AppendAllText("results.txt", $"elapsed time: {(result / 1000.0)} (s) = {result} (ms)");

            base.OnStartup(e);
        }

        private Assembly CurrentDomain_AssemblyResolve(object sender, ResolveEventArgs args)
        {
            Assembly result = null;
            if (args != null && !string.IsNullOrEmpty(args.Name))
            {
                if (!args.Name.Contains("Dependency"))
                    return args.RequestingAssembly;

                var baseDir = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location);
                var platformDir = Path.Combine(baseDir, "platform");

                var assemblyName = args.Name.Split(new string[] { "," }, StringSplitOptions.None)[0];
                var assemblyPath = Path.Combine(platformDir, $"{assemblyName}.dll");
                if (File.Exists(assemblyPath))
                {
                    result = Assembly.LoadFrom(assemblyPath);
                }
                else
                {
                    return args.RequestingAssembly;
                }
            }

            return result;
        }
    }
```

### Evaluating the two solutions

In the case I stumbled across this problem, the probing solution is better for a number of reasons.

- simpler with less code, which is always a good thing :)
- faster - in the simple example of a WPF application loading a single dependency from another folder:
    - config solution app startup: 0.005s (5 ms)
    - AppDomain hook app startup:  0.010s (10ms) 
    - While this is fairly negligible in a small example, in a larger codebase the savings could be more significant
- Windows security
    - This one was interesting to stumble across. Suppose you distribute your application in a zip file form. When downloading a zip file from the internet, Windows will automatically 'block' it. This can be seen by right-clicking and going to properties on the zip file after it has downloaded. Assuming you have not explicitly unblocked the zip file beforehand, upon extracting the zip file through the Windows built-in 'extract files' functionality, every file in the resulting unzipped directory will still be 'blocked'. If you then tried to run an executable from that directory, the Windows smart screen would pop-up and ask you: 'are you sure you want to run this program, it was downloaded from the internet?' While this is not a big deal, as the user can still click 'run', if your application happened to be loading an assembly from a different directory by hooking into the AppDomain's AssemblyResolve event handler, then the program will likely not run if that dependency was needed. This is because the dll that was trying to be loaded by the application also has been blocked. By using the probing solution all of the assemblies discovered associated with the main application will not prevent the application from starting up if they are 'blocked' by Windows. Attempting to resolve and load them at runtime of the program itself however will prevent the application from starting up if they are 'blocked'.


### Useful links

- Demo / Working [example](https://github.com/intxparts/MicroProblem_ResolvingAssemblies)
- [How the .Net Runtime Locates Assemblies](https://docs.microsoft.com/en-us/dotnet/framework/deployment/how-the-runtime-locates-assemblies)


