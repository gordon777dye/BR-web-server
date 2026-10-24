---
title: Chapter_18
file: Chapter_18.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [Answers 18.1, Answers 18.2, Reserved Words]
---
===Error handling and recovery===
The theme of this chapter concerns some very good news in the face of some unavoidable bad news. The topic is error handling or (stated with a bit more optimism) error recovery. This chapter will seek to answer the question, “Can you write a beepless or errorless program?”

Business Rules! was built around a fundamental programming truth: operators will make mistakes. This is the unavoidable. An old programming proverb has become so common that it is sometimes referred to by its abbreviation GIGO: garbage in, garbage out! When a program is fed garbage for input, its output will not be worth much.

It is mentally challenging to write a program that works correctly when it gets good data. Bad data can easily produce all kinds of problems -- many ending up with the computer beeping and the word ERROR in the far left of the status line. After all your hard work writing a program, and testing it with good data, is there any way to avoid the seemingly inevitable disaster of turning it over to people who will make mistakes when they use it?

The good news is that Business Rules! has many features designed to help when programs get bad data and other types of errors occur. This very complete set of techniques allows programmers to anticipate a wide variety of error conditions and to provide error recovery routines within the program.

Back in Chapter 3, you learned how to add CONV line-ref on the end of an INPUT statement to prevent a program from beeping and going into error mode when an operator entered letters instead of numbers for a numeric variable. This chapter will review and greatly extend those techniques.

When you finish this chapter, you will be able to:

*Understand what happens externally and inside Business Rules! when an error occurs.
*Use the system variables ERR, LINE, CNT and FILENUM to help print messages and recover from error conditions.
*Use RETRY and CONTINUE statements to transfer control at the end of an error processing routine.
*Use the EXIT and ON statements for more general levels of error processing.
*Understand default conditions for error processing and how to change them.
*Use several new error conditions including PAGEOFLOW.
*Use function keys to interrupt a program.

===18.1 A review of what happens and an example of how to avoid it===
As you well know by now, there are many different errors that can occur with programs. One major way to separate different types of errors is based on when the error occurs. This chapter will deal only with errors that occur during the execution of a program (as opposed to those that occur when the program is being typed in); errors that occur during the execution of a program are called execution errors.

What types of things can go wrong after a program has been running correctly for a while? Lots of things. Operators make errors. They accidentally enter letters where the program requires numbers. They choose the right options, but in the wrong sequence. They interrupt programs at the wrong time. Entire files appear and disappear at inappropriate times. Certain records within a file vanish. In short, operators can do just about anything.

Would you like to goofproof your programs from these types of errors? On the one hand, it’s easy; on the other hand, it’s not. The hard part is that you have to anticipate things that can go wrong at various places in the program. After you have anticipated them, Business Rules! has an easy-to-use set of tools to help you program messages and various types of recoveries.

What happens when an error occurs? The answer involves both things that happen externally (that you can see or hear) and internally.
Externally, five things happen simultaneously:

1. The Computer beeps. <br>
2. ERROR appears in the far left corner of the status line.  <br>
3. A four-digit error code appears in the middle of the status line. <br>
4. The line number of the error causing statement is displayed in the status line just to the right of the four digit error code. <br>
5. The program is temporarily suspended and waits for a command from the operator. <br>

Inside Business Rules!, not seen by the operator, five additional things are going on:

1. The four-digit error code is automatically assigned to the system variable ERR. <br>
2. The system variable LINE is automatically set to the line number containing the statement causing the error. <br>
3. In case the error-causing statement occurred on a line with several statements, Business Rules! keeps an additional internal notation of which specific statement caused the error in that line. This information is used for error recovery routines which try to retry the statement or continue with the next statement afterward. <br>
4. If the error-causing statement is an input/output statement, the system variable CNT is automatically set to the number of items in the input/output lists that have been processed successfully. <br>
5. If the error-causing statement is an input/output statement, the system variable FILENUM is automatically set to the file number form the statement causing the most recent error. -- Also file (filenum) gives file status. <br>

