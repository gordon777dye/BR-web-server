---
title: BR Error Code Reference
file: error-reference.md
category: dev
kind: reference
status: 1a
description: Distilled reference for 70 of the most critical BR error codes, organized by category with causes, scenarios, fixes, and example code.
corrections:
  - "Error 0117 \"Invalid numeric expression\" removed: **there is no BR error 117.** BR's own table (brs/wberrdefs.h) runs 105, 106, 108, 120, 121, 122, 123, 130 with nothing between 108 and 120, and br_tree has no page for it — of the 69 write-ups here it was the only one with neither a br_tree page nor a definition in BR's source, which is how gendata found it. The entry was also wrong about its own subject: it gave \"Division by zero: LET x = 5 / 0\" as the leading cause, and BR's divide-by-zero is error **6** (BREDIVIDEBYZERO). Found in brls phase 5."
---

# BR Error Code Reference

This is a curated, model-friendly distillation of 70 critical BR error codes, in 68 write-ups (4194/4195/4196 share one). Each entry gives the cause, common scenarios, fixes, example recovery code and related errors. Organized by category for quick lookup.

Every code here is one BR's own error table defines. Do not add an entry without checking
`brs/wberrdefs.h` or a `br_tree/90-reference/error-codes/` page for it first — one invented entry
(0117) reached this file and survived until the generator cross-checked the two.

## Table of Contents

