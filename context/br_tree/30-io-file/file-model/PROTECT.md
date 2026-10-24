---
title: PROTECT
file: PROTECT.md
category: 30-io-file
subcategory: 30-io-file/file-model
kind: statement
related: [command, 4148, Multi-User Programming, RELEASE, RESERVE, CLOSE]
---
The **Protect** `command` enables and disables two types of file protection.

The PROTECT command requires a choice between one of four different parameters: RESERVE, READ, WRITE, or RELEASE (see below).

The "RESERVE" parameter prevents others from using the specified file or file name. "READ" allows all workstations to read file data (the file must exist), but not to change it (the file is write protected). "WRITE" removes the READ-only status and allows all workstations to READ and WRITE to the file. Both the READ and WRITE parameters refer to the current workstation as well as to others. "RELEASE" removes PROTECT RESERVE restrictions which have been initiated by the current workstation from the specified file. A RELEASE can only be done from the workstation that initiated the PROTECT restrictions.

The following procedure file illustrates the use of PROTECT to prevent others from using the customer file while deleted records are removed and the index is rebuilt:

 PROCERR RETURN
 PROTECT CUSTMAST,RESERVE
 PROCERR STOP
 SKIP DONE IF ERR <> 0
 COPY CUSTMAST WORK[WSID] -D
 FREE CUSTMAST
 RENAME WORK[WSID] CUSTMAST
 INDEX CUSTMAST,CUSTMAST.KEY,1,4,REPLACE
 PROTECT CUSTMAST,RELEASE
 :DONE
 CHAIN "MENU"

If the PROTECT RESERVE instruction had not been issued for the above procedure, another workstation would have been able to open the file during the COPY; such an occurrence would prevent the FREE and RENAME commands from executing.

When PROTECT RESERVE is successful, other workstations are not allowed access to the full path name of the file. Business Rules consults an internal table of file reservations before beginning every OPEN process; if the specified file is reserved, the system returns a `4148` error (file sharing rules violated) without even accessing the disk. The SKIP command needs to only test ERR for zero or nonzero because the PROCERR RETURN forces ERR to be zero.

The PROTECT command may also be used to reserve a file's name even when the FREE command has been used to delete the rest of the file. This feature allows you to reserve a file, then delete the file while continuing to reserve the file's name. You can then rename the contents of another file to the reserved file name. You can even reserve files that do not exist.

==Comments and Examples==
Multi-user file protection is controlled with the RESERVE and RELEASE parameters. PROTECT with the RESERVE parameter allows a file or file name to be reserved for exclusive use at the workstation issuing the command.

 PROTECT CUSTOMER.FIL RESERVE

RESERVE status keeps a file locked even when the file is not open. It also reserves the file name, even when the file is freed, so that no other workstation can create a file with the same name. The RELEASE parameter removes this exclusive control.

 PROTECT CUSTOMER.FIL RELEASE

The second type of file protection is controlled with the READ and WRITE parameters. The READ parameter makes a file read-only (makes it write-protected) until changed by another PROTECT command with a WRITE parameter. Permissions at the operating system determine the success or failure or the READ and WRITE options.

 PROTECT CUSTOMER.FIL, READ
 PROTECT CUSTOMER.FIL, WRITE

For additional information about locking or sharing both files and records, see `Multi-User Programming`.

==Syntax==
 PROTECT <file name> {READ|`RELEASE`|`RESERVE`|WRITE}
`Image:Protect.png`

==Parameters==
**File NAME** is the name and path of the file to be protected.<br>

**READ** allows all workstations to read file data, but not to change it (the file is write protected). This parameter restricts all workstations, including the workstation that issues the command.<br>

**RELEASE** removes RESERVE restrictions which have been initiated by the current workstation for the specified file. This parameter can be issued only from the workstation that initiated the RESERVE restrictions.<br>

**RESERVE** prevents all others from using the specified file.<br>

**WRITE** removes READ-only status and allows all workstations to READ and WRITE to the file.

==Technical Considerations==
# An alternative to releasing locked files with PROTECT RELEASE is to use the `CLOSE` statement with its RELEASE parameter. (This can only be done when the file to be released is currently open.)
# An alternative to reserving files with PROTECT RESERVE is to use the OPEN statement with its RESERVE parameter.
# The STATUS ALL command provides a list of file name reservations which have been issued from the current workstation.
# All file name reservations issued from a particular workstation are automatically released when that workstation exits from BR.
# The PROTECT command may be used to reserve a file's name when a file does not exist or when the FREE command has been used to delete the file.
# File locking with the PROTECT command differs from file locking with the NOSHR parameter in two main ways: PROTECT keeps a file locked even when the file is not open; and PROTECT does not prevent other opens to the same file by the same workstation.
# READ and WRITE file protection can be used on single-user or multi-user systems. The READ protection is not removed from the file when the workstation exits from BR.
