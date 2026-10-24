---
title: Chapter_6
file: Chapter_6.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [Answers 6.2, Answers 6.3, Answers 6.4, Answers 6.5, Answers 6.6, Answers 6.7, Answers 6.8]
---
===Debugging Features=== 

Mistakes! This chapter won’t teach you how to avoid them, but it should help make discovering them a lot easier.  When you are finished you should be able to: 

*Use the RUN command’s STEP and TRACE options. 
*Use the LIST command to search for a character string. 
*Use PRINT as a command while the program is in execution. 
*Use BREAK and DISPLAY.
*Use LOGGING.
*Use READ and DATA statements to automate data entry steps. 

As your programs become longer, the mistakes that you make will be more and more difficult to detect, which may result in a bug-filled program.  A common error such as the following, where a numeric variable is assigned to a character string, could easily become lost in a program of 250 or more lines if the system did not provide a way to help you detect it: 

 2330 PRINT “Enter customer name” 
 2340 INPUT CUSTNAME 

Business Rules! has a number of features which are designed to make error detection easier.  To learn more about these debugging features (so called because errors in programs are often called bugs), you should enter the program below, named CHECKBAL into Business Rules!. 

When you LIST the program on your screen, it should look as follows: 

`image:6.1.png|600px`

CHECKBAL has two major bugs in it, only one of which will cause a Business Rules! syntax error.  Look the program over and see if you can discover the errors and then, whether you discover them or not, go ahead and RUN the program.  Use at least five figures from your own checkbook for the data. 

You should find that Business Rules! beeps and goes into error mode when you enter “F” for finished.  If you look at the middle portion of the status line, you’ll see that the error code is 0726.  Next to the error code is the number 00070; this is the number of the program line where the error occurred. 

Enter END or STOP from error mode, then LIST the program to see if you can figure out what caused the error.  (Don’t forget to look up the definition for error code 0726.) 

You should come to the conclusion the “F” is an illegal value for the numeric variable DEBIT, therefore it cannot be entered. 

====Quick Quiz 6.1==== 

1. What is the 5-digit number that appears in the center of the status line after an error occurs? <br>
a) The number of the error-causing program line.  <br>
b) The number of the program line where the error occurred.  <br>
c) The error code.  <br>

Answers:  <br>
1-b. 
 

===6.2 Using LIST to search for a character string ===

In the last section you learned that F cannot be entered for the variable DEBIT.  But you still need some way for the operator to signify that he is finished entering data, so what do you do? 

One possibility is to use the number -99 instead of F.  (Since -99 is not a logical withdrawal or deposit entry, there is no harm in using this number to signify the end of a series of numbers.)  When you do this, however, you will want to change all references to F to -99.  The best way to make sure that you don’t miss any is to use the search function of the LIST command. 

LIST will list all occurrences of a single string when you type the string in quotation marks.  Since quotation marks signify a literal string, you must be sure to specify uppercase and lowercase letters exactly as you expect them to be in the program. 

LIST “F” will produce this listing: 

`image:6.2.png`

You may make changes directly to the lines in this listing.  When you push Enter after changing each line.  Business Rules! will consider the changes to be permanent.  Go ahead and replace the F’s with -99’s and then LIST again to verify the changes are made.

===More about LIST=== 

LIST command is case-sensitive when used with double quotes like this:

 LIST "a"

The result will display only lines which contain only lowercase "a", but NOT uppercase "A".

LIST command is case-insensitive when used with single quotes like this:

 LIST 'a'

The result will display all lines which contain lowercase "a" and uppercase "A".

The LIST command provides all sorts of helpful ways to make the life of a programmer easier.  Besides using it to list an entire program or to search for a certain piece of information, you can use it to display a screen full of program lines starting with the program line you indicate.  The following command causes the system to display line 10 and the full screen of information that follows: 

 LIST 10- 

The next example causes the system to display line 180 and the full screen of information that comes before the line (notice the placement of the dash): 

 LIST -180 

You can even tell the system to list a specific range of program lines.  The following command causes lines 70 to 120 to be displayed: 

LIST 70,120 

====Quick Quiz 6.2 ====

1. Use the LIST command’s search feature to answer the following questions: <br> 
a) Which lines contain the string “THEN”?  <br>
b) Which lines contain the sting “credit”?  <br>
c) Which lines contain the string “00” (two zeros)?  <br>