CNT and FILENUM are only set when the error is an input/output error. Their values can be misleading. Suppose the first error was an I/O error which set both variables; then the second error was not an I/O error. CNT and FILENUM would have old values in them from the first error, but ERR and LINE would have information about the most recent error.

CNT is used in other situations besides error processing. Any input/output statement, with or without errors, will reset CNT. In fact, a PRINT statement in your error processing routine will also reset CNT and you will lose the value from the original error-causing statement. For example, line 170 in the following program will always print “Bad field was field number 3” because line 160 (which is processed after the error) always prints 2 fields successfully.

 00100 PRINT USING 130: “1”,2,3 CONV CONV
 00110 PRINT USING 130: 1,”2”,3 CONV CONV
 00120 PRINT USING 130: 1,2,”3” CONV CONV
 00130 FORM #*N 2
 00140 STOP
 00150 CONV: !
 00160 PRINT “Letters in numeric field in line”;LINE;
 00170 PRINT “Bad field was field number”;CNT+1
 00180 CONTINUE

To make this routine function correctly, make these two changes:

 00150 CONV: LET TEMPCNT=CNT
 00170 PRINT “Bad field was field number”;TEMPCNT+1

Notice that line 170 uses CNT+1 (or TEMPCNT+1). CNT is set to the last successfully processed field. To get the first unsuccessfully processed field, simply add 1.

Now let’s review an example from way back in Chapter 3.

 10 PRINT “Total number of miles?”
 20 INPUT M CONV 80
 30 PRINT “Number of gallons?”
 40 INPUT G CONV 80
 50 MPG=M/G
 60 PRINT “Miles Per Gallon =”;MPG
 70 STOP
 80 PRINT “Please enter numbers, not letters.”
 90 RETRY

In line 20, if someone entered letters for the numeric variable M, a 0726 error code would be generated. On the end of line 20, CONV is an example of an error condition; when error conditions appear at the end of a statement, they must always be followed immediately by a line-ref. Remember, a line-ref can be either a line number or a line label.

When someone enters letters instead of numbers in line 20, the error condition CONV at the end of line 20 catches or traps the error and the program branches to line 60 where a message is printed. Line 90 contains a special statement used only with error handling which causes Business Rules! to try again to execute the INPUT statement in line 20.

A conversion error line 40 would produce similar results, except that the RETRY statement would send the program back to line 40. Let’s end this section with a closer look at the two special statements used for ending error handling routines.

RETRY and CONTINUE statements are provided for transferring control at the end of an error processing section of a program. Their function is analogous to the RETURN statement at the end of a subroutine. Any error condition will set the statement to which control will be transferred. More than one statement on a line is no problem.

Here is the difference between these two. The RETRY statement transfers control back to re-execute the statement which caused the most recent error. The CONTINUE statement transfers control to the first executable statement after the one causing the most recent error. With the CONTINUE statement, a program can skip the trouble-making statement. Also, CONTINUE is usually used with “unharmful” errors such as PAGEOFLOW.

====Quick Quiz 18.1====
True or False:

1. Error handling techniques described in this chapter can be used to recover from syntax errors as lines are being entered.

2. When an execution error occurs, a four-digit error code is displayed in the status line; also, the system variable LINE is set to the same error code.

3. When an execution error occurs, information about which statement caused the error is saved for possible use with the RETRY or CONTINUE statements

4. Errorcodes can be 3 and 4 digits long.

`Answers 18.1` <br>

===18.2 The EXIT statement and many error conditions===
Business Rules! provides four levels for anticipating or trapping execution errors. The first two levels apply to individual statements, and will be called statement coding. The other two levels apply to blocks or groups of statements, perhaps as big as an entire program, and will be called block coding.

You have already seen the first level of statement coding in the examples in the first section with CONV on the end of a statement. The purpose of this section is to show you how to use the EXIT statement and the special error condition EXIT as another method of statement coding of error conditions.

Here is the complete list of error conditions.

;CONV
Indicates one of four conversion errors: <br>
#A numeric input field contains non-numeric characters.
#The number is too big for the field.
#The I/O list item is numeric where the FORM data conversion specifies a string, or vice versa.
#A negative value is being input or output, but the PIC data conversion format does not specify a sign (negative symbol).

