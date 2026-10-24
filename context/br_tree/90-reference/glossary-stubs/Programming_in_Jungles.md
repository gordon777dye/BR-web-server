---
title: Programming_in_Jungles
file: Programming_in_Jungles.md
category: 90-reference
subcategory: 90-reference/glossary-stubs
kind: concept
related: [Business Rules!, how to, Export, Top level categories, any category, any single pages, Templates, batch, AutoRun.inf, Templates category]
provenance: recovered-2b (redirect-collision casualty re-fetched from wiki)
---
Sometimes we're blazing a trail through unexplored territories we may write some `Business Rules!` programs along the way. Well out there in the jungle there is no internet. So if we want something from the web, we'd better pack it to go first.  The easiest way to take this wiki with you is to make your own wiki on a stick (a.k.a. Thumb drive or USB drive) and export data from this wiki to it.  It's much simpler it sounds, thanks to some innovative work from CHSoftware.

==DIY==
Want to create a personal web host on a stick?  Here's `how to` do it:

#Install a Wiki on a Stick to your thumb drive.
:*The required packages (for our ends) are:
::#MediaWiki
::#PHP5
::#Apache Server
::#MySQL
:*Test and verify that you can access your *wiki on a stick*
#`Export` the desired `Top level categories` or `any category` or `any single pages` that you want from this wiki.  `Templates` are critical.
:*(Improvement in this step is planned, special categories will be made for the convenience of exporting)
:*Export sizes are limited, so you can't export EVERYTHING at once, but you can get quite a lot.
#Login to your new wiki with the user name *Admin* and the password *password*.
#Go to **special pages** and then **Import** (generally towards the end of the page).
#Choose the file that you previously exported (in step 2)

That's it.  Now when you are ready to launch your portable wiki on a stick, all you have to do is double click on **mowes.exe** in the root of your USB drive.

===Run from a Batch File===
If you'd like create an appropriately-named `batch` file to launch **mowes.exe** instead:

BRWiki.cmd (for example) might contain:
  mowes.exe

===AutoRun===
You may like your wiki to automatically pop up when you insert your thumb drive into a computer.  To do that you'll need to make an `AutoRun.inf` file and place it in the root directory of your thumb drive.  The AutoRun.inf file is just a regular text file and should contain the following:

 [AutoRun.inf]
  Open=mowes.exe

It may contain more, but that's the bare minimum.

===Location===
Perhaps you don't want your wiki on a stick to be stored in the root of your flash drive. Or maybe you don't want it on a flash drive at all. Have it your way! You can put your wiki anywhere you want- even at the end of a ridiculously long path in My Documents on your hard drive. Or perhaps you want it on your flash drive, but in a folder of it's own, separate from all of your other files and folders. It will be fine there too. Just make sure to alter any Autorun or Batch files that call the wiki. That's all you have to do!

==FAQ==
**Q.** What should I export from the BR Wiki?

**A.**
Always get:
*the `Templates category`
Additionally:
*`Error Codes`
*`GUI`
*`BR Manual`
*`Special:Allpages` contains a list of all the pages, go there and copy anything you want right into `Special:Export`

**Note:** You can't take everything in one export because it will exceed the maximum import size on your local wiki.



**Q.** Can I edit my wiki on a stick?

**A.** Yes, you can, but be aware that all changes you make to your wiki on a stick will be lost forever just as soon as you import additional data from the BR Wiki.  When programming in a jungle, you should log the desired changes, and when you are back to civilization (internet accessible) make those changes to the BR Wiki.



**Q.** Page not found

**A.** If you get a Page not found error in your browser than it's probably because the IP address hasn't populated and cached everywhere yet... Simply, wait a few seconds and press F5/Refresh.