2. Study the CHECKBAL program carefully.  What would happen if you had changed the Fs to -99 in lines 60 and 100 without also changing them in lines 75 and 120?  <br>
a) There would be no way to branch out of either the DEBIT or CREDIT loops.  <br>
b) Business Rules! would continue to accept only F as an indicator that the operator is finished entering data.  <br>
c) -99 would be subtracted from the values of TOTDEB and TOTCRED.  <br>

3. What does the LIST command’s search function do?  <br>
a) LISTs all lines in which the specified literal string occurs.  <br>
b) Searches for error-causing lines in a program.  <br>
c) Tries to find the value of a specified variable. 

4. Which of the following commands tells the system to list lines 100 to 150?  <br>
a) LIST 100-150  <br>
b) LIST 100  <br>
c) LIST 100,150 

5. Type in the following commands while CHECKBAL is loaded and see what happens: <br> 
a) LIST 44  <br>
b) LIST 20-  <br>
c) LIST -99999 

`Answers 6.2`  <br>

===6.3 Checking CHECKBAL’s calculations ===
You have now fixed one of the major bugs in the CHECKBAL program.  A LIST of the code should look as follows: 

`image:6.3.png`

Save this program under the name CHECKBAL2, and then run it again using the following figures:                             

Starting Balance: $456.98 

Withdrawal/debits: $34.20, 2.56, 98.42, 17.99, 10.00

Credits: 155.54, 49.72                    
             

Now figure the balance by hand, with a calculator or with Business Rules! commands. Match the ending balance that the program came up with to this balance. Which is correct?  It is important for you to check the results of all the programs you write in this manner.  

Using the figures above, the CHECKBAL program should have given you an ending balance of $499.07.  Please, compare this result to your own calculations.

LIST your program again and see if you can determine the cause of this miscalculation.  The best first place to look is at the statements that contain mathematical assignments (such as LET statements).  Are the formulas correct? 

If the assignments check out okay, you may need a more sophisticated debugging tool.  The next lesson will explain two options of the RUN command, STEP and TRACE, which will allow you to regulate and view the step-by-step progress of a program. 

====Quick Quiz 6.3 ====
1. The reason that the CHECKBAL program came up with a wrong answer is: <br>
a) Business Rules! made an arithmetic error. <br>
b) The program has an error in it. <br>
c) The operator did not enter the information properly. <br>

2. Where is the first place you should look for bugs when a program makes an incorrect calculation? <br>
a) At the PRINT statements. <br>
b) At the information that the operator entered. <br>
c) At the statements that contain mathematical formulas. <br>

`Answers 6.3`

===6.4 The RUN command’s STEP and TRACE options===

The RUN command has two options, STEP and TRACE, which are helpful for following the flow of a program during the debugging process.  There are four possible combinations: 

 RUN STEP 
 RUN TRACE 
 RUN STEP TRACE or RUN TRACE STEP 

**RUN STEP** tells Business Rules! to pause after the execution of each program line.  During the pause, Business Rules! is in STEP mode.  The word STEP appears in the left corner of the status line, and the number of the next line to be executed appears on the right (near the center). In release 4.3 and later, stepping through a program will also display each statement just before executing it.

**STEP** mode is much like ATTN mode in that it allows you to enter and execute most Business Rules! commands.  Business Rules! will remain in STEP mode until you press Enter.  It will then execute the next program line and re-enter STEP mode. Note that in release 4.3 and later, stepping through a program will display each program source statement just before executing it. 

Using **RUN STEP** when there are input statements in a program can be confusing, so let’s go though this step-by-step (no pun intended).  With CHECKBAL2 loaded and READY, type in RUN STEP.  Press Enter each time the program enters STEP mode until you reach the STEP mode before line 70.  The screen will look as follows: 

`image:6.4.png`

The error code for your most recent error will appear here (501 in above figure). 

Note that the prompt in the left corner of the status line says STEP.  If you enter the withdrawal/debit data that the screen asks for at this point, Business Rules! will not accept it as program input.  It will, instead, print the value of that data (go ahead and try it: if you enter 15, Business Rules! will print the same number -- since 15 is the value of 15 -- on the next line).

You must push Enter and allow Business Rules! to execute line 70 before it will recognize withdrawal/debit data.  The screen will then look as follows: 

`image:6.5.png`

Input mode means that you must now enter data before the program will continue. 

When you enter data and press Enter, Business Rules! will accept the data and re-enter STEP mode. 

