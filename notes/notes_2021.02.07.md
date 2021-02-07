# Github CI slowdown on ubuntu-latest

*2021.02.07*

While making some changes to one of my repos today I noticed the CI for the Linux build was a lot slower than it should be, and I have not changed the CI workflow for some time. The Windows build was actually beating it!! 

- ubuntu-latest: 30s
- Windows: 6s

Something was not right. 

The only thing that runs on each platform is the Lua binary running the test scripts.
Looking at the results from the test runs, the tests are still reporting the same numbers for both platforms:

- ubuntu-latest: 0.09s
- Windows: 0.5s

Looking at the history of the builds, the last build I ran a month ago reported the expected overall numbers for each platform:

- ubuntu-latest: 2s
- Windows: 7s

I noticed while navigating through the Actions screen that there was a warning about an upcoming transition from 18.04 -> 20.04 for the ubuntu-latest builds.

![](images\GithubCISlowdownUbuntuLatest\sus.png)

Sure enough, the newer version of ubuntu appears to be slowing things down significantly. Targeting the build explicitly for ubuntu-18.04 gets the build times back to expected levels.

For now I have left my build targetting 18.04 in hopes that the latest ubuntu will be fixed once Github completes the transition. If not, we will have more digging to do ;).