;DUPREC
Indicates an attempt to WRITE to and existing record (you must use REWRITE).

;EOF
Indicates that there are no more records in the file (for a READ or INPUT statement), or that there is not enough file space (for a PRINT or WRITE statement).

;EXIT
Traps all errors not previously trapped by an error condition; the specified line-ref refers to an EXIT statement which is coded elsewhere in the program.

;IOERR
Covers all I/O statement errors not previously trapped by an error condition.

;NOKEY
Indicates that the file does not contain the specified key.

;NONE
Indicates that there is no matching line-ref for the numeric expression in an ON GOSUB or ON GOTO statement.

;NOREC
Indicates one of three errors:
#The specified record has been deleted.
#The number is at least two greater than the last record number of the field (for WRITE).
#The number is greater than the last record number in the file (for READ).

;OFLOW
This System/23 compatibility feature indicates that the system computed a number having an absolute value greater than the largest numeric value of the system.

;PAGEOFLOW
Indicates that the number of lines printed since the last page feed equals or exceeds the page length specified in the OPEN statement. (Default page length = 60.)

;SOFLOW
Indicates one of two errors:
# The number of input data characters is greater than the defined length of the string variable for assignment, READ, REREAD, or INPUT.
# The length of the output I/O list string expression is greater than the field width defined in the specification.

;HELP
Where to go if the help key is pressed.

;ZDIV
Indicates that division by zero was attempted.

Can you code more than one error condition on a statement? Sure! In the program below, both CONV and SOFLOW are coded on all PRINT statements.

 00100 LET A$=”123456”
 00110 PRINT USING 130: “1”,2 CONV CONV,SOFLOW SOFLOW
 00120 PRINT USING 130: 1,A$ CONV CONV,SOFLOW SOFLOW
 00130 FORM N 2,X 2,C 2
 00140 STOP
 00150 !
 00160 CONV: LET TEMPCNT=CNT
 00170 PRINT “Letters in numeric field in line”;LINE;
 00180 PRINT “Bad field was field number”;TEMPCNT+1
 00190 CONTINUE ! Pick up with next statement
 00200 !
 00210 SOFLOW: PRINT “SOFLOW in line”;LINE;
 00220 PRINT “-- A$ truncated -- lost from end was --“;A$(3:LEN(A$))
 00230 LET A$=A$(1:2)
 00240 RETRY ! go back and try again

Line 110 produces a CONV error on the first field; it is processed like the example above. The error processing routine is found in lines 160 to 190 and ends with a CONTINUE statement that sends control to line 120. Why 120? Because it is the next executable statement after the error causing statement.

Line 120 produces a SOFLOW error on the second field because the output string of length (6) overflows the conversion specification which allows for a length of 2. Error handling traps this error before the system can beep, and then branches to the SOFLOW label in line 210. Lines 210 and 220 print a message that characters “3456” were truncated from the end of A$.

At the end of line 220, notice the substring of A$ that starts with position 3 and ends in the last position in A$, which is taken from the system function LEN(A$). Line 230 uses the substring operation again to reset A$ to be equal to just the first two characters. Because the string is now short enough to avoid the overflow, line 240 sends the program back to retry line 120, which will now succeed. You may want to type in this program and RUN STEP to follow the order of execution.

The above program demonstrates that you can -- and sometimes should -- code more than one error condition on one statement. However, if two or more error conditions were added to every PRINT statement, it could get tedious to type all that stuff in. Are you ready for a short-cut?

The EXIT statement provides a short-cut method of coding several pairs of “error-condition line-ref” specifications. For example, you can code the following EXIT statement only once in the program:

 50 EXIT CONV CONV, SOFLOW SOFLOW, ZDIV ZDIV

Then on each PRINT statement, you would only have to say:

 110 PRINT USING 130: “1”,2 EXIT 50

Then, if any error occurred in line 100, the EXIT 50 would cause Business Rules! to examine all the error conditions in line 50 to see if the type of error is covered. A CONV error is covered and would cause a transfer from 110 to the line label CONV.