RUN TRACE tells Business Rules! to print a record of the line numbers on the screen as they are being executed. 

RUN STEP TRACE (or RUN TRACE STEP) performs a combination of the STEP and TRACE functions.  For each statement, Business Rules! prints the line number on the screen, enters STEP mode and waits for Enter before executing the line. 

====Quick Quiz 6.4 ====
1. Which form of the RUN command should you use when you want program execution to pause after every line?  <br>
a. RUN PAUSE  <br>
b. RUN TRACE TRACE  <br> 
c. RUN STEP  <br>

2. Which form of the RUN command prints line numbers as their lines are being executed?  <br>
a. TRACE  <br>
b. RUN STEP  <br>
c. RUN TRACE 

3. When a program is in STEP mode, what does the number on the status line (just right of the center) refer to?  <br>
a. The line which has just been executed.  <br>
b. The size of the program.  <br>
c. The next line to be executed. 

`Answers 6.4`<br>

===6.5 Checking variable values from STEP mode ===

Business Rules! STEP mode accepts and allows execution of most commands.  This feature of STEP mode allows you to test the values of variables with PRINT commands throughout a program.  Why would you want to test the values of a program’s variables?  For a program such as CHECKBAL, checking values allows you to narrow down the source of a miscalculation. 

You already know for instance, that the value of BAL is incorrect when the PRINT statement in line 160 is executed.  But where does it go wrong?  In line 160?  In an earlier line?  Checking values while the program is in STEP mode allows you to find out. 

To check the value of BAL at the start of the CHECKBAL program, type in and Enter: 

 RUN STEP 

When the program enters STEP mode at line 10, type in and Enter: 

 PRINT BAL 

Business Rules! will print the current value of BAL, 0, on the next line.  Note that the program is still in STEP mode; it remains in this mode until you press Enter all by itself. 

Is 0 the correct value for BAL to have at this point?  If you think back to the numeric variable discussion in Chapter 3, you should remember that 0 is the default value of all numeric variables which have not otherwise been assigned.  BAL should be equal to 0 at line 10 and it should continue to equal 0 until it is first changed in the CHECKBAL program. 

To find out where the first change to BAL occurs, you can remain in STEP mode and enter LIST for a listing of the entire program.  You can also enter LIST “BAL” Enter, for a list of only the lines which include the BAL variable.  When you do this you will find that BAL is not changed until line 150 of the CHECKBAL2 program.  You can thus expect BAL to continue to equal 0 until Business Rules! executes that line of the program. 

You could check the values of all the variables in CHECKBAL2 at this point, but they would all equal 0.  A better choice is to step through the program, entering the same data as you entered previously (starting balance - $456.98;Withdrawal/debits -34.20, -2.56, -98.42, -17.99 and -10.00; deposit/credits  +155.54 and +49.72) until line 150 has been executed.  (The status line will show that line 160 is about to be executed.) 

Check the value of BAL at this time by entering: 

 BAL 

Business Rules! should respond with the same wrong answer, $42.09, which you got the first time you ran the program with the above figures.  Since this line 150 is the first line in which BAL is changed in the program, at least one of the other variables in the same LET statement (the source of the number assigned to BAL) must be incorrect also. 

While you are still in STEP mode, you can tell Business Rules! to LIST line 150 with the following command (When you want to LIST just one line, type the keyword LIST and the line number): 

 LIST 150    

Business Rules! will give you this: 

 00150 BALANCE: LET BAL=STARTBAL-TOTDEB+TOTCRED 

Keeping the program in STEP mode, go ahead and check the values of each of the other three variables in line 150.  After you have checked all three, the bottom of your screen should show the following: 

`image:6.7.png`

Do any of the values seem out of place?  Does having a value of 0 for STARTBAL perhaps seem strange?  We already know that the first part of the program asks for and accepts a starting balance (which you specified as 456.98), but somehow the entered value is not being placed into the STARTBAL file folder. 

Use the LIST command to check all other occurrences of STARTBAL: 

 LIST “STARTBAL” 

You may be surprised to see that Business Rules! responds with a listing of line 150 only.  If STARTBAL does not exist anywhere else in the program, what variable was your $456.98 starting balance assigned to?  LIST the entire program to see: 

`image:6.3.png`

A look at line 30 shows you that the starting balance data is assigned to the string variable STARTBAL$.  The variable STARTBAL in line 150 is a numeric variable; since its data was accidentally assigned to a different variable, its default value is still 0. 

