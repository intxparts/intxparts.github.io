# VPN Issues

*2021.01.05*


Been having issues with the VPN at work for a while. A lot of the issues are on the ISP side, but most of them have been resolved now.
This morning there were a number of failures while on the VPN:

- MS Outlook failed to connect to the exchange server
- MS Teams failed to connect to anything/login
- Nuget was unable to resolve the public repository www.nuget.org/api/v2/
- Unable to ping google.com

The first two are not surprising since those products tend to be fragile. The last two were alarming and are what pushed me into looking up DNS. Sure enough ipconfig had just what I needed:

```
ipconfig /flushdns
```

After running that command and restarting the machine everything started working again. 