If the error that occurred in line 110 was not one of the three in line 50, the system would beep.

EXIT can be mixed in with any other error condition, but processing will be from left to right in the list of error conditions.

 110 PRINT USING 130: “1”,2 CONV 300,EXIT 50
 120 PRINT USING 130” “1”,2 EXIT 50,CONV 300

Lines 110 and 120 mix EXIT and CONV. If a CONV error occurred in line 110, the program would transfer to line 300, because that’s the first CONV it finds in examining all the error conditions from left to right. However, if a CONV error occurred in line 120, the program would transfer to the CONV line label, because that’s what would be found first when it examined the EXIT statement. So, in line 120, the CONV 300 would never be used. The main purpose for using the EXIT statement is to set up one or more general groups of error conditions. If you want to code an exception for a particular statement (like CONV in line 110 above), remember that the list at the end of the statement will be processed from left to right.

Here is a summary of the rules for using the EXIT statement. The EXIT error condition must be followed immediately by a “line-ref” which must refer to an EXIT statement coded elsewhere in the program. EXIT statements are non-executable and may be placed anywhere in the program without changing the order of statement execution. There can be more than one EXIT statement in a program. The EXIT error condition is treated as a special error condition (special because a group of several error conditions can be coded together). The purpose of this type of coding would be to set up one or more groups of general error conditions so that only the exceptions (and the EXIT line-ref) need to be coded on specified lines. If EXIT and other error conditions are coded on the same line, EXIT should be coded last. For a specific code to override the general provisions of the EXIT group, the specifics must occur first. It is permissible (although confusing) to have more than one EXIT error condition coded at the end of a statement line. They will be evaluated in the order they occur.

 00002 ON ZDIV IGNORE
 00003 ON IOERR SYSTEM

With line 2 above, and no additional error trapping of ZDIV, any division by zero error would be ignored by the system. What exactly does it mean to be ignored? The error-causing statement is skipped. The system variables ERR and LINE are not set. The program continues with the next statement after the one which caused the error.

Probably, you would not want to code IGNORE for an entire program. It would be better to only code it for a few statements, than reinstate normal error processing. How do you cancel the effects of an IGNORE? With another ON statement; either of the following two statements would terminate the effects of line 2 above.

 00110 ON ZDIV GOTO 82000
 00120 ON ZDIV SYSTEM

There is one exception to the rule that the error-causing statement is skipped when IGNORE is in effect. The exception occurs with SOFLOW errors in statements like the following:

 00570 A$=B$ & C$

Suppose none of these strings have been dimensioned and their default maximum length is 18. Also, suppose that the length of B$ is 12 and the length of C$ is 15. Because their combined length of 27 is greater than the maximum length of A$, SOFLOW will occur. When IGNORE is in effect, the overflowing string will be truncated. This means A$ will contain the first 18 characters.

Using IGNORE with any other error conditions would cause the statement to be skipped and no assignment made. For example:

 1020 LET X = 12: LET A = 15: LET N = 0
 1030 ON ZDIV IGNORE
 1040 LET X = A/N
 1050 PRINT X

What number will be printed in line 1050; Maybe 15, or 0, or 12? Type in this example and see!

Now let’s discuss the keyword SYSTEM as used in ON statements. To reverse the effect of coding IGNORE, you can code SYSTEM instead.

 1030 ON ZDIV SYSTEM

This changes the error processing features initiated in line 1030 above.

The keyword SYSTEM directs Business Rules! to reinstate normal error processing -- except when ON ERROR is used as a fourth level of error processing which will be discussed in the next section.

When the keyword SYSTEM is in effect, the computer beeps, the program is suspended and awaits a command, ERROR is displayed in the far left of the status line, the values for ERR and LINE are displayed in the middle of the status line.

So far, you have learned about two main levels of error trapping. You may be wondering what happens if both methods are used, which one will have priority?

The answer is that Business Rules! will look first at the end of the error-causing statement. Whatever is coded on the end of the statement will be used to process the error before Business Rules! looks to see if there are any ON error statements that might apply. Since error conditions on the end of a statement are processed before ON statements, this makes it easy for you to use ON statements for “the general rule” in error handling, and also use error conditions (including EXIT) on the end of the statement to handle the “exceptions”
 