Remove the dollar sign from the STARTBAL$ variable in line 30, and then RUN the program again (you will need to END the current RUN of the program first).  Use all the same data that you used in past tests.  The ending balance should come out correct this time. 

You have now successfully debugged the CHECKBAL program. 

====Quick Quiz 6.5 ====

1. What is the purpose of checking variable values during STEP mode?  <br>
a)   Helps detect syntax errors.  <br>
b)   Helps locate the source of a miscalculation.  <br>
c)   Causes the computer to beep when a miscalculation occurs. 

2. Which of the following commands would cause Business Rules! to print only line 150 of a program on the screen?  <br>
a)   LIST “BAL”  <br>
b)   PRINT 150  <br>
c)   LIST 150 

3. Which of the following commands can be used during STEP mode?  <br>
a) SAVE  <br>
b) LIST  <br>
c) LOAD  <br>
d) RUN  <br>
e) PRINT  <br>
f) GO 

4. The CHECKBAL program is in STEP mode, and the status line shows the line number 00150.  If you tell Business Rules! to print the value of BAL, what will happen?  <br>
a)   Business Rules! prints the value that BAL equals after line 150 is executed.  <br>
b)   Business Rules! will ignore the command and execute the next line.  <br>
c)   Business Rules! prints the value that BAL equals after line 140 is executed. 
 
`Answers 6.5`  <br>

 

===6.6 Using READ and DATA for automatic data entry ===
Now that you have successfully debugged the CHECKBAL2 program, we’re going to show you a step that would have made it easier (gee, what a dirty trick!).

You probably got tired very quickly of entering data for CHECKBAL2 each time that you ran it.  A couple of simple, temporary changes to your program could automate this process for you and thereby reduce your debugging time. 

Instead of requiring input from the operator, your programs can be instructed to locate a data table (constructed with DATA statements) and then read the required information (with READ statements).  DATA and READ are two separate statements which work together to provide automatic data entry. 

The DATA statement is designed to store values which will be assigned to variables during program execution.  An example of values that you could store in a DATA statement is the withdrawal/debit information that the CHECKBAL program needs.  The following DATA statement stores all five values and the number that signifies the end of data, -99. 

 00170 DATA 34.20,2.56,98.42,17.99,10.00,-99 

All DATA statements contain the keyword DATA and at least one data item.  When the statement is to contain more than one data item (as in the above example), the individual items must be separated by commas.  There is no need to use spaces between data items, but you may if you wish. 

Business Rules! handles DATA statements differently than it does most other statements.  DATA statements are nonexecutable, which means that they are not executed during regular program flow, but are just skipped.  Business Rules! instead checks an entire program for DATA statements before the first program line is executed.  All the information in all the DATA statements is then combined (with the original order maintained) into one data table.  The data table’s pointer is set to the first item in the table. 

Business Rules! data tables are internal constructs, which means that Business Rules! designs them only for its own use; you cannot ever actually see them. 

 00170 DATA 34.20,2.56,98.42,17.99,10.00,-99 

If you could see them, the above line 170 (which is so far the only DATA statement in the CHECKBAL program), would create the following data table (<- is the data pointer):

 34.20 &lt;- 
 2.56 
 98.42 
 17.99 
 10.00 
 -99 

The values in a data table can only be accessed by “READ data” statements.   All READ data statements contain the keyword READ and at least one variable name. When more than one variable name is used, the names must be separated with commas.  Replace the INPUT statement at line 70 of the CHECKBAL2 program with the following READ statement: 

 70 READ DEBIT 

READ tells the system to find the data table and assign the first available data item (the one to which the data pointer is set) to the named variable.  As soon as the data item has been assigned, the pointer moves to the next item on the table. 

Use RUN STEP to run the CHECKBAL program with the changes noted above.  Check the value of DEBIT each time that the system is about to execute line 70, then answer the questions in the next Quick Quiz 6.6.

====Quick Quiz 6.6 ====

1. Why does the PRINT statement at line 60 still instruct the operator to provide withdrawal/debit information, even though it would send an error message if you tried to enter information at line 70? <br>
a)   The withdrawal/debit question must remain in the program so that the READ statement can read it. <br>
b)   The withdrawal/debit question is left over from when the program required operator input at line 70.<br>
c)   PRINT and READ are two separate statements which work together to provide automatic data entry. 

2. How many times was the READ statement in line 70 executed? <br>
a)   One time. <br>
b)   Eight times. <br>
c)   Six times.

