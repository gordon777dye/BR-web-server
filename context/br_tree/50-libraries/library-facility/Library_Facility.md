---
title: Library_Facility
file: Library_Facility.md
category: 50-libraries
subcategory: 50-libraries/library-facility
kind: statement
related: [Business Rules!, user-defined function, DLL, Business Rules! program, OPTION, PROCERR, STATUS, FNsnap tips]
---
`Business Rules!` includes a comprehensive **Library** Facility which enables the main program to access `user-defined function`s from any other  program (or "library") that is separate from the main program. This works similarly to `DLL` (Dynamic Link Libraries). The library may be loaded "resident" (staying loaded regardless of the status of the main program), it may be loaded "present" (remaining active in current memory as long as the main program is active), or it may be loaded "as needed" (loaded when needed to execute a function, then unloaded as soon as the function has been executed).

A library is any `Business Rules! program` that contains library functions. A library must be identified to Business Rules! before a program can execute any of its functions. When a library is identified, Business Rules! adds its name to an internal table of library names. This table identifies the names of all the libraries that should be searched whenever a library function is called that is not yet linked to a library.

Business Rules! places no limits on the number of libraries that may be loaded into memory at one time. Business Rules! provides for maximum memory usage and performance flexibility by allowing libraries to be identified and loaded into memory via three different methods: the resident method, the present method and the as-needed method. See the separate descriptions below for specific information about each type of library linkage.

==Advantages==

Some of the significant advantages of placing user-defined functions in a library rather than keeping them in the main program are as follows:

1. Reduces the size of executables - its no longer necessary to include a standard set of user-defined functions in every program in your application. For some applications (which may include literally hundreds of copies of the exact same code), the potential savings in disk space are tremendous.

2. Saves maintenance time - If you're in the habit of duplicating user-defined functions in every single program that needs them, you know what kind of effort it takes to make (and distribute to your clients) even a one-line change to a function. With Business Rules Library Facility, you make the change only once, and you replace only one program at the client's site.

3. Encourages use of programming standards - The use of library functions for a standard routine is a great way to encourage programming consistency and the setting of standards among your programmers.

This chart provides a Comparison of User-Defined Function Features and the library facility:
<br>`Comparison of User-Defined Function Features`

==Library Function==

A **library function** is a specially defined `user-defined function`; it exists in a program which is frequently separate from the main program, but it may exist in the main program as well.

To qualify as a library function, a user-defined function must simply utilize the DEF statement's LIBRARY keyword. The following is an example of a library function definition:

```business-rules
 52400 DEF LIBRARY FNRESLIB2
 52500 PRINT "This is a library function"
 52600 FNEND
```

Executing a library function is a two-step process. First, the program executing the library function must name the function in an executed LIBRARY statement, which establishes either named or unnamed linkage. Second, the program must call the library function; this may be accomplished using any of the same methods that is available for calling non-library user-defined functions. In the following example, line 01000 uses the LIBRARY statement to establish named linkage between the function FNPRESLIB2 and the library PRESLIB. Line 01100 causes the library PRESLIB to be loaded into present memory (if the library does not already exist in memory), then executes FNPRESLIB2.

 ```business-rules
 01000 LIBRARY "PRESLIB": FNPRESLIB2
 01100 LET FNPRESLIB2
```

===Implementation Considerations===

The Business Rules Library Facility was carefully designed to offer a consistent interface under varying circumstances. Before you begin implementing this capability into your existing applications and ongoing development, BRC recommends that you consider the following:

1.  Should your libraries remain resident?
Business Rules allows libraries to remain resident in memory (providing maximum performance) or to be loaded and released as needed (providing best utilization of memory). Select the method or combination of methods that's best for your applications.

2. Will you use multiple versions of the same function?
Since maintaining more than one version of a function is one method of controlling program options, BR rules for library selection have been established with care. You should carefully review these rules and the ways in which multiple libraries can be of use to you as you plan your implementation.
Until you feel comfortable with the intricacies of the Business Rules Library Facility, it is recommended that you give every library function a unique name (a name that is different from every other library function name).

