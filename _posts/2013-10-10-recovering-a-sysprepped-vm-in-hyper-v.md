---
title: Recovering a Sysprepped VM in Hyper-V
tags: [azure, hyper-v]
---

I was working with a SharePoint 2010 VM and decided it would be a grand idea to sysprep the VM and then upload the VHD to Azure.  That ended up not working out for me and when I tried to use the same VHD within Client Hyper-V (Windows 8.1)​.

I immediately got the reprehensible "Windows could not complete the installation. To install Windows on this compuiter, restart the installation." error message.  To fix it, I simply had to press SHIFT+F10 and then run the Microsoft Out-of-box-experience feature manually.  Not sure why that didn't "just work" but I'm sure a really sharp IT pro will explain it to me someday.

BTW, here's the Microsoft Community answer that led me in the right direction:

<http://answers.microsoft.com/en-us/windows/forum/windows_7-windows_install/windows-could-not-complete-the-installation-to/bf09c3c5-298b-459f-aed5-4f431b8398f5>

Thanks [MarkBeacom](http://answers.microsoft.com/en-us/profile/480f1a5d-8acb-44ea-9ce4-d94168323ec8)!