3. Match the following: <br>

{|  class="wikitable"
|a)   DATA statement. ||1.Accesses values from a data table. 
|-
|b)   DATA item. ||2.Marks the next data item to be used. 
|-
|c)   READ statement. ||3.One of the values listed in a DATA statement. 
|-
|d)   Pointer. ||4.Stores value which will be assigned to variables. 
|}

4. Which of the following statements is correct? <br>
a)   Business Rules! constructs a data table the first time that it encounters a DATA statement during normal program flow. <br>
b)   Business Rules! combines all the information from all a program’s DATA statements into a single data table. <br>
c)   DATA SEE is the command which allows you to look at a program’s data table. 

`Answers 6.6` <br>

===6.7 Using multiple DATA statements in a single program ===

The CHECKBAL2 program in the last lesson used only one READ statement (which was executed several times because it occurred in a loop) and one DATA statement.  It is also possible to use each statement more than once in program. 

You learned earlier that Business Rules! automatically searches an entire program for DATA statements before it executes the first program line.  All the information in all the DATA statements is then recorded in a single data table. 

If you wish to add a second DATA statement for deposit/credit values to the CHECKBAL2 program, your two data statements could be as follows: 

 00170 DATA 34.20,2.56,98.42,17.99,10.00,-99 
 00175 ! above (or prior) line gives data for withdrawal/debit 
 00180 DATA 155.54,49.72,-99 
 00185 ! above line gives data for deposit/credit 

Business Rules! would create the following table for this information: 
 34.20 <- 
 2.56 
 98.42 
 17.99 
 10.00 
 -99 
 155.54 
 49.72 
 -99 

Now here’s a test: if you also want the program to automatically enter the starting balance data, where should you put the DATA statement and what should it include?  Choose the best answer from the following possibilities (look at the line number to determine where the statement will be placed): 
  
 00165 DATA 456.98,-99 
       OR 
 00190 DATA 456.98 
       OR 
 00167 DATA 456.98 

The first answer above is wrong because -99 is not required as an end-of-data indicator.  The two DATA statements which are already in the program include -99 as the last item only because the CHECKBAL program requires this number before it will exit from the DEBIT or CREDIT loops.  

The second answer above is wrong because it would cause the starting balance data to be placed at the end of the data table.  Business Rules! determines the placement of items in the table according to the order that they appear in the program.  Since the starting balance ($456.98) is the first data value which is required by the program, it must also be the first data item in the data table.  The DATA statement containing the starting balance must have the lowest line number of all the DATA statements. 

The third choice is the correct answer.  Adding this line to the CHECKBAL2 program will cause Business Rules! to construct the data table such as the following when the program is run: 

 456.54 <- 
 34.20 
 2.56 
 98.42 
 17.99 
 10.00 
 -99 
 155.54 
 49.72 
 -99 

You may have already realized that there are a number of other ways to make Business Rules! construct the above data table for the CHECKBAL2 program.  There is no limit as to the number of data items which can be used in a single DATA statement (except that the total length of the line cannot exceed 800 characters), so you could put all the data items into a single statement, as follows: 

 20000 DATA 456.54,34.20,2.56,98.42,17.99,10.00,-99,155.54,49.72,-99 

There is also no limit to the number of DATA statements which may appear in a program.  You could put each data item into a separate DATA statement if you wanted to (however, this would not be an efficient use of program space or your time): 

 30010 DATA 456.54 
 30020 DATA 34.20 
 30030 DATA 2.56 
 30040 DATA 98.42 
 30050 DATA 17.99 
 30060 DATA 10.00 
 30070 DATA -99 
 30080 DATA 155.54 
 30090 DATA 49.72 
 30100 DATA -99 

Business Rules! would construct the same data table from the above two examples as it would from the following set of DATA statements (which we have already discussed).  The advantage of the following method, as you will learn in the next lesson, is that it allows you to match up each READ statement to a DATA statement which contains the values it will access. 

If you have not already done so, incorporate these statements into the CHECKBAL2 program. 

 00167 DATA 456.98 
 00170 DATA 34.20,2.56,98.42,17.99,10.00,-99 
 00180 DATA 155.54,49.72,-99 

====Quick Quiz 6.7 ====

1. How many data tables does Business Rules! construct for a program with 30 DATA statements? <br>
a)   Three.  Each data table may include information from up to ten DATA statements. <br>
b)   Thirty.  Business Rules! constructs one table for each DATA statement. <br>
c)   One.  All the information in all the DATA statements is combined into a single data table. 

