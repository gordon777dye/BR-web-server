---
title: Couldn't_'lock_in_progress'
file: Couldn't_'lock_in_progress'.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [WBServer.dat, BR!, in progress]
---
'''Couldn't lock in progress'''

This is a problem accessing the `WBServer.dat`.  This lock is retried several times as other locks are.  It is possible that there are a lot of people starting `BR!` at the same time or that something is running slowly and holding its lock longer that normal.

To recover from this error you can delete the WBServer.dat file and let BR.exe rebuild it.

==See Also==
*`in progress`