3. Do your existing functions utilize global program variables?
Unlike local user-defined functions, library functions that exist in a program separate from the main program cannot access main program variables globally. They have to be specifically passed. You should carefully review your usage of global variables before moving local functions into separate libraries.

**Functions work the same irrespective of how a library is loaded. However variables are cleared each time a RELEASE function is called and they are retained across program loads when a library is loaded resident and includes an `OPTION` RETAIN statement.**

===As needed Library===

An as-needed library is loaded and unloaded as needed for execution of specific functions. Loading a library only when it is needed allows the program to conserve memory usage.

Each library has its own global variables that are separate from the main program's variables. Global Variables in an as-needed library are cleared each time a function call to the library is completed and the library is subsequently unloaded from memory.

Programs can indicate that a library is to be loaded as needed by specifying the LIBRARY statement with the RELEASE keyword. This causes Business Rules to establish named linkage between the specified function(s) and the specified library, but it does not actually load the library. (The library is loaded only when one of the as-needed library's functions is actually called.) In the following example, line 00280 establishes linkage between the library ASNLIB and the function FNASNLIB1. Line 00290 causes the following to occur:

1. Load ASNLIB into memory,

2. Execute the function FNASNLIB1,

3. Remove ASNLIB from memory.

 ```business-rules
 00280 LIBRARY RELEASE,"ASNLIB": FNASNLIB1
 00290 LET FNASNLIB1
```

===Linkage Reassignment and Detachment===

Once Business Rules has established linkage between a specific function and a library, the *linkage* remains active until a specific event causes it to become reassigned or detached.

REASSIGNMENT

As noted previously, the LIBRARY statement may be used to establish linkage between a function and the library from which it is to be called. When a named LIBRARY statement is used, linkage is directly established between the named library and the named function(s). 

When an unnamed LIBRARY statement is used, Business Rules searches for the function in a particular search order and assigns linkage to the first library found where the first library statement function is defined. If a library function is defined in the main program an unnamed library statement should be used to establish linkage to it. Otherwise the main program will be loaded twice, once to run as the main program and once as a library. 

Once a function has actually been linked to a library, the only way to subsequently establish linkage between the same function name and a different library is to execute another LIBRARY statement that names the same function and a different library. When all of a present library's linked functions are reassigned; the library is automatically removed from memory. When all of a resident library's linked functions are reassigned; the library may be removed from memory with the CLEAR command.

In the following example, line 01300 uses a named library statement to establish linkage between PRESLIB1 and the function FNASSIGN, and line 01400 actually executes FNASSIGN from the PRESLIB1 library. Line 1500 then re-assigns linkage of FNASSIGN to the library PRESLIB2, and line 1600 executes FNASSIGN from the PRESLIB2 library.

 ```business-rules
 01300 LIBRARY "PRESLIB1": FNASSIGN
 01400 LET FNASSIGN
 01500 LIBRARY "PRESLIB2": FNASSIGN
 01600 LET FNASSIGN
```

DETACHMENT

Regardless of how a library is loaded (resident, present or as needed), all linkages are detached at the time that the main program ends.

There is no other way to completely detach a linkage other than ending the main program.

===Present Library===

A present library is a library that is loaded to remain in memory as long as the main program is active or until all linkages that have been established for the library are reassigned.

Each library has its own global variables that are separate from the main program's variables. Global Variables in a present library are cleared when the main program ends.

A library can be loaded present through three different methods: 

1.The first method is to specify a LIBRARY statement that identifies a library name but no function names. When this method is used, the library is loaded at the time that the LIBRARY statement is executed. For example, when the following statement is executed, the CURLIB library is immediately loaded into memory:

 00210 LIBRARY "CURLIB":

2.The second method of loading a library present is to specify the LIBRARY statement with both a library name and function names. When this method is used, the library is loaded the first time one of the specified functions is called. In the following example, line 00210 establishes linkage between the function FNCURLIB1 and the library CURLIB.

Line 00220 causes the following to occur:

1. The library CURLIB is loaded as a present library,

2. The function FNCURLIB is executed.

```business-rules
 00210 LIBRARY "CURLIB": FNCURLIB1
 00220 LET FNCURLIB1
```

3. The third way to end up with a library loaded present is to execute a CLEAR STATUS command on a library that has already been loaded resident and has attached functions, thus turning it into a present library.

===Resident Library===

A resident library is a library program that is loaded to remain in memory, regardless of the status of the main program. It does not get removed from memory until it is explicitly cleared or until the Business Rules session is terminated. Loading a library resident saves the overhead associated with loading a library each time it is needed.

Each library has its own global variables that are separate from the main program's variables. Business Rules allows resident libraries to handle their own global variables in any of three different ways:

1. Globals may be cleared when the main program ends,

2. Globals may be retained irrespective of the status of the main program, or

3. Globals may be cleared after each function call to the resident library.

The resident status of a resident library can be removed (thus changing the library into a present library) through the use of the CLEAR STATUS command.

A library can be made resident through use of the enhanced LOAD command. However, it is important to understand that functions cannot be executed from any library -even a library that has been loaded into resident memory -until a LIBRARY statement names the functions to be executed and establishes linkage to either a named or unnamed library program - between the function call and the library function definition.

In the following example, line 00130 causes RESLIB to be loaded into memory as a resident library. Line 00140 establishes named linkage between the function FNRESLIB1 and the RESLIB library. Line 00150 executes the function FNRESLIB1.

```business-rules
 00130 EXECUTE "LOAD RESLIB,RESIDENT"
 00140 LIBRARY "RESLIB": FNRESLIB1
 00150 LET FNRESLIB1
```

==Variable Usage==

Before you start placing all your existing user-defined functions into separate libraries, you should fully understand how library functions deal with global variables.

This section will focus on three main points:

1. How a main program and a library function can communicate,

2. How functions within a library communicate, and,

3. When global variables are cleared for a library program.

===How main programs and library functions communicate===

Business Rules programs communicate with regular user-defined functions via passed parameters, the returned function value, and global variables (variables not passed in the parameter list). All of these same communication options are available for library functions that are defined within the main program. However, only the first two options are available to library functions that are separate from the main program. These functions cannot access the main program's global variables because global variables are only available to routines and functions which are defined within the same program. As a result, user-defined functions that are held within a main program may need to be reviewed for their global variable usage before they are changed to library functions and placed into a separate library program.

If a program needs to communicate a large number of standard values to a library function, consider using an initialization function to pass the values to the library program. Use the initialization function to assign the passed values to global variables in the library so they will be available to all functions in the library.

===How functions within a library communicate===
Within each library, all functions share variables which are global to that library, and library global variables retain their values between function calls unless the RELEASE keyword is used on the LIBRARY statement, which is allowed both for resident and as-needed libraries. When RELEASE is used global variables are cleared after each function call.

===When Global Variables are Cleared===
This section restates the previous paragraph in a more structured style.

**Main program library functions** - For library functions that are defined within the main program, globals are cleared when a the main program ends.

**Resident library** - When a library is loaded resident, global variables may be cleared in any of three ways:
{|
|-valign="top"
|width="10%"|**Default**||By default, Business Rules clears a resident library's global variables when the main program ends.
|-valign="top"
|width="10%"|**Retain**||When the OPTION RETAIN statement is used in a resident library program, the library retains its global variables irrespective of when the main program ends. The only way to clear globals when this statement is used is to CLEAR the library from memory or to reload it with the LOAD RESIDENT command. Remember that the library must be loaded resident for the OPTION RETAIN statement to have any affect.
|-valign="top"
|width="10%"|**Release**||When a resident library is named on a LIBRARY statement with the RELEASE keyword, the library's global variables are cleared after each function call to the library. This functionality is provided so the decision to load a library resident or as-needed can be made on a customer-by-customer basis; the program code remains the same (because Business Rules handles the variables the same) regardless of whether the library is loaded resident or as-needed.
|-valign="top"
|}
<br>
**As-Needed Library** - When a non-resident library program is linked by a Library statement with the RELEASE keyword, variables (and the library code space) are cleared when each call to the library ends, provided another function call to that library is not active.
<br>
<br>
The following table summarizes the information presented above. The keywords used in the "When globals are cleared" column are the same keywords used in the STATUS LIBRARY display (second column from right) to identify when variables for the listed library will be cleared. (See the "STATUS" command in the Commands chapter for complete information about this display.) The keywords are defined as follows:

| Keyword | When globals are cleared |
|---|---|
| **RUN** | Globals are cleared when new main program is run. |
| **END** | Globals are cleared when main program ends. |
| **EXIT** | Globals are cleared after each function call to the library. |
| **RETAIN** | Globals are retained, irrespective of main program status. |

| Library description | When globals are cleared |
|---|---|
| Main program | RUN |
| Resident library — Default | END |
| Resident library — RELEASE is specified on LIBRARY statement | EXIT |
| Resident library — OPTION RETAIN statement is in library program | RETAIN |
| Present library | END |
| As-needed library | EXIT |

==Additional Processing Considerations==

Alternate libraries can be interrogated with function key 9 during a program pause.

Active procedures (scripts) and opened files are not affected by library function calls, unless the library issues commands that specifically affect them. This includes `PROCERR` settings.

A nice aspect of library functions is the capability of a program to call a library function, which, in turn, calls a function in the main program. This supports the concept of manager functions that provide overall functionality while the main program fills in the details that may vary from program to program.

Main program functions can be called by libraries. These can even displace functions of the same name within the libraries.  The way to permit library routines to be overridden (functionally replaced) by corresponding functions in the main program is to have the library include those functions in a LIBRARY statement that doesn't specify a library name. The library will then attach the library function in the main program instead of its own, even if a copy of the function exists in the library, because the main program is always regarded as having been loaded last for purposes of resolving unnamed library searches.

Note that if a LIBRARY statement within a resident library creates linkage and then the main program ends, the linkage is broken and that LIBRARY statement must be re-executed before the function can be called again by the resident library.

With respect to speed, parameters should be passed by reference (using the & in front of the variable name in the DEF statement) wherever possible. This avoids needless allocation of memory and copying of data, which is a significant part of function call processing.

If you want to avoid the processing time required to load a library until a function within it is called, simply name the library and function on the same LIBRARY statement. However, if you want to be sure that the named functions exist within the library, first load the library with a statement that contains no function names. This will cause the library to be loaded at the time the LIBRARY statement is executed. Then when the LIBRARY statement containing the function list is encountered, the library (which is now in memory) will be checked for the presence of each function.

It should be emphasized that executing a LOAD command does not establish function linkage. A subsequent LIBRARY statement must be processed to establish such linkage.

When replacing a resident library with a different library, the first library should be cleared with a CLEAR command to free its memory before loading the second library.

Updating a library (with the REPLACE command) has no effect on active application environments until the library is (re)loaded.<br>
If a LIBRARY statement contains the name of a local function that is defined as non-library, a "duplicate function definition" error is generated when the program is run or saved.

If a LIBRARY statement refers to a library without RELEASE and another statement refers to the same program with RELEASE, an error is generated. Also RELEASE cannot be specified for any library with the OPTION RETAIN statement.

If a function in the main program, defined with the LIBRARY keyword, is called from within a library (a condition referred to as library loopback), the main program uses fresh stack space. Therefore, pre-existing for-next processes are not recognized until the library returns normally to the main program.

Loopback: A library function can call back into the **main program** — link it with an
**unnamed** `LIBRARY` statement (the main program is always treated as "loaded last", so it will 
find the function quickly). A loopback call uses  **fresh stack space** (the caller's 
original pending loops aren't seen until the library returns).  CAUTION: If you name the main (current) 
program  in a LIBRARY statement a second copy of the main program will be initiated with all variables 
cleared  and it's variables will remain separate from the calling instance. This could be very confusing.

Memory fragmentation can occur if a library is loaded resident while other programs are in memory. To avoid this problem, load your resident libraries before running application programs.

===Editing Active Libraries===

The LIST command displays the currently active program. This means if a program is interrupted while a library call is being processed, the LIST command will show the library program statements. If desired, use F9 to select another loaded program such as the main program, and then issue another LIST command or inspect variables in that module. 

It is important to note that the only way to *save changes* made to a running library program is to list the library to a file and reload it from source later on. Because of this, it can be desirable to develop a new library function first within the main program. Then once you've completed the testing and debugging process, you can move it to a separate library and test it there.

There is, however, another approach that can work. If you load the library program in a separate session, solely for the purpose of changing the stored program, and then test your changes by saving them in the extra session and restarting the main program, this can be a convenient way to change libraries. It only takes a few seconds to CLEAR PROC and rerun the main program. And the DEBUG breakpoints set in the library remain in effect until specifically cleared.

===Linkage===

When used to its full potential, the Business Rules Library Facility enables multiple versions of the same function (with the same name) to exist in different libraries, all of which may be loaded into memory. The actual library that is used for a specific function call is determined by the most recently executed LIBRARY statement establishing linkage to the function.

The LIBRARY statement may be used to establish linkage in one of two ways: the named method, or the unnamed method. These methods are defined as follows:

;Named
The LIBRARY statement explicitly links one or more specific functions to a specific library. This is the most efficient and foolproof method for assuring that the library function you wish to use gets executed.

In the following example, the functions FNRESLIB1 through FNRESLIB5 are explicitly linked to the library MAIN. When any of these functions are called, Business Rules will automatically execute them from the MAIN library. (Regardless of whether or not any other library currently in memory also contains functions by the same name.)

 50300 LIBRARY "MAIN":FNRESLIB1, FNRESLIB2, FNRESLIB3, FNRESLIB4, FNRESLIB5

UNNAMED LIBRARY FUNCTIONS

The LIBRARY statement names the desired library functions and leaves it to Business Rules to determine which of the currently identified libraries they should be linked to. This determination is made according to the pre-set guidelines described below. The unnamed method of linkage is useful when you have several libraries loaded and are not concerned with which library contains the desired function. An unnamed library statement **must** be used to establish linkage to perform callbacks to the main program for accessing or changing data in the main program. 

When the unnamed method is used, Business Rules first searches the main program, then each library that is currently loaded (in last loaded, first searched order) for each function listed on the LIBRARY statement. Once Business Rules finds the function, the linkage is established, and future calls to the same function will continue to utilize the same linkage until it is changed. Note that Business Rules does not search as-needed (RELEASE) libraries when using the unnamed method of establishing linkage. Also, it is important to understand that it can take significantly longer to establish linkage using the unnamed method of linkage than with the named method of linkage.

In the following example, line 01000 loads RESLIB as a resident library. Lines 01100 and 01200 load PRESLIB1 and PRESLIB2 as present libraries, and line 01300 names ASNLIB as an as-needed library. The LIBRARY statement on line 01400 establishes unnamed linkage for the function FNALIBI. When line 01500 is executed, Business Rules searches the currently loaded programs in the following order for FNALIBI: Main program, PRESLI2, PRESLIB1, RESLIB. Note that ASNLIB is not considered for this search because it is not currently loaded in memory.

```business-rules
 01000 EXECUTE "LOAD RESLIB,RESIDENT"
 01100 LIBRARY "PRESLIB1":
 01200 LIBRARY "PRESLIB2":
 01300 LIBRARY RELEASE,"ASNLIB": FNASNLIB1
 01400 LIBRARY : FNALIBI
 01500 LET FNALIBI
```

===Status Library===

Business Rules STATUS LIBRARY command may be used to display a table that identifies all the linkages that are currently active for each library. See the `STATUS` command for more information. For information about releasing and/or changing library linkages, see the term `#Linkage Reassignment and Detachment` earlier on this page.

==Sample Program==

The following two sample sections of code are, for convenience purposes, labeled "Main Program" and "Library". The Main Program references two functions (FNSEND and FNRECEIVE), which are located in the Library. Line 50 of the Main Program establishes the function linkage; line 70 prompts for a message; and line 110 calls the FNSEND function, which is defined on line 30 of the Library.

FNSEND opens a serial communications port and sends the operator-specified message to the terminal connected to the port. The Main Program then calls the FNRECEIVE function, which is defined on line 80 of the Library. This function waits up to 15 seconds for a response (by default), returns the response in the parameter, and returns its length as a function value. Finally, the Main Program prints the response or the message "No Response".

MAIN PROGRAM

```business-rules
 00010 ! MAIN PROGRAM
 00020 !
 00030 DIM MESG$*60, RESPONSE$*120
 00040 !
 00050 LIBRARY "TOOLS\LIB1": FNSEND, FNRECEIVE
 00060 !
 00070 PRINT "Specify Message"
 00080 LINPUT MESG$
 00090 IF LEN(MESG$) = 0 THEN STOP
 00100 !
 00110 LET FNSEND(MESG$)
 00120 !
 00130 IF FNRECEIVE(RESPONSE$) THEN !:PRINT RESPONSE$ !:ELSE !:PRINT "No Response"
 00140 GOTO 70

 Library:
 00010 ! LIB1
 00020 !
 00030 DEF LIBRARY, FNSEND(MESSAGE$*60)
 00040  IF NOT COMM_OPENED THEN !:OPEN #40: "NAME=COM2:, FORMAT=ASYNC,BAUD=2400",DISPLAY, OUTIN !:COMM_OPENED = 1
 00050  PRINT #40: MESSAGE$
 00060 FNEND
 00070 !
 00080 DEF LIBRARY FNRECEIVE(&RESP$)
 00090  LINPUT #40: RESP$ IOERR 100
 00100  FNRECEIVE = LEN(RESP$)
 00110 FNEND
```

===Turning an Existing Program into a Callable Library Function===

Business Rules Library Facility makes it easy to turn an entire program into a library function that a user can invoke at will from within another program. For example, consider a standard application that includes both a client maintenance (MNTCUST) program and an order entry program (ORDERS). You would like to give users the ability to invoke the client maintenance program from within the order entry program whenever they press F4. The steps required to do this are as follows:

**1. Modify MNTCUST** by placing the entire original program into a user-defined library function and adding a few lines that cause the program to call itself as a library function whenever it is executed as the main program.

   a. Move any user-defined functions that exist within the main body of the program to the end of the program (or to a separate library).

   b. Add lines such as the following to the top of the program. Line 00030 should be replaced with the normal MNTCUST CHAIN statement to the menu.

   ```business-rules
    00010 LIBRARY "MNTCUST" : FNMNTCUST
    00020 LET FNMNTCUST
    00030 CHAIN -menu-
    00040 DEF LIBRARY FNMNTCUST
   ```

   c. Add the following line to the end of the main body of the program (prior to any user-defined function definitions):

   ```business-rules
    80000 FNEND
   ```

   d. Change the normal main body CHAIN statement to GOTO the FNEND statement added in step c.

**2. Modify ORDERS** as follows:

   a. Change the screen to include a label that identifies the operation of the F4 key.

   b. Change the program to check for pressing of the F4 key.

   c. Change the program to execute the following whenever F4 is pressed. Note that the LIBRARY statement in line 50000 utilizes the "RELEASE" keyword: this causes the MNTCUST library to be loaded into memory on an as-needed basis only. Thus the only time that the on-the-fly client maintenance feature uses system resources is when the user actually requests the capability by pressing F4.

   ```business-rules
    50000 LIBRARY RELEASE, NOFILES, "MNTCUST" :FNMNTCUST
    50010 LET FNMNTCUST
   ```

The NOFILES specification (BR release 4.3 and later) lets the library have its own independent file system. That way there is no concern for file number conflicts. The MNTCUST program will perform file IO with the same file sharing rules it would have, had it been executed on a separate workstation.

Files opened NOCLOSE by NOFILES libraries are opened as normal files. In such cases the NOCLOSE parameter is ignored.

====Other====

See `FNsnap tips` for accessing Fnsnap functions as libraries.

==Error Processing==

If an error is not trapped in a library function, the error is reported back to the calling program. When that happens the following system variables are set:

| Variable | Value |
|---|---|
| **LINE** | The line number of the erroneous statement. |
| **ERR** | The error number that occurred in the library function. |
| **CNT** | The appropriate value as if the error occurred in the calling program. |

If an error occurs while attempting to match parameters between a function call and the function definition, CNT is set to the number of parameters successfully matched.