===Function keys and the ON error statement===
The ON error statement also can be used for processing function keys when Business Rules! is in RUN mode. Business Rules! supports up to 20 function keys, F1, F2, F3, and so on up to F20. With the KEYBOARD statement, you may also be able to make shift-F1 to shift-F10 into F11 to F20.

In the ON error statement, each function key must be set up with a separate statement. Like other error conditions, F1-F20 can be used with GOTO, IGNORE, or SYSTEM.

 100 ON FKEY 2 GOTO 90000
 200 ON FKEY 10 IGNORE
 300 ON FKEY NUMBER SYSTEM

Line 100 instructs Business Rules! to branch to line 90000 if F2 is ever pressed. Line 200 illustrates the use of IGNORE and that numeric expressions can be used after the keyword FKEY. Line 300 shows the use of the keyword SYSTEM and that a variable can be used as the numeric expression after the FKEY.

Why would someone want to use a function key when a program is running? One possibility is to allow the operator to stop a long report and return to the menu with a single keystroke if the computer is suddenly needed for something else. In the following example, the operator could just push F7 instead of waiting for the report to finish or using CTRL-A plus CLEAR PROC and CHDIR plus LOAD MENU plus RUN.

 00001 ON FKEY 7 GOTO 99990
 o
 o
 o
 99990 CHAIN “MENU”

Another possible use of function keys during a program is to allow the operator to “gracefully” interrupt a report, perhaps to finish printing all of the current record or page before terminating.

Remember ON FKEY statements apply only to function keys pressed when the program is in RUN mode. What happens if a function key is pressed during INPUT mode, that is during an input operation from the keyboard? The answer is that no interruption occurs. Instead of ON FKEY processing, the system CMDKEY variable is set and pressing the Enter key is simulated.

What happens if you don’t code any ON FKEY statements, but someone accidentally presses a function key while your program is running? Well, not to worry! The defaults for F1-F10 are IGNORE. When a new program is started, it is as if Business Rules! had the following statements execute for you before the first statement of your program is executed.

 00001 FOR I = 1 TO 10
 00002 ON FKEY I IGNORE
 00003 NEXT I

A good way to think about ON error statement processing is that Business Rules! maintains an ON error table. For each error condition in the table, there is an entry of either SYSTEM, IGNORE, or GOTO line-ref.

The initial or default entry in the table is SYSTEM for all entries except PAGEOFLOW and the FKEY entries which are preset to IGNORE.

====Quick Quiz 18.2====
True or False:

1. Error handling techniques described in this chapter can be used to recover from syntax errors as lines are being entered.

2. When an execution error occurs, a four-digit error code is displayed in the status line; also, the system variable LINE is set to the same error code.

3. When an execution error occurs, the system variables ERR, LINE and CNT are always set.

4. When an execution error occurs, information about which statement caused they error is saved for possible use with the RETRY or CONTINUE statements.

`Answers 18.2` <br>

===18.3 The ON error statement and the final level of appeal===
This section will introduce you to the final level of error processing. So far, you have learned about three levels. If an IOERR occurs, Business Rules! will first look for this error condition on the end of the statement, exit statement, only if IOERR is not found on the error-causing statement will Business Rules! look for an ON IOERR statement.

But what if none of these three levels have been coded? Is there anything else that can help us avoid one of those dreaded beeps? Yes, there is one last level of error processing that you can appeal to. This final level also uses the ON error statement. This third level uses the keyword ERROR in the position of a specific error condition. It allows the same three options as the other error conditions.

 00100 ON ERROR GOTO 90000
 00200 ON ERROR IGNORE
 00300 ON ERROR SYSTEM

Before Business Rules! beeps when an error occurs, it checks to be sure that the following three conditions have been met:

# There is no applicable error condition coded at the end of the error-causing statement -- including any EXIT error conditions; remember, all coding on the end of a statement is examined from left to right.
# If there is an applicable ON error statement for these specific error conditions, it must be set to SYSTEM by default or by the programmer.
# The processing for ON ERROR SYSTEM must be in effect either by default or set by the programmer.