2. Which of the following statements is true? <br>
a)   The items in a data table are placed in chronological order according to their value (the lowest number is first, the highest number is last). <br>
b)   Items are placed in the data table in the same order that they appear in the program. <br>
c)   The last value in a DATA statement must always be -99. 

`Answers 6.7` <br>

 

===6.8 Using multiple READ statements in a program ===

Before you run the version of the CHECKBAL2 program that you have just created, you should change the INPUT statements in lines 30 and 110 to READ statements.  This allows the program to access the new values that you have included in the DATA statements.  Change the statements to the following: 

 00030 READ STARTBAL 
 00110 READ CREDIT 

Go ahead an RUN the CHECKBAL2 program.  It should continue to print the same questions on the screen as it did before, but it will no linger stop and wait for input.  (Of course, you could remove these PRINT statements if you wanted to.)  It should come up with an ending balance of 499.07, which is correct. 

When the last item in a data table is assigned to a variable, the data table is out of items.  The pointer will not return to the top of the table and reissue each value (unless your program includes the RESTORE statement, which we will discuss below).  A READ statement which tries to read data items that do not exist will cause a syntax error during program execution. 

The most important thing to remember about using multiple READ statements in a program is that the data table must hold enough values for every READ statement. 

Each variable in a READ statement may access only one item from the data table.  A READ statement with six variables will access six data items.  If the same READ statement is then re-executed by the program, the statement will access six more data items. 

Using the data table below, can you figure out which values Business Rules! would assign to the variables in line 11000? 

 11000 READ NAME$,BIRTHDATE$,SEX$,EYECOLOR$,HEIGHT$,WEIGHT$ 

“Armand Tate” 
“6/28/57” 
“M” 
“GRN” 
“5/11” 
“137” 
“Willa Masters” 
“3/2/42” 
“F” 
“BRN” 
“4/10” 
“98” 
78,900,341.26 

The RESTORE statement allows you to tell Business Rules! to reset the data pointer to the first item in the data table.  When a data table runs out of data items and this statement has not been used, Business Rules! sends an error. 

====Quick Quiz 6.8 ====

1. Which data item does the first variable in a READ statement access? <br>
a)   The first item in the data table. <br>
b)   The item to which the data pointer is set. <br>
c)   The first item of its same type (numeric or string). 

2. What does the RESTORE statement do? <br>
a)   Tells Business Rules! to bring back a former version of a program. <br>
b)   Resets the data table pointer to the first item in the table. <br>
c)   Duplicates each DATA statement in a program. <br>

`Answers 6.8` <br>

====Chapter 6 Exercise ====

A company has four employees with current annual salaries of $36,000, $28,000, $16,000 and $20,000.  Put these four numbers in a DATA statement.  

Write a program to print the new salaries if each employee is given a 10 percent raise.  

Also print the total of the four new salaries.

Save this program under the name NEWSAL, and you will continue to modify it with what you learn in Chapter 7. 

`Solutions#CHAPTER 6|Solution` 

===6.9 Using BREAK and DISPLAY===

Two more tools that are useful for debugging (as of 4.1) are the BREAK and DISPLAY commands. 

While a program is loaded, you can always enter STATUS BREAK and all the program's current debug settings will be displayed on the screen.  

===6.10 LOGGING===

The LOGGING config statement will provide logging for debugging purposes. 

By adding this syntax to your BRConfig.sys file, BR will record what happens when the program runs.

 LOGGING loglevel, logfile

Where loglevel is a number representing an activity to be logged, as seen in the chart below. Choosing a higher number will also include all the levels below it:

{|
|-
||**0 - MAJOR_ERROR**||major problems occurring during execution
|-
||**1 - NOTABLE_ERROR**||unexpected error likely to cause problems
|-
||**2 - MINOR_ERROR**||unexpected error that can be ignored
|-
||**3 - MAJOR_EVENT**||starting program, exiting and shelling
|-
||**4 - SECURITY_EVENT**||logons, logon attempts etc
|-
||**5 - MINOR_EVENT**||individual commands entered during execution
|-
||**9 - DEBUGGING_EVENT**||added for debugging purposes
|-
|}

And logfile is the file where BR will record the information. 

NEXT:`Chapter 7|Unformatted and Formatted Printing`

`BR Tutorial|Back to Index`