1. **[File I/O Errors (41xx)](#file-io-errors)** — 26 codes
2. **[Function Definition Errors (03xx)](#function-definition)** — 11 codes
3. **[Flow Control Errors (02xx)](#flow-control)** — 9 codes
4. **[Array & Subscript Errors (01xx)](#array-subscript)** — 7 codes
5. **[Syntax & Parsing Errors (10xx)](#syntax-parsing)** — 11 codes
6. **[Critical System Errors (90xx)](#critical-system)** — 2 codes
7. **[Other Important Errors](#other)** — 4 codes

---

## File I/O Errors (41xx) {#file-io-errors}

### Error 4100 — Invalid or Missing File Number

**Cause:** File number reference is missing or invalid in an OPEN or I/O statement. The file number must be prefixed with a pound sign (#).

**Common scenarios:**
- Using `OPEN "NAME=filename"` instead of `OPEN #1: "NAME=filename"`
- Missing # symbol in READ, WRITE, or PRINT statements
- Variable list missing in READ data statement

**Fix:**
1. Add the pound sign (#) before the file number in OPEN statements
2. Verify all I/O statements use the correct file number syntax: `#filenumber`
3. Ensure READ statements include the variable list for input operations

**Example recovery code:**
```br
! WRONG: OPEN "NAME=data.dat", INTERNAL, INPUT   ! no #channel
! RIGHT:
OPEN #1: "NAME=data.dat", INTERNAL, INPUT
READ #1: recvar
CLOSE #1:
```

**Related errors:** 4101, 4115, 4138, 4152

---

### Error 4115 — Database Not Opened

**Cause:** Attempted to perform an operation on a database file that has not been opened with an OPEN statement.

**Common scenarios:**
- Accessing file data before OPEN statement executes
- File reference used in wrong scope or subroutine
- OPEN statement executed conditionally but data access is unconditional

**Fix:**
1. Add OPEN statement before any READ, WRITE, or other file operations
2. Verify OPEN statement is not nested in a conditional block that may be skipped
3. Check file number consistency between OPEN and data access statements

**Example recovery code:**
```br
0010 LET filename$ = "mydata.dat"
0020 OPEN #1: "NAME=" & FILENAME$, INTERNAL, INPUT
0030 READ #1: RECORD$
0040 CLOSE #1:
```

**Related errors:** 4100, 4152, 4173

---

### Error 4120 — Invalid Y2K Data in Index Field

**Cause:** A Y2K index field contains corrupted or improperly formatted date data.

**Common scenarios:**
- Legacy data with improper Y2K conversion
- Date field exceeds valid Y2K range
- Index file header corrupted by system crash

**Fix:**
1. Use REINDEX command to rebuild the B-tree index
2. Set Option 27 in BRConfig.sys to suppress error (if safe to do so)
3. Validate and correct date data before re-indexing
4. Restore from backup if data corruption is widespread

**Example recovery code:**
```br
0010 EXECUTE "INDEX data.dat data.key 1 10 REPLACE"
0020 ! Verify data after reindex
0030 OPEN #1: "NAME=data.dat,KFNAME=data.key", INTERNAL, OUTIN, KEYED
0040 READ #1, KEY=MYKEY$: RECORD$ NOKEY 0090
```

**Related errors:** 4123, 4127, 4180

---

### Error 4122 — Invalid Access for File Type

**Cause:** Mismatch between the file type and the access mode being attempted (e.g., trying to print to an internal file, or access a file opened as a different type).

**Common scenarios:**
- Attempting PRINT to a file opened INTERNAL
- Opening same file as both internal and external
- Program file opened as key file
- Damaged file header preventing proper type detection

**Fix:**
1. Match access type to file type: internal files use READ/WRITE, display files use PRINT
2. Ensure file is closed before reopening with different access mode
3. Rebuild corrupted internal files (see error 4124)
4. Use correct FORM= parameter in OPEN statement

**Example recovery code:**
```br
! Display file - use PRINT
OPEN #1: "NAME=report.txt,REPLACE", DISPLAY, OUTPUT
PRINT #1: "Report Header"

! Internal file - use READ/WRITE
OPEN #2: "NAME=data.dat,KFNAME=data.key", INTERNAL, OUTIN, KEYED
READ #2, KEY="ABC": RECORD$ NOKEY 9000
REWRITE #2: RECORD$
```

**Related errors:** 4121, 4123, 4125

---

### Error 4123 — Incomplete Record or Corrupted B-Tree

**Cause:** File corruption in the B-tree index structure, often due to bit-locking issues or index exceeding size limits.

**Common scenarios:**
- Power failure during index write operation
- Index file exceeds maximum size limit
- Bit-locking collision in multi-user environment
- File copy interrupted mid-operation

**Fix:**
1. Reindex the file using REINDEX command
2. Rebuild from backup if reindex fails
3. Check for available disk space before reindex
4. Verify bit-locking is properly configured (Option 31)

**Example recovery code:**
```br
0010 ! Attempt to reindex corrupted file
0020 EXECUTE "INDEX data.dat data.key 1 10 REPLACE"
0030 ! If reindex fails, restore from backup
0040 OPEN #1: "NAME=backup.dat", INTERNAL, INPUT
0050 OPEN #2: "NAME=data.dat,RECL=128,REPLACE", INTERNAL, OUTPUT
```

**Related errors:** 4120, 4124, 4127

---

### Error 4124 — Invalid Header Record for Internal File

**Cause:** Internal file header is corrupted or incompatible (often from CPU architecture mismatch or file format corruption).

**Common scenarios:**
- File ported between Intel and non-Intel systems without conversion
- Both KFNAME and NAME point to the same file in OPEN statement
- Header overwritten by external process
- Incomplete file copy

**Fix:**
1. Run conversion program (wb2unix or wb2dos) if porting between architectures
2. Ensure KFNAME and NAME parameters use different files
3. Restore from backup if conversion fails
4. Recreate file from source data

**Example recovery code:**
```br
! WRONG: KFNAME and NAME same file
! OPEN #1: "NAME=data.dat,KFNAME=data.dat", INTERNAL, OUTIN, KEYED

! RIGHT: Separate key and data files
OPEN #1: "NAME=data.dat,KFNAME=data.key", INTERNAL, OUTIN, KEYED
```

**Related errors:** 4123, 4125, 4126

---

### Error 4125 — Data File VERSION Error

**Cause:** File version number in header does not match the VERSION number specified in the OPEN statement.

**Common scenarios:**
- Opening file created in older BR version
- VERSION parameter in OPEN doesn't match file format
- File header corrupted

**Fix:**
1. Update the VERSION number in OPEN statement to match actual file format
2. Update the file if it's in an older format (use conversion utilities)
3. Check BRC documentation for correct VERSION number for your BR release
4. Verify file integrity before attempting access

**Example recovery code:**
```br
! Check file version during open
ON ERROR GOTO HANDLE_ERROR
OPEN #1: "NAME=legacy.dat,VERSION=3", INTERNAL, INPUT
GOTO DONE
HANDLE_ERROR: LET VERNO = ERR
PRINT "File version mismatch. Current error:"; VERNO
DONE: !
```

**Related errors:** 4122, 4124, 4126

---

### Error 4126 — File Abnormally Truncated

**Cause:** File header record count does not match actual data in file. Indicates data loss from abnormal termination or incomplete write.

**Common scenarios:**
- BR! terminated with Ctrl+Alt+Delete during write
- Power failure during file operation
- Copy operation interrupted mid-process
- Disk full during write operation

**Fix:**
1. Restore from backup if data loss is unacceptable
2. Use REORG command to rebuild file structure
3. Verify disk space and system stability before retry
4. Implement periodic backups and transaction logging

**Example recovery code:**
```br
0010 ! Attempt to rebuild truncated file
0020 EXECUTE "INDEX data.dat data.key 1 10 REORG"
0030 OPEN #1: "NAME=data.dat,KFNAME=data.key", INTERNAL, OUTIN, KEYED
0040 ! Verify file integrity
0050 READ #1: RECORD$ EOF 0070 IOERR 0060
0060 PRINT "File still corrupted, error"; ERR
```

**Related errors:** 4123, 4124, 4127

---

### Error 4127 — Related Key Files Don't Match

**Cause:** Key files are not the same type (one is ISAM, the other is B-tree) when they should both be identical type.

**Common scenarios:**
- Mixed ISAM and B-tree indexes for same data file
- Key file replaced with incompatible version
- Partial reindex operation interrupted

**Fix:**
1. Verify all key files use consistent indexing method
2. Reindex all key files to same type: `EXECUTE "REINDEX", "#1", "data.dat"`
3. Ensure every index of a file is opened with the same index type (ISAM or BTREE)
4. Recreate key files if type conversion is required

**Example recovery code:**
```br
! Open every index of a file with the same index type
OPEN #1: "NAME=data.dat,KFNAME=key1.idx,ISAM", INTERNAL, OUTIN, KEYED
OPEN #2: "NAME=data.dat,KFNAME=key2.idx,ISAM", INTERNAL, OUTIN, KEYED
! Both key files now same type
```

**Related errors:** 4123, 4124, 4125

---

### Error 4129 — File Name Too Long

**Cause:** File name exceeds BR's maximum allowed length for file paths.

**Common scenarios:**
- Path with deep directory nesting exceeds limit
- File name includes full path exceeding maximum
- Network path too long in client-server setup

**Fix:**
1. Shorten file name or use shorter directory structure
2. Move file to directory with shorter path
3. Use relative paths instead of absolute paths if possible
4. Check BRConfig.sys for path length settings

**Example recovery code:**
```br
! WRONG: filename too long
! LET filename$ = "C:\Very\Long\Directory\Path\With\Many\Subdirectories\mydata.dat"

! RIGHT: Shorter path or use working directory
LET filename$ = "data.dat"
OPEN #1: "NAME=" & FILENAME$, INTERNAL, INPUT
```

**Related errors:** 4100, 4152, 4180

---

### Error 4138 — Can't Rename Between Client and Server

**Cause:** Attempted to rename a file that exists on client-server, but rename operation spans between client and server filesystems.

**Common scenarios:**
- Renaming local file to network location
- Renaming network file to local location
- File reservation prevents cross-location rename

**Fix:**
1. Ensure source and target are in same location (client or server)
2. Copy file to target location, then delete original if needed
3. Use full paths consistently for client-server operations
4. Verify file reservation status before rename

**Example recovery code:**
```br
! Copy instead of rename across locations
OPEN #1: "NAME=local.dat", INTERNAL, INPUT
OPEN #2: "NAME=@server:remote.dat,RECL=128,REPLACE", INTERNAL, OUTPUT
DO
   READ #1: RECORD$ EOF 0100
   WRITE #2: RECORD$
LOOP
```

**Related errors:** 4139, 4150, 4174

---

### Error 4139 — Could Not Re-reserve File

**Cause:** File reservation could not be restored after a name change operation.

**Common scenarios:**
- Reservation system conflict during rename
- File no longer accessible after rename
- WBSERVER.DAT corruption preventing re-reservation

**Fix:**
1. Close and reopen file to re-establish reservation
2. Verify file still exists and is accessible after rename
3. Check WBSERVER.DAT integrity (error 4161-4166)
4. Release file locks if stuck and retry operation

**Example recovery code:**
```br
0010 ! Release file and retry reservation
0020 RELEASE #1:
0030 CLOSE #1:
0040 OPEN #1: "NAME=" & NEWNAME$, INTERNAL, OUTIN
```

**Related errors:** 4138, 4170, 4171, 4172

---

### Error 4150 — Duplicate File Name

**Cause:** Attempted to create a file with a name that already exists.

**Common scenarios:**
- CREATE open mode, but file already exists
- Backup operation overwrites existing file
- Multiple processes creating same file

**Fix:**
1. Delete the existing file if that is safe: `EXECUTE "FREE " & FILENAME$`
2. Use different file name
3. Use different disk or directory
4. Check for file locks that prevent deletion

**Example recovery code:**
```br
0010 LET filename$ = "newdata.dat"
0020 ON ERROR GOTO 0050
0030 OPEN #1: "NAME=" & FILENAME$ & ",RECL=128,NEW", INTERNAL, OUTPUT
0040 GOTO 0090
0045 !
0050 IF ERR = 4150 THEN
0060   EXECUTE "FREE " & FILENAME$
0070   RETRY
0080 END IF
0090 !
```

**Related errors:** 4152, 4153, 4174

---

### Error 4152 — File Not Found

**Cause:** The specified file does not exist in the specified location, or the path is invalid.

**Common scenarios:**
- File name typo in path
- File was deleted or moved
- Incorrect disk or drive specified
- Directory doesn't exist
- Permission denied (Unix/Linux)

**Fix:**
1. Verify file name spelling and location
2. Check that directory path exists
3. Verify file was not deleted or moved
4. On Unix/Linux, verify file permissions (use `ls -l`)
5. Use DIR command to list available files

**Example recovery code:**
```br
0010 LET filename$ = "data.dat"
0020 IF NOT EXISTS(filename$) THEN
0030   PRINT "File not found:", filename$
0040   PRINT "Creating new file..."
0050   OPEN #1: "NAME=" & FILENAME$ & ",RECL=128,NEW", INTERNAL, OUTPUT
0060 ELSE
0070   OPEN #1: "NAME=" & FILENAME$, INTERNAL, OUTIN
0080 END IF
```

**Related errors:** 4100, 4129, 4160

---

### Error 4160 — Open Files Limit Exceeded

**Cause:** BR's internal file handle limit (594 on Windows) has been exceeded, or OS file handles are exhausted.

**Common scenarios:**
- Loop opening files without closing them
- Recursive calls accumulating file handles
- Too many concurrent users accessing files
- OS file handle limit reached

**Fix:**
1. Close files when no longer needed: `CLOSE #filenumber:`
2. Consolidate file operations to reduce number of open files
3. Rewrite loops to reuse file handles
4. Increase OS file handle limits if supported
5. Reduce number of concurrent users

**Example recovery code:**
```br
! WRONG: Loop accumulates open files
FOR i = 1 TO 1000
  OPEN #I: "NAME=file" & STR$(I) & ".dat", INTERNAL, INPUT
NEXT i

! RIGHT: Reuse file handle
FOR i = 1 TO 1000
  IF i > 1 THEN CLOSE #1:
  OPEN #1: "NAME=file" & STR$(I) & ".dat", INTERNAL, INPUT
  READ #1: RECORD$ EOF 0900
NEXT i
CLOSE #1:
```

**Related errors:** 4100, 4152, 4173

---

### Error 4170 — Unable to Release File

**Cause:** Attempted to release a file lock that was locked by a different user (WSID and SESSION ID do not match).

**Common scenarios:**
- User A locked file, User B tries to release it
- Session IDs don't match after reconnection
- File reservation in inconsistent state

**Fix:**
1. Verify only the user who locked the file releases it
2. Have correct user perform the RELEASE statement
3. Check WSID and SESSION information with STATUS command
4. Use `RESERVE #filenumber:` to re-establish exclusive access

**Example recovery code:**
```br
0010 RESERVE #1:
0020 ! Perform exclusive operations
0030 RELEASE #1:
0040 ! Verify release with STATUS
0050 LET FSTATUS = FILE(1)
0060 PRINT "File status:"; FSTATUS
```

**Related errors:** 4171, 4172, 4173

---

### Error 4171 — Could Not Lock (Reserve)

**Cause:** Unable to lock the "reserve checking in process" marker when attempting to reserve a file.

**Common scenarios:**
- File reservation system is stuck
- WBSERVER.DAT corrupted or inaccessible
- Multiple processes competing for same reservation
- Timeout waiting for lock

**Fix:**
1. Check WBSERVER.DAT integrity (see errors 4161-4166)
2. Restart BR or file server to reset reservation system
3. Reduce concurrent access or stagger file operations
4. Check system logs for lock timeouts

**Example recovery code:**
```br
0010 LET retry_count = 0
0020 RETRY_LOOP: RESERVE #1: IOERR 0030
0030 IF ERR = 4171 THEN
0040   LET retry_count = retry_count + 1
0050   IF retry_count > 3 THEN
0060     PRINT "Failed to reserve file after 3 retries"
0070     GOTO 0120
0080   END IF
0090   LET Z = SLEEP(1)
0100   GOTO RETRY_LOOP
0110 END IF
0120 !
```

**Related errors:** 4172, 4173, 4174

---

### Error 4172 — Could Not Lock (Release)

**Cause:** Unable to lock the "reserve checking in process" marker when attempting to release a file.

**Common scenarios:**
- File release operation interrupted
- WBSERVER.DAT access problem
- File reservation becomes orphaned
- Race condition in multi-user environment

**Fix:**
1. Retry the RELEASE operation
2. Close and reopen the file
3. Check WBSERVER.DAT integrity
4. Restart the application if orphaned reservations suspected

**Example recovery code:**
```br
0010 ON ERROR GOTO 0050
0020 RELEASE #1:
0030 CLOSE #1:
0040 GOTO 0100
0045 !
0050 IF ERR = 4172 THEN
0060   ! Force close without release
0070   CLOSE #1:
0080   PRINT "File closed (forced)"
0090 END IF
0100 !
```

**Related errors:** 4170, 4171, 4173

---

### Error 4173 — Could Not Open

**Cause:** Unable to lock the "reserve checking in process" marker when opening a file.

**Common scenarios:**
- File reservation system overloaded
- WBSERVER.DAT corrupted or full
- System resource limits reached
- Timeout during file open

**Fix:**
1. Verify WBSERVER.DAT has adequate space and is accessible
2. Retry the OPEN operation
3. Close other files to reduce load
4. Check system memory and resources
5. Restart BR if reservation system is stuck

**Example recovery code:**
```br
0010 LET max_retries = 3
0020 LET retry = 0
0030 OPEN_RETRY: !
0040 OPEN #1: "NAME=data.dat", INTERNAL, OUTIN IOERR OPEN_FAIL
0050 GOTO OPEN_SUCCESS
0060 OPEN_FAIL: !
0070 IF ERR = 4173 AND retry < max_retries THEN
0080   LET retry = retry + 1
0090   LET Z = SLEEP(2)
0100   GOTO OPEN_RETRY
0110 END IF
0120 OPEN_SUCCESS: !
```

**Related errors:** 4170, 4171, 4172

---

### Error 4174 — Attempted File Reservation on Non-local File

**Cause:** Attempted to reserve a file that exists on a remote server in BR! 4.30 or later.

**Common scenarios:**
- File accessed via network path (e.g., @server:)
- Reservation attempted on non-local (client-server) file
- Mixed local and remote file access

**Fix:**
1. Work with local file copies for reserved operations
2. Use client-server file specification (@server:) without reservation
3. Coordinate multi-user access through application logic instead of file locks
4. Upgrade to version supporting remote reservations if available

**Example recovery code:**
```br
! Remote file access (no reservation)
OPEN #1: "NAME=@server:data.dat", INTERNAL, OUTIN

! Local file access (with reservation)
OPEN #2: "NAME=local.dat", INTERNAL, OUTIN
RESERVE #2:
```

**Related errors:** 4138, 4170, 4171, 4172

---

### Error 4180 — Bad Drive Statement

**Cause:** Drive specification in BRConfig.sys is invalid (directory doesn't exist, missing parameters, or syntax error).

**Common scenarios:**
- Drive path does not exist or is invalid
- Missing third parameter in DRIVE statement
- Blank third parameter
- Network path not mounted

**Fix:**
1. Verify directory exists in drive statement
2. Add missing third parameter to DRIVE statement (cannot be blank)
3. Check syntax of drive statement
4. Mount network drive if using network path
5. Remove or comment out invalid drive statement

**Example recovery code:**
```text
! BRConfig.sys — DRIVE is a configuration directive, not a BR statement
! WRONG: DRIVE A: C:\BR (missing third parameter)
! WRONG: DRIVE A: C:\notexist\

! RIGHT:
DRIVE A: C:\BR\ \DEMO\
DRIVE B: C:\DATA\ \FILES\
```

**Related errors:** 4114, 4115, 4138

---

### Error 4184 — Drive Already Mapped

**Cause:** Attempted to map a drive letter that is already mapped to another path.

**Common scenarios:**
- Drive statement maps same drive twice
- Drive already mapped by OS or BR
- Conflicting drive assignment

**Fix:**
1. Use different drive letter
2. Remove duplicate drive statement from BRConfig.sys
3. Verify drive assignments with DIR @: command
4. Unmap drive before remapping (if possible)

**Example recovery code:**
```text
! BRConfig.sys and the command console — not program statements
! Check drive status
DIR @:

! Use unassigned drive letter
DRIVE C: C:\MyDir\ \DEMO\

! Or rename the mapping in BRConfig.sys
DRIVE E: C:\DATA\ \FILES\
```

**Related errors:** 4180, 4181, 4185

---

### Error 4185 — Client Dir Invalid

**Cause:** Client directory specification in DIR @ statement is invalid or inaccessible on the client system.

**Common scenarios:**
- Path doesn't exist on client
- Insufficient permissions on client
- Network disconnection during DIR operation
- Malformed client path specification

**Fix:**
1. Verify client directory path exists and is accessible
2. Check file permissions on client system
3. Verify network connectivity
4. Use absolute path instead of relative path
5. Check DIR @ syntax

**Example recovery code:**
```br
0010 LET client_dir$ = "C:\DATA"
0020 IF EXISTS(CLIENT_DIR$) = 0 THEN
0030   PRINT "Client directory does not exist:", client_dir$
0040   GOTO 0070
0050 END IF
0060 EXECUTE "DIR " & CLIENT_DIR$
0070 !
```

**Related errors:** 4180, 4184

---

### Error 4194/4195/4196 — Null Record Encountered

**Cause:** Network error during file read/write/rewrite operation. Null byte check failed, indicating serious network communication failure.

**Common scenarios:**
- Network interruption during file operation
- Server disconnection mid-operation
- Corrupted network packet
- Client-server protocol mismatch

**Fix:**
1. Verify network connectivity
2. Check file server status
3. Retry the operation
4. If persistent, close and reopen file
5. Restart BR or file server if needed

**Example recovery code:**
```br
0010 ON ERROR GOTO 0050
0020 OPEN #1: "NAME=@server:data.dat", INTERNAL, OUTIN
0030 WRITE #1: RECORD$
0040 GOTO 0100
0045 !
0050 IF ERR >= 4194 AND ERR <= 4196 THEN
0060   PRINT "Network error occurred during file operation"
0070   CLOSE #1:
0080   PRINT "Retrying connection..."
0090 END IF
0100 !
```

**Related errors:** 4138, 4160, 4173

---

## Function Definition Errors (03xx) {#function-definition}

### Error 0301 — Def Conflict: Number of Parameters

**Cause:** User-defined function parameters don't match the DEF statement definition (wrong number, type, or array specification).

**Common scenarios:**
- Function call has 3 parameters but DEF expects 2
- Passing scalar to function expecting array (missing MAT)
- Passing array to function expecting scalar
- Type mismatch (string vs numeric)

**Fix:**
1. Count parameters in DEF statement and function call—must match exactly
2. Add MAT keyword if passing arrays
3. Verify parameter types match (string, numeric, array)
4. Check if optional parameters are being handled correctly

**Example recovery code:**
```br
! DEF statement with 3 parameters
DEF fnCalculate(num_val, str_val, mat values)
  LET result = num_val + LEN(str_val)
  LET FNCALCULATE = RESULT
FNEND

! Correct call
DIM DATA(5)
LET X = FNCALCULATE(42, "test", MAT DATA)

! WRONG calls that cause error:
! LET X = FNCALCULATE(42, "test")        ! missing the array argument
! LET X = FNCALCULATE(42, "test", DATA)  ! missing the MAT keyword
```

**Related errors:** 0302, 0303, 0304, 0305

---

### Error 0302 — Library Function Not Defined

**Cause:** A user-defined function is referenced (called) but not defined with a DEF statement, or an internal function is used in unsupported BR version.

**Common scenarios:**
- Typo in function name call
- Function definition deleted or not saved
- Using new internal function (Str2Mat) in old BR version
- LIBRARY statement references undefined function

**Fix:**
1. Verify function name spelled correctly in both DEF and calls
2. Define the function with DEF statement
3. Ensure DEF statement was saved
4. For internal functions, check if available in your BR version
5. Add LIBRARY statement for library functions

**Example recovery code:**
```br
! Define the function before using it
DEF fnMyFunction(x)
  LET FNMYFUNCTION = X * 2
FNEND

! Now call it
LET RESULT = FNMYFUNCTION(5)

! For internal functions, check version
IF WBVERSION$ >= "4.3" THEN
  LET ARR$ = "one,two,three"
  LET N = STR2MAT(ARR$, MAT MYARR$)
END IF
```

**Related errors:** 0301, 0303, 0305, 0320

---

### Error 0303 — Illegal Pass by Reference to User Function

**Cause:** Attempted to pass a literal value to a function parameter declared as pass-by-reference (using & in DEF), but only variables can be passed by reference.

**Common scenarios:**
- Calling function with constant: `fnTest("literal", &param)`
- DEF expects reference but call passes literal
- Passing expression instead of variable

**Fix:**
1. If parameter needs reference, pass a variable not literal
2. Remove & from DEF parameter if literal passing is needed
3. Create temp variable for literal to pass by reference

**Example recovery code:**
```br
! WRONG: DEF expects reference, call passes literal
! DEF FNTEST(VAL_IN$, &REF$)
! LET X$ = FNTEST$("test", &UNKNOWNVAR$)   ! the & belongs on the DEF, not the call

! RIGHT: Pass actual variable
DEF FNTEST$(VAL_IN$, &REF$)
  LET REF$ = VAL_IN$ & "modified"
  LET FNTEST$ = REF$
FNEND

LET MYSTRING$ = "original"
LET RESULT$ = FNTEST$("test", MYSTRING$)   ! MYSTRING$ comes back changed
```

**Related errors:** 0301, 0302, 0304

---

### Error 0304 — Def Variable Type Conflict

**Cause:** Parameter type in function call doesn't match DEF statement definition (numeric vs string, or wrong number of parameters).

**Common scenarios:**
- Passing numeric where string expected
- Wrong number of parameters in call
- Using = instead of := for inline assignment in function call
- Array/scalar mismatch

**Fix:**
1. Convert parameter types to match DEF
2. Verify parameter count matches DEF
3. Use := for inline assignments inside function calls (not =)
4. Use MAT keyword consistently for arrays

**Example recovery code:**
```br
! DEF with specific types
DEF FNPROCESS$(NUM_VAL, STR_VAL$)
  LET FNPROCESS$ = STR$(NUM_VAL) & STR_VAL$
FNEND

! Correct calls
LET RESULT$ = FNPROCESS$(42, "test")
LET RESULT$ = FNPROCESS$(MYNUM, "test")

! WRONG - causes error:
! LET RESULT$ = FNPROCESS$("42", "test")  ! string where a number is wanted
! LET X$ = FNPROCESS$(Y=5, "test")        ! use := to assign inside an expression
```

**Related errors:** 0301, 0302, 0303, 0306

---

### Error 0305 — Library Function Not Named on LIBRARY Statement

**Cause:** A program defines and uses a library function (DEF LIBRARY FNname), but the function is not listed in any LIBRARY statement.

**Common scenarios:**
- DEF LIBRARY defined but no LIBRARY statement anywhere
- LIBRARY statement incomplete or wrong function name
- Function name typo in LIBRARY statement

**Fix:**
1. Add LIBRARY statement with exact function name match
2. Place LIBRARY statement before or after DEF but in program
3. Match function name exactly (case-sensitive check)

**Example recovery code:**
```br
! Define library function
DEF LIBRARY fnHelper(x)
  LET FNHELPER = X * 2
FNEND

! Add LIBRARY statement - MUST be present
LIBRARY "helper.br": FNHELPER

! Now library function can be used
0100 LET RESULT = FNHELPER(5)
```

**Related errors:** 0301, 0302, 0320

---

### Error 0306 — FNEND Not Matched with DEF

**Cause:** FNEND statement occurs without a preceding DEF, or FNEND is inside another control structure (FOR/NEXT, IF, GOSUB) where it shouldn't be.

**Common scenarios:**
- Extra FNEND with no matching DEF
- FNEND inside a FOR loop or IF block
- DEF and FNEND line numbers out of order
- Nested function definitions (illegal)

**Fix:**
1. Verify every DEF has exactly one matching FNEND
2. Move FNEND outside any FOR/NEXT, IF/END IF, GOSUB structures
3. Check that FNEND line number is after DEF
4. Ensure functions are not nested

**Example recovery code:**
```br
! WRONG: FNEND inside FOR loop
! DEF fnTest
!   FOR i = 1 TO 10
!     ...
!   FNEND
! NEXT i

! RIGHT: FNEND after FOR
DEF fnTest
  FOR i = 1 TO 10
    PRINT I
  NEXT i
FNEND
```

**Related errors:** 0309, 0310, 0307

---

### Error 0307 — Inactive User-defined Function

**Cause:** Attempted to assign a value to a function variable when the function is not active (hasn't been called, or FNEND has already been reached).

**Common scenarios:**
- GOTO into middle of function
- Assigning to function result after FNEND executed
- Function called but then exited via GOTO
- Function variable referenced outside its scope

**Fix:**
1. Don't use GOTO to jump into or out of functions
2. Ensure function is actively executing before assigning result
3. Use only normal FNEND exit from functions
4. Properly structure function calls and returns

**Example recovery code:**
```br
! WRONG: GOTO skips function entry
! GOTO middle
! DEF fnTest
! MIDDLE: LET FNTEST = 5
! FNEND

! RIGHT: Proper function call
DEF fnTest(x)
  LET FNTEST = X * 2
FNEND

LET RESULT = FNTEST(5)
```

**Related errors:** 0306, 0309, 0310

---

### Error 0309 — Illegal Nesting of DEF

**Cause:** One function definition is contained within another function definition, which is not allowed. Also can indicate line numbers out of order.

**Common scenarios:**
- DEF inside another DEF-FNEND block
- Copy-paste creating nested function definitions
- Line numbers out of sequential order causing apparent nesting

**Fix:**
1. Move inner DEF-FNEND block outside the outer function
2. Ensure all function definitions are at program level, not nested
3. Check line number ordering—should be sequential or properly structured
4. Separate functions so each is independent

**Example recovery code:**
```br
! WRONG: Nested functions
! DEF fnOuter
!   DEF fnInner
!     ...
!   FNEND
! FNEND

! RIGHT: Functions at program level
DEF fnInner(x)
  LET FNINNER = X * 2
FNEND

DEF fnOuter(x)
  LET FNOUTER = FNINNER(X) + 1
FNEND
```

**Related errors:** 0306, 0310, 0320

---

### Error 0310 — Missing FNEND Statement

**Cause:** A DEF statement exists without a matching FNEND to close it.

**Common scenarios:**
- FNEND line deleted or commented out
- FNEND with wrong spelling (FEND, FN_END, etc.)
- Function definition spans multiple pages, FNEND on wrong page
- Line numbers make it unclear where function ends

**Fix:**
1. Add FNEND statement after function body
2. Verify spelling: must be exactly FNEND
3. Check line numbering to find function boundaries
4. Use editor's structured view to find unmatched DEF/FNEND

**Example recovery code:**
```br
! WRONG: No FNEND
! DEF fnMissing(x)
!   LET FNMISSING = X * 2

! RIGHT: Add FNEND
DEF fnMissing(x)
  LET FNMISSING = X * 2
FNEND
```

**Related errors:** 0306, 0309, 0307

---

### Error 0315 — Attempt to Re-dimension Sub-array

**Cause:** Attempted to re-dimension an array that was passed to a function, or attempted to re-dimension a parameter that wasn't actually passed.

**Common scenarios:**
- Function receives sub-array from parent, tries to MAT it
- Passing scalar instead of array to function expecting array
- Optional array parameter not passed, then MAT attempted
- Using MAT on parameter that wasn't declared as MAT in DEF

**Fix:**
1. Don't MAT dimension arrays passed as parameters—they're already dimensioned
2. Ensure calling code passes array (with MAT keyword if required)
3. Check DEF parameter matches call (MAT x vs x)
4. For optional parameters, check if passed before MAT

**Example recovery code:**
```br
! WRONG: Trying to MAT dimension received array
! DEF fnProcess(mat data)
!   MAT data(0)  ! ERROR - already dimensioned
!   ...
! FNEND

! RIGHT: Use as-is or create local copy
DEF fnProcess(mat data)
  LET ROWS = UDIM(MAT DATA, 1)
  LET COLS = UDIM(MAT DATA, 2)
  ! ... process existing array
  LET FNPROCESS = ROWS * COLS
FNEND

! Call with array
DIM MYDATA(100)
LET N = FNPROCESS(MAT MYDATA)
```

**Related errors:** 0105, 0106, 0123

---

### Error 0320 — Duplicate Library Function

**Cause:** A user-defined function is defined more than once (either two DEF statements or in both DEF and LIBRARY statements).

**Common scenarios:**
- Function defined twice with DEF
- Function in both DEF LIBRARY and LIBRARY statement
- Copy-paste created duplicate function
- Include files with same function

**Fix:**
1. Remove duplicate DEF statement
2. Use either DEF or DEF LIBRARY, not both
3. Remove one of conflicting function names
4. Check include files for duplicate definitions

**Example recovery code:**
```br
! WRONG: Duplicate definitions
! DEF fnHelper(x)
!   RETURN x * 2
! FNEND
! ... later ...
! DEF fnHelper(x)  ! Duplicate!
!   RETURN x * 2
! FNEND

! RIGHT: Single definition
DEF fnHelper(x)
  LET FNHELPER = X * 2
FNEND

! Or for library functions:
DEF LIBRARY fnHelper(x)
  LET FNHELPER = X * 2
FNEND

LIBRARY "helper.br": FNHELPER  ! not DEF again
```

**Related errors:** 0302, 0305, 0309

---

## Flow Control Errors (02xx) {#flow-control}

### Error 0201 — Return Without GoSub

**Cause:** A RETURN statement is executed without a preceding GOSUB statement in the call stack.

**Common scenarios:**
- RETURN without GOSUB call
- GOTO skipped GOSUB entry point
- GOSUB exited via GOTO instead of RETURN
- RETURN in wrong scope

**Fix:**
1. Ensure GOSUB is called before RETURN
2. Don't use GOTO to exit GOSUB—use RETURN
3. Verify GOSUB is in execution path before RETURN
4. Match GOSUB and RETURN pairs properly

**Example recovery code:**
```br
0010 LET x = 10
0020 GOSUB process_data
0030 PRINT "Result:", x
0040 END

! Wrong path
! 0050 RETURN  ! ERROR - no GOSUB

0100 process_data:
0110 LET x = x * 2
0120 RETURN
```

**Related errors:** 0202, 0211, 0213

---

### Error 0202 — Function Not Active / GOSUB Error

**Cause:** FNEND encountered without active function, or GOSUB called within function with improper exit path.

**Common scenarios:**
- Function tries to exit via FNEND before GOSUB returns
- GOSUB inside function exits function instead of returning from subroutine
- Multiple FNEND without DEF

**Fix:**
1. Ensure GOSUB completes with RETURN before FNEND
2. Verify execution paths in subroutines within functions
3. Use RETURN to exit GOSUB (never FNEND)
4. Match FNEND only with DEF

**Example recovery code:**
```br
! WRONG: Function tries to FNEND before GOSUB returns
! DEF fnProcess
!   GOSUB helper
!   FNEND  ! ERROR - GOSUB still active
! helper:
!   ...
!   RETURN

! RIGHT: Let GOSUB complete
DEF fnProcess
  GOSUB helper
  LET FNPROCESS = RESULT
FNEND

helper:
  LET result = 42
  RETURN
```

**Related errors:** 0201, 0211

---

### Error 0211 — Retry or Continue Without Error

**Cause:** RETRY or CONTINUE statement executed outside an error handler or when no error has occurred.

**Common scenarios:**
- RETRY or CONTINUE not inside error handler (EXIT clause)
- Error condition has cleared but RETRY executed
- RETRY in normal code path

**Fix:**
1. Use RETRY only inside error handlers (after error occurs)
2. Use CONTINUE to skip error and continue
3. Place RETRY/CONTINUE only after error detection
4. Verify error condition still exists before RETRY

**Example recovery code:**
```br
! WRONG: RETRY without error context
! RETRY  ! ERROR - no error occurred

! RIGHT: RETRY in error handler
0010 LET filename$ = "data.dat"
0020 OPEN #1: "NAME=" & FILENAME$, INTERNAL, INPUT IOERR 0040
0030 GOTO 0100
0040 FILE_ERROR: !
0050 IF ERR = 4152 THEN
0060   PRINT "File not found. Creating..."
0070   OPEN #1: "NAME=" & FILENAME$ & ",RECL=128,NEW", INTERNAL, OUTPUT
0080   RETRY
0090 END IF
0100 !
```

**Related errors:** 0201, 0202, 0213

---

### Error 0213 — Line Reference Not Found

**Cause:** Reference to a line number or label that does not exist in the program.

**Common scenarios:**
- GOTO 9999 but line 9999 doesn't exist
- Label name misspelled in GOTO
- Line number deleted but still referenced
- Label defined differently than referenced

**Fix:**
1. Verify line number or label exists in program
2. Check spelling of label names
3. Use LIST command to find actual line numbers
4. Add missing line or label
5. Update references to use existing lines/labels

**Example recovery code:**
```br
! WRONG: Referencing non-existent line
! GOTO 9999  ! Line 9999 doesn't exist

! Also WRONG: Label typo
! GOTO process_data
! ... no label named process_data

! RIGHT: Use existing line
0010 GOTO 0050
0020 ! ... other code ...
0050 LET x = 5

! RIGHT: Define and use label correctly
GOTO process_data
! ... other code ...
process_data:
  LET x = 5
```

**Related errors:** 0201, 0202, 0220, 0221

---

### Error 0220 — Next Before For

**Cause:** A NEXT statement appears before its corresponding FOR statement (line order is wrong).

**Common scenarios:**
- Line numbers out of order
- FOR and NEXT split across pages/sections
- NEXT before corresponding FOR due to line numbering

**Fix:**
1. Ensure FOR statement comes before NEXT
2. Verify line numbers are in correct order
3. Check loop variable matches (FOR i, NEXT i)
4. Renumber lines if necessary for proper order

**Example recovery code:**
```br
! WRONG: NEXT before FOR
! 0100 NEXT i
! 0110 FOR i = 1 TO 10

! RIGHT: FOR before NEXT
0010 FOR i = 1 TO 10
0020   PRINT i
0030 NEXT i
```

**Related errors:** 0221, 0222, 0223

---

### Error 0221 — Missing For Statement

**Cause:** NEXT statement occurs with no matching FOR, or FOR/NEXT variables don't match.

**Common scenarios:**
- NEXT without FOR
- FOR and NEXT use different variables (FOR i, NEXT j)
- Nested loops with mismatched variables
- Line order problems (same as 0220)

**Fix:**
1. Add FOR statement before NEXT
2. Ensure FOR and NEXT use identical loop variable
3. Match nesting properly for multiple loops
4. Fix line numbering if out of order

**Example recovery code:**
```br
! WRONG: NEXT without FOR or variable mismatch
! NEXT i  ! No FOR

! Wrong variables:
! FOR i = 1 TO 10
! NEXT j  ! j doesn't match i

! RIGHT: Proper FOR/NEXT pairing
FOR i = 1 TO 10
  FOR j = 1 TO 5
    PRINT i, j
  NEXT j
NEXT i
```

**Related errors:** 0220, 0222, 0223

---

### Error 0222 — Missing Next Statement

**Cause:** FOR statement without corresponding NEXT statement to close the loop.

**Common scenarios:**
- NEXT statement deleted or not written
- Multiple FOR loops but not enough NEXT statements
- Line numbers prevent finding the NEXT
- FOR/NEXT mismatch in nesting

**Fix:**
1. Add NEXT statement after FOR body
2. Verify NEXT variable matches FOR variable
3. For nested loops, NEXT in reverse order of FOR
4. Check line numbers are sequential

**Example recovery code:**
```br
! WRONG: FOR without NEXT
! FOR i = 1 TO 10
!   PRINT i
! (missing NEXT i)

! RIGHT: Complete FOR/NEXT
FOR i = 1 TO 10
  PRINT i
NEXT i

! RIGHT: Nested loops
FOR i = 1 TO 10
  FOR j = 1 TO 5
    PRINT i, j
  NEXT j
NEXT i
```

**Related errors:** 0220, 0221, 0223

---

### Error 0223 — FOR NEXT Variable Mismatch

**Cause:** Multiple FOR loops active with same variable, or FOR and NEXT variables don't match in nested loops.

**Common scenarios:**
- Reusing loop variable in nested FOR: `FOR i / FOR i / NEXT i / NEXT i`
- FOR and NEXT use different variables
- Loop structure confused

**Fix:**
1. Use different variables for nested loops
2. Match FOR and NEXT variables exactly
3. Close innermost loop first (LIFO order)

**Example recovery code:**
```br
! WRONG: Reused variable
! FOR i = 1 TO 10
!   FOR i = 1 TO 5  ! ERROR - i already used
!   NEXT i
! NEXT i

! RIGHT: Different variables
FOR i = 1 TO 10
  FOR j = 1 TO 5
    PRINT i, j
  NEXT j
NEXT i
```

**Related errors:** 0220, 0221, 0222

---

### Error 0230 — Not an Exit Statement

**Cause:** An I/O statement references an EXIT condition, but the line number specified does not contain an EXIT statement.

**Common scenarios:**
- EXIT parameter points to wrong line
- Line with EXIT deleted but reference remains
- Typo in line number reference

**Fix:**
1. Verify EXIT line number actually has EXIT statement
2. Move EXIT statement to referenced line
3. Update EXIT parameter to match actual EXIT line
4. Use LIST to find correct line number

**Example recovery code:**
```br
! WRONG: EXIT references non-EXIT line
! 0010 INPUT #1: DATA$ EXIT 0020
! 0020 PRINT "Got data"          ! no EXIT group on this line

! RIGHT: the referenced line carries an EXIT group
0010 INPUT #1: DATA$ EXIT 0020
0020 EXIT IOERR 0900, EOF 0910
```

**Related errors:** 0211, 0213

---

## Array & Subscript Errors (01xx) {#array-subscript}

### Error 0105 — Variable is Not an Array

**Cause:** A MAT statement is used on a non-array variable (a simple scalar).

**Common scenarios:**
- MAT x where x is a simple string or number
- Attempting array operations on scalars
- Typo in variable name (should be different array)

**Fix:**
1. Ensure variable is DIM'd as an array before using MAT
2. Change MAT statement to work with array variable
3. Declare array with proper DIM statement
4. Check variable name spelling

**Example recovery code:**
```br
! WRONG: MAT on scalar
! LET x = 5
! MAT x(10)  ! x is not an array

! RIGHT: Declare and use array
DIM x(100)  ! Declare as array
MAT x(10)   ! Now can redim

! Also RIGHT:
MAT myarray(50)  ! Create array with MAT
```

**Related errors:** 0106, 0120, 0121

---

### Error 0106 — Array Size Conflict

**Cause:** Array sizes don't match in MAT operations, or array grouping in Input/Print statements uses arrays of different dimensions.

**Common scenarios:**
- MAT x = y but arrays are different sizes
- MAT INPUT grouping with arrays of different sizes
- Dimension mismatch in array assignment

**Fix:**
1. Ensure all arrays in MAT operations have same dimensions
2. For array grouping, match sizes of all arrays
3. Redimension arrays to same size
4. Check dimension counts (1D vs 2D, etc.)

**Example recovery code:**
```br
! WRONG: Different sizes
! DIM a(10), b(20)
! MAT a = b  ! Size mismatch

! RIGHT: Match sizes
DIM a(20), b(20)
MAT a = b

! Also RIGHT: Array grouping
DIM X(5), Y(5), Z(5), FSPEC$(3)*20
INPUT #1, FIELDS MAT FSPEC$: MAT X, MAT Y, MAT Z   ! all the same size
```

**Related errors:** 0105, 0120, 0121, 0123

---

### Error 0108 — Maximum String Length Exceeded

**Cause:** String operation result exceeds BR's maximum string length of 32,767 bytes.

**Common scenarios:**
- String concatenation creates too long result
- Function like RPT$ creates excessive length
- Loop building huge string

**Fix:**
1. Break large string operations into chunks
2. Process strings in segments instead of all at once
3. Limit repetition counts in string functions
4. Use file I/O for very large strings

**Example recovery code:**
```br
! WRONG: Creating huge string
! LET big_string$ = RPT$("=", 36000)  ! Exceeds 32767

! RIGHT: Build in chunks
LET chunk_size = 1000
LET big_string$ = ""
FOR i = 1 TO 33
  LET big_string$ = big_string$ & RPT$("=", chunk_size)
NEXT i
! Or write to file for really large output
```

**Related errors:** 0105, 0106, 0120

---

### Error 0120 — Illegal Array Subscript Element

**Cause:** Array subscript is out of range (negative, zero in BASE 1, or exceeds dimensioned size).

**Common scenarios:**
- Subscript is negative (e.g., x(-1))
- Subscript is 0 when BASE is 1
- Subscript exceeds array dimension
- Subscript is non-integer or invalid

**Fix:**
1. Verify subscript is within array bounds (1 to max or 0 to max-1 depending on BASE)
2. Check subscript calculation for errors
3. Verify array is properly dimensioned for needed size
4. Add bounds checking before array access

**Example recovery code:**
```br
! WRONG: Out-of-bounds subscript
! DIM x(10)
! PRINT x(11)  ! Only goes to 10
! PRINT x(-1)  ! Negative

! RIGHT: Check bounds
DIM x(10)
LET i = 5
IF i >= 1 AND i <= 10 THEN
  PRINT x(i)
ELSE
  PRINT "Index out of bounds"
END IF

! Or redimension larger
DIM x(100)
```

**Related errors:** 0105, 0106, 0121, 0122

---

### Error 0121 — Illegal Reference to an Array

**Cause:** Attempting to use array incorrectly (e.g., treating 2D array as 1D, or missing subscripts).

**Common scenarios:**
- 2D array accessed with 1 subscript: x(5) where should be x(5,3)
- 1D array accessed with 2 subscripts: x(5,3) where should be x(5)
- Array used where scalar expected or vice versa

**Fix:**
1. Verify array dimensions match usage
2. Use correct number of subscripts
3. Check DIM statement vs access patterns
4. Use MAT operations for full array access

**Example recovery code:**
```br
! WRONG: Dimension mismatch
! DIM x(10, 20)  ! 2D array
! PRINT x(5)  ! Wrong - needs 2 subscripts

! RIGHT: Match subscripts to dimensions
DIM x(10, 20)
PRINT x(5, 3)

! 1D example:
DIM y(100)
PRINT y(5)

! For full array operations:
PRINT MAT X   ! prints all of X
```

**Related errors:** 0120, 0122, 0123

---

### Error 0122 — Illegal Array Element

**Cause:** Array element specified is invalid (out of bounds, wrong type, or dimension mismatch).

**Common scenarios:**
- Subscript too large for array
- Negative subscript with BASE=1
- Non-integer subscript
- Reference to undefined array

**Fix:**
1. Check subscript is valid for array dimensions
2. Verify BASE setting (0 or 1)
3. Ensure array is properly DIM'd
4. Add error checking for subscript validity

**Example recovery code:**
```br
! Set BASE if needed
OPTION BASE 0
DIM x(10)  ! Valid indexes: 0-10

! Or BASE 1 (default):
OPTION BASE 1
DIM x(10)  ! Valid indexes: 1-10

! Safe access:
LET index = 5
IF index >= 1 AND index <= 10 THEN
  PRINT x(index)
END IF
```

**Related errors:** 0120, 0121, 0123

---

### Error 0123 — Dimension Conflict

**Cause:** Number of subscripts in array reference doesn't match number of dimensions in DIM statement.

**Common scenarios:**
- DIM x(10) but access x(5,3)
- DIM x(10,20) but access x(5)
- MAT operations with mismatched dimensions
- Passing scalar to function expecting array with specific dims

**Fix:**
1. Count dimensions in DIM and access—must match exactly
2. For 2D array, always use 2 subscripts
3. For 1D array, always use 1 subscript
4. Use DIM statement matching intended usage

**Example recovery code:**
```br
! WRONG: Dimension mismatch
! DIM x(10)      ! 1D
! LET y = x(5,3) ! Accessing as 2D

! RIGHT: Proper dimensions
DIM x(10)
LET y = x(5)     ! 1D access

! Or if 2D needed:
DIM x(10, 20)
LET y = x(5, 3)  ! 2D access
```

**Related errors:** 0105, 0106, 0120, 0121

---

## Syntax & Parsing Errors (10xx) {#syntax-parsing}

### Error 1000 — Unidentified Source Remaining

**Cause:** Invalid or garbage characters in source code, or reserved word used as variable with space in name.

**Common scenarios:**
- Garbage characters in line from file conversion
- Variable name with space: `LET my var = 5`
- Double operator: `if x=1 and and y=2`
- Unprintable characters from copy-paste

**Fix:**
1. Retype the offending line cleanly
2. Use valid variable names without spaces
3. Remove duplicate operators
4. Check for non-printing characters (use LIST to view)

**Example recovery code:**
```br
! WRONG: Space in variable name
! LET my var = 5

! WRONG: Double 'and'
! IF x=1 AND AND y=2 THEN

! RIGHT:
LET myvar = 5
IF x=1 AND y=2 THEN
  PRINT "Both conditions true"
END IF
```

**Related errors:** 1001, 1002, 1006

---

### Error 1001 — Reserved Word

**Cause:** A reserved keyword was used illegally (e.g., as a variable name or label).

**Common scenarios:**
- `LET FOR = 10` (FOR is reserved)
- Variable named IF, THEN, PRINT, etc.
- Label named OPEN, CLOSE, etc.

**Fix:**
1. Don't use reserved words as variable/label names
2. Rename variable to non-reserved name
3. Check BR documentation for reserved word list
4. Append underscore or suffix if needed: `FOR_value`, `if_flag`

**Example recovery code:**
```br
! WRONG: Reserved words as variables
! LET FOR = 10
! LET IF = 5
! LET PRINT = x

! RIGHT: Descriptive non-reserved names
LET for_count = 10
LET if_condition = 5
LET print_flag = x
```

**Related errors:** 1000, 1002, 1005

---

### Error 1002 — Invalid Use of Keyword

**Cause:** A keyword is used in incorrect context or with wrong syntax.

**Common scenarios:**
- `THEN` without `IF`
- `ELSE` without preceding `IF`/`THEN`
- `NEXT` without `FOR`
- Keyword in wrong position

**Fix:**
1. Verify keyword usage matches BR syntax
2. Provide required context (e.g., IF before THEN)
3. Check for proper nesting of control structures
4. Consult BR language reference for syntax

**Example recovery code:**
```br
! WRONG: THEN without IF
! THEN PRINT "Error"

! WRONG: ELSE without IF
! ELSE LET x = 10

! RIGHT: Complete IF structure
IF x > 5 THEN
  PRINT "x is large"
ELSE
  PRINT "x is small"
END IF
```

**Related errors:** 1000, 1001, 1006

---

### Error 1003 — Missing Quote

**Cause:** String literal is missing opening or closing quote, leaving quote unmatched.

**Common scenarios:**
- `PRINT "Hello World` (missing closing quote)
- `PRINT 'Hello World"` (mismatched quote types)
- Quote inside string not escaped

**Fix:**
1. Add matching closing quote
2. Use consistent quote type (typically " for strings)
3. For apostrophes in strings, use different quotes or escape
4. Ensure quotes balance on line

**Example recovery code:**
```br
! WRONG: Missing closing quote
! PRINT "Hello World

! WRONG: Mismatched quotes
! PRINT 'Hello World"

! RIGHT: Balanced quotes
PRINT "Hello World"
PRINT "It's a test"  ! Quote inside string OK with double quotes
PRINT 'It''s OK'     ! doubled quote escapes it inside the same quote type
```

**Related errors:** 1000, 1006, 1020

---

### Error 1005 — Duplicate Label or Function

**Cause:** A label or function name is defined more than once in the program.

**Common scenarios:**
- Two labels with same name
- Function defined twice
- Include files with duplicate definitions
- Copy-paste created duplicate

**Fix:**
1. Remove duplicate definition
2. Rename one to use different label/function name
3. Check for accidental includes of same file twice
4. Consolidate duplicate code into single definition

**Example recovery code:**
```br
! WRONG: Duplicate labels
! process_data:
!   LET x = 5
! process_data:  ! Duplicate!
!   LET y = 10

! RIGHT: Unique labels
process_data:
  LET x = 5
  GOTO calculate
calculate:
  LET y = x + 10
```

**Related errors:** 1001, 1006, 1011

---

### Error 1006 — Syntax Error

**Cause:** General syntax error—invalid combination of keywords/expressions or self-conflicting statement.

**Common scenarios:**
- Invalid statement structure
- Missing required keywords
- Configuration attribute name too long (> 12 chars)
- Punctuation errors

**Fix:**
1. Check statement syntax against BR reference
2. Verify all required keywords present
3. For config: shorten attribute name to ≤12 characters
4. Review line for spelling/punctuation errors

**Example recovery code:**
```br
! WRONG: Invalid syntax
! IF x = 5 PRINT y  ! Missing THEN

! WRONG: Config attribute too long
! ATTRIBUTE my_very_long_attribute_name = 1

! RIGHT: Proper syntax
IF x = 5 THEN PRINT y

! RIGHT: short attribute name, set in BRConfig.sys
! ATTRIBUTE myattr = 1
```

**Related errors:** 1000, 1001, 1002

---

### Error 1011 — Illegal Immediate Statement

**Cause:** Statement that requires a line number (like GOSUB, DEF) was entered without a line number (as immediate/console statement).

**Common scenarios:**
- `GOSUB process` without line number (immediate mode)
- `DEF fnTest(x)` at console
- Entering program statements at immediate prompt
- Missing line number in edit

**Fix:**
1. Add line number to statements requiring them
2. Use immediate mode only for commands (LOAD, SAVE, LIST)
3. Enter program statements with line numbers
4. Use GOTO for immediate jumps, not GOSUB

**Example recovery code:**
```br
! WRONG: GOSUB without line number (at console)
! GOSUB process_data

! RIGHT: With line number
0010 GOSUB process_data
0100 process_data:
0110 LET x = 5
0120 RETURN

! At console, use:
GOTO 10  ! Not GOSUB
```

**Related errors:** 1005, 1012

---

### Error 1012 — Illegal Line Number

**Cause:** Line number is out of valid range (< 1 or > 99999).

**Common scenarios:**
- Line number 0 used
- Line number exceeds 99999
- Line number contains decimal
- Negative line number

**Fix:**
1. Use line numbers between 1 and 99999
2. Renumber program if needed
3. Use integers for line numbers (no decimals)
4. Verify line number format

**Example recovery code:**
```br
! WRONG: Invalid line numbers
! 0 LET x = 5       ! Line 0 not allowed
! 100000 LET y = 10 ! Exceeds 99999
! 10.5 LET z = 15   ! Decimal not allowed

! RIGHT: Valid line numbers
1 LET x = 5
10 LET y = 10
100 LET z = 15
99999 LET w = 20  ! Maximum
```

**Related errors:** 1005, 1011

---

### Error 1020 — Missing Parenthesis

**Cause:** Parentheses are unbalanced—missing opening or closing parenthesis.

**Common scenarios:**
- `LET x = (5 + 3` (missing closing)
- `LET x = 5 + 3)` (extra closing)
- Function call missing closing: `SIN(x`
- Nested parens unmatched

**Fix:**
1. Count opening and closing parentheses—must equal
2. Match each ( with closing )
3. For nested parens, ensure innermost close first
4. Use editor to find unmatched pairs

**Example recovery code:**
```br
! WRONG: Unbalanced parentheses
! LET x = (5 + 3
! LET y = SIN(x)
! LET z = ((a + b) * (c + d)

! RIGHT: Balanced parentheses
LET x = (5 + 3)
LET y = SIN(x)
LET z = ((a + b) * (c + d))
```

**Related errors:** 1003, 1006

---

### Error 1022 — Missing Keyword

**Cause:** A required keyword is missing from a statement.

**Common scenarios:**
- `IF x=6 GOTO 100` (missing THEN)
- `FOR i` (missing = or range)
- Statement missing required keyword

**Fix:**
1. Add missing required keyword
2. Check BR reference for statement syntax
3. Verify statement structure is complete
4. Common missing keywords: THEN, TO, BY, IN

**Example recovery code:**
```br
! WRONG: Missing THEN
! IF x=6 GOTO 1200

! WRONG: Missing TO
! FOR i 1 TO 10

! RIGHT: Complete statements
IF x=6 THEN GOTO 1200
FOR i=1 TO 10
  PRINT i
NEXT i
```

**Related errors:** 1003, 1006, 1024

---

### Error 1024 — Missing Colon

**Cause:** A colon is missing from a statement that requires it (typically file operations).

**Common scenarios:**
- `CLOSE #1` (missing colon)
- `OPEN #1` (missing colon)
- `READ #1` (missing colon)
- Input statement without colon

**Fix:**
1. Add colon at end of file operation statements
2. File operations must end with `:` 
3. Statements like CLOSE, OPEN, READ all need colon

**Example recovery code:**
```br
! WRONG: Missing colon
! OPEN #1 "NAME=data.dat", INTERNAL, INPUT   ! no colon after #1
! READ #1: data
! CLOSE #1

! RIGHT: Colons present
OPEN #1: "NAME=data.dat", INTERNAL, INPUT
READ #1: DATA$ EOF 0900
CLOSE #1:
```

**Related errors:** 1003, 1006, 1020

---

## Critical System Errors (90xx) {#critical-system}

### Error 9000 — Out of Memory

**Cause:** Critical memory exhaustion. BR program or arrays are too large for available system memory.

**Common scenarios:**
- Very large DIM array
- Program file too large (> available memory)
- Multiple large arrays simultaneously
- Memory leak from unclosed files

**Fix:**
1. Reduce array sizes or number of arrays
2. Break program into smaller modules
3. Close files and release memory when done
4. Increase physical RAM if possible
5. Immediate action: LIST program to safe location, then exit and reload

**Example recovery code:**
```br
! PREVENT: Limit array sizes
DIM data(1000)  ! Reasonable size
! NOT: DIM data(1000000)

! Or break into chunks:
LET chunk_size = 10000
FOR START = 1 TO TOTAL STEP CHUNK_SIZE
  OPEN #1: "NAME=data.dat,KFNAME=data.key", INTERNAL, INPUT, KEYED
  READ #1, KEY=STR$(START): RECORD$ NOKEY 9000
  CLOSE #1:
  ! Process chunk
NEXT start

! Emergency: Save to file immediately
EXECUTE "LIST >myprogram.brs"
```

**Related errors:** 9001

---

### Error 9001 — WorkStack is Full

**Cause:** Temporary working data stack exhausted, usually from complex expressions, large string operations, or deeply nested function calls.

**Common scenarios:**
- Very long string concatenation
- Complex nested function calls
- Large parameter passing
- Multiple temporary values on stack

**Fix:**
1. Break complex statements into smaller pieces
2. Reduce nesting depth in function calls
3. Simplify string operations
4. Increase WorkStack in BRConfig.sys: `WorkStack 1000000`
5. Limit number of active function calls

**Example recovery code:**
```br
! WRONG: Complex nested statement causes stack overflow
! LET result = fn1(fn2(fn3(fn4(fn5(x)))))

! RIGHT: Break into steps
LET temp1 = fn5(x)
LET temp2 = fn4(temp1)
LET temp3 = fn3(temp2)
LET temp4 = fn2(temp3)
LET result = fn1(temp4)

! Or adjust BRConfig.sys:
! WorkStack 1000000
```

**Related errors:** 9000

---

## Other Important Errors {#other}

### Error 4197 — NULL in record

**Cause:** Network transmission included NULL bytes in record data, corrupting the data.

**Common scenarios:**
- Network noise or data corruption
- Invalid record structure
- Binary data transmitted as text

**Fix:**
1. Verify network connection stability
2. Check record format for binary data requirements
3. Retry operation
4. Use error correction in transmission

**Related errors:** 4194, 4195, 4196

---

### Error 4167 — File already open

**Cause:** Attempted to open a file that is already open with different access mode or file number.

**Common scenarios:**
- File opened as internal, attempting to open as external
- Opening same file twice with different modes
- Forgetting to close file before reopening

**Fix:**
1. Close file before reopening: `CLOSE #filenumber:`
2. Use same file number and mode if multiple references needed
3. Check for unconditional OPEN outside loops

**Example recovery code:**
```br
! Check if file is open before opening
IF EXISTS("data.dat") = 0 THEN
  OPEN #1: "NAME=data.dat,RECL=128,NEW", INTERNAL, OUTPUT
ELSE
  OPEN #1: "NAME=data.dat", INTERNAL, OUTIN
END IF
! ... use file ...
CLOSE #1:
```

**Related errors:** 4100, 4115, 4152

---

### Error 4175 — Invalid file reservation request

**Cause:** File reservation request contained invalid parameters or file state.

**Common scenarios:**
- Attempting to reserve non-existant file
- Invalid reservation parameters
- File already reserved in conflicting way

**Fix:**
1. Verify file exists before attempting reservation
2. Check reservation parameters
3. Ensure file is properly opened before reserving
4. Check for conflicting reservations

**Example recovery code:**
```br
OPEN #1: "NAME=data.dat", INTERNAL, OUTIN
RESERVE #1:   ! reserve for exclusive access
! ... exclusive operations ...
RELEASE #1:
CLOSE #1:
```

**Related errors:** 4170, 4171, 4174

---

### Error 4230 — Unable to translate

**Cause:** Character set translation failed (encoding mismatch between file and system).

**Common scenarios:**
- ASCII/Unicode mismatch
- Non-ASCII characters in data
- File created on different system with different encoding
- Locale/language data issues

**Fix:**
1. Verify file encoding matches BR configuration
2. Convert file to proper encoding
3. Check BRConfig.sys character set setting
4. Use conversion tools if data is wrong encoding

**Related errors:** 4124, 4125, 4180

---

End of Error Reference. For more information on BR error codes, consult BRC documentation or the original BR! wikibase at https://brulescorp.com/brwiki2/.