Here is an example of an attempt at an all-purpose error handling routine. Of course, it would take a very long routine to really be able to handle all errors -- especially for all possible operators. This routine could be useful to programmers to display crucial information which would speed up your debugging. Also, it illustrates use of CNT, FILENUM, ERR, LINE and various system functions which are typical of error recovery and debugging procedures.

To invoke this type of “catch all” routine, your program should contain a statement like the following usually located near the beginning of the program:

 00001 ON ERROR GOTO GENERALERROR ! To trap all errors

Using ON ERROR GOTO will trap all otherwise un-trapped errors. The routine looks like this:

 99000 GENERALERR: ! “General Purpose” error handling routine
 99101 LET GERRCNT=CNT
 99020 PRINT BELL;BELL;
 99030 PRINT “Error”;ERR;”occurred at line”; LINE
 99040 PRINT “This Line is listed below --“
 99050 EXECUTE “LIST”&STR$(LINE)&”,”&STR$(LINE)&” >line.err”
 99060 DIM LLL$*800
 99070 OPEN #77: “NAME=LINE.ERR”,DISPLAY,INPUT
 99080 LINPUT #77: LLL$
 99090 CLOSE #77:
 99100 PRINT LLL$
 99110 PRINT
 99120 PRINT “Current value of CNT =”;GERRCNT
 99130 PRINT
 99140 IF POS(LLL$,”#”,6)=0 THEN GOTO ERREND
 99150 PRINT “Last file processed was #”;FILENUM;”--“;FILE$(FILENUM)
 99160 IF FILE(FILENUM)<=0 THEN GOTO ERREND
 99170 PRINT “ Error occurred with the file listed above”
 99180 IF FILENUM<>255 THEN PRINT “ Last record processed was”; REC(FILENUM);”of”;LREC(FILENUM) !:
 ELSE PRINT “ PRINT statement began output at line”;
 KREC(255)+1
 99190 ERREND: PAUSE

After a NOKEY error, example screen output could look like this:

 Error 4272 occurred at line 200. 

This line is listed below:

 00200 READ #1,USING F1,KEY=CUSTNO$:CUSTNAME$

 Current value of CNT = 1
 Last file processed was #1 -- C:\BR\CUSTOMER.DAT
 Error occurred with the above listed file
 Last record processed was 0 of 20

This routine saves the value of CNT in line 99010 to be printed later. Line 99020 causes two beeps. Line 99030 prints the error number (ERR) and line number (LINE) where that error occurred (line 99030). Next, lines 99050 to 99100 list the line with the error; this is done by means of an EXECUTE statement with the file-redirection, then reading the line back in from that file. Lines 99110 to 99130 print the value of CNT at the time f the error (saved in line 99010).

Line 99140 tests to see whether the line involves I/O. This cannot be determined exactly in a line with more than one statement; line 99140 test for a # symbol and if it finds one anywhere in the line, it assumes the error was on an I/O statement. If the # symbol is in the first statement, and the error occurred in the second statement, this assumption would be wrong. However, when it is wrong, the routine prints too much information rather than too little. Remember, you were warned this routine was too small to work perfectly in all situations.

If line 99140 decides the error involved an I/O statement, the file number, name, and path of the file are printed from line 99150. Line 99150 uses the FILE function to decide whether that file was involved in the error.

If the file number was not 255, line 99170 prints the last record processed and the total number of record on that file. If the file was the printer, it prints the line number on the current printer output page.

====Quick Quiz 18.3====
The program BIGTRAP listed below has 2 INPUT statements for strings and 5 INPUT statements for numeric data. BIGTRAP also has many error trapping features. 

To find the correct answers for this quiz, you should enter run this program in STEP mode with the RUN STEP command. Listed below are the line numbers for the 7 lines which are INPUT statements. Assume that an error happens on each INPUT statement.

Because the lines 900 and 1100 ask for strings, the error will be SOFLOW. Because all other lines ask for numbers, the error for these will be CONV. As you execute this program, you can cause these errors by typing more than 18 letters whenever the word INPUT appears in the far left of the status line.

For each INPUT statement, you must answer a two-part question. The first part is whether the program will beep or branch to some line number. If you think it will not beep, the second part is to tell which line number the program will execute after the error.

 00100 ! ***********************B I G T R A P ********************
 00200 ! PURPOSE: Show all levels of error processing *
 00300 ! CREATION DATE: 8/15/05 LAST REVISION 8/16/05 *
 00400 ! Business Rules! *
 00500 ! *********************************************************
 00600 !
 00700 ON ERROR GOTO MISCELLANEOUS
 00800 PRINT “Enter A$”
 00900 INPUT A$ SOFLOW 2900
 01000 PRINT “Enter B$”
 01100 INPUT B$ EXIT 1200
 01200 EXIT SOFLOW 3000
 01300 ON CONV GOTO 3100
 01400 PRINT “Enter A”
 01500 INPUT A
 01600 ON CONV IGNORE
 01700 PRINT “Enter B”
 01800 INPUT B
 01900 ON CONV SYSTEM
 02000 PRINT “Enter C”
 02100 INPUT C
 02200 ON ERROR IGNORE
 02300 PRINT “Enter D”
 02400 INPUT D
 02500 ON ERROR SYSTEM
 02600 PRINT “Enter E”
 02700 INPUT E
 02800 STOP
 02900 PRINT 2900;”SOFLOW error at line”;LINE : CONTINUE
 03000 PRINT 3000;“SOFLOW error at line”;LINE : CONTINUE
 03100 PRINT 3100;”CONV error at line”;LINE : CONTINUE
 03200 MISCELLANEOUS” PRINT “Misc. error at line”;LINE : CONTINUE

1. SOFLOW in line 900,2900 <br>
Branches to line 2900, no beep <br>
2. SOFL OW in line 110,3000 <br>
Branches to line 3000, no beep <br>
3. CONV in line 1500 <br>
Branches to line 3100, no beep <br>
4. CONV in line 1800 <br>
Branches to line 3100, no beep <br>
5. CONV in line 2100 <br>
Branches to line 3200, no beep <br>
6. CONV in line 2400 <br>
Branches to line 2500, no beep <br>
7. CONV in line 2700 <br>
Beeps and shows error # at the bottom

`BR Tutorial|Back to Index`

===18.4 Reserved Words===
The reserved words listed in this APPENDIX cannot be used as variable names in Business Rules statements. These words are mainly names of existing functions and a few others reserved for future use. Reserved words may be used as line labels, file names, program names, etc but it is discouraged.

CURRENTLY IMPLEMENTED: (See also `Reserved Words`)

ABS

FILE

MAX$

SIN

CHR$

AIDX

FILE$

MENU

SHIFT

CMDKEY

ATN

FILENUM

MENU$

SLEEP

CNT

BELL

FP

MIN

SQR

CNVRT$

CALL

MIN$

SEARCH

SRCH

CODE

CEIL

FREESP

MOD

HELP$

COS

CFIELDS$

MSG

STR$

HEX$

CURCOL

CFORM$

SREP$

NEWPAGE

SUM

CURFLD

INF

KREC

LEN

REM

RND

ORD

KSTAT$

REC

UPRC$

LINEBUFFER$

INT

KPS

LINE

EXISTS

LINESTATUS$

PI

KLN

CURROW

UPSI$

DATE

TAB

PROCIN

RAD

USERID$

DATE$

IP

POS

PROCLVL

UNHEX$

WSID$

PIC$

TIMER

TRUNC

RLN

XLATE$

TAN

TIME$

UDIM

VAL

SERIAL

Days

LWRC$

ERR

CASE

BREAK

LOG

RPAD$

SGN

EXP

LOOP

ROUND

RPT$

MAX

DO

WHILE

DIDX

RTRM$

ENV$

UNTIL

LPAD$

LREC$

LTRM$

SELECT

FN (all words starting with FN, for user defined functions)

`BR Tutorial|Back to Index`
