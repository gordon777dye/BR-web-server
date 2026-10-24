---
title: Chapter_3
file: Chapter_3.md
category: 90-reference
subcategory: 90-reference/error-codes
kind: error-code
related: [Answers 3.1, 0726, Answers 3.2, Answers 3.3, Answers 3.4, Answers 3.5, Answers 3.6, Answers 3.7, Answers 3.8]
corrections: "Two naming claims corrected against the runtime (§3 line-label and variable-naming passages). The original text said names must begin with a letter and that line labels could be any length. Both are wrong: names are 1-30 characters, an underscore counts as a letter throughout, and `_a = 1` compiles. The two `must begin with a letter` lines left in place are Quick Quiz distractors (Q3.4-1c, Q3.5-2c), not assertions - they are false, which is the point of them, and no answer key was ever fetched."
---
===3.1 More Operation & Programming Fundamentals===
  
Now that you've learned the basics about running, saving, loading and editing programs, you're ready to learn more about writing programs that actually do something. When you have completed Chapter 3 you should be able to: 
  
#Use the INPUT and LET statements in a program. 
#Code the CONV error condition and a corresponding error-handling routine in a program. 
#Recover from user errors. 
#Enter and exit from ATTN mode. 
#Use line labels and comments to help identify your programming logic. 
#Explain the purpose of a variable and describe two types of variables, numeric and string. 
  
===INPUT & LET statements===
In Chapter 2 you learned to write a program called GRANDMA, which tells a brief story. GRANDMA was unlike most programs you will write, because it did not require any information or interaction from the user. 

In BR, **users** are people, who are using (running) software written in BR without complete technical expertise required to understand the system fully.
  
Let's now write a program that does require action or input from the user. This program, which computes miles per gallon, first asks for information and then takes that information, performs a mathematical operation, and prints the result. 
  
Most programmers try to keep the needs of the user in mind when they write. Programs which are easy to use and forgiving of the user's mistakes are often called user-friendly. 
  
To tell the person who is running the program what information is needed, we must first start off with a PRINT statement: 
  
 00010 PRINT "Total number of miles?" 

This statement asks a question that the user must answer.
  
Next, you must use the INPUT statement to tell BR to wait for and accept information from the user: 
  
 00020 INPUT MI 

The letters MI in line 20 are called a variable. It represents the number of miles (and the answer to the question in line 10), which varies every time that the program is run. 

A **variable** is a named memory location which temporarily stores data that can change while the program is running.

You must always specify a variable when you use the INPUT statement. We will discuss more about variables in another lesson. When the miles per gallon program is run and the user enters a number in response to the question, Business Rules! puts this number into the variable MI. 
  
The next two statements in your program ask for and accept the answer to the following question: What information does the variable GAL in line 40 stand for? 
  
 00030 PRINT "Number of gallons?" 
 00040 INPUT GAL 

Once the program has asked for and received all the information it needs, it must perform the computation. Miles per gallon can be determined by dividing the number of miles by the number of gallons.  In Business Rules! you can use the following symbols to perform mathematical calculations:

 + plus
 - minus
 * multiply
 / divide
 = assign a value to a variable
 ( ) determine the order of arithmetic operations

Using the variables that we have already chosen, the formula is: 

 MPG = MI/GAL
  
The LET statement tells Business Rules! to perform this exact computation. MPG is introduced as a new variable in this statement: 
  
 00050 LET MPG = MI/GAL 

When Business Rules! finishes executing line 50, it knows the answer to the miles per gallon problem. If you want the user to know what the answer is, you must make the program specifically say it! The following statement instructs Business Rules! to print two things: the information within delimiters (Miles Per Gallon =), and the value of the variable MPG. 
  
 00060 PRINT "Miles Per Gallon="; MPG 

The last statement in your program is STOP: 
  
 00070 STOP 

If you now do a LIST of your program, it should look like this: 

  
`image:3.1.png`

====Miles Per Gallon Program (MILEAGE) ====
To see if the program works, type RUN and answer the questions. Then SAVE the program under the name MILEAGE and go on. Note that the program will expect you to type a number in response to both questions. If you type in letters, symbols, or numbers surrounded by quotes, then an error will occur.

====Quick Quiz 3.1==== 
1) Name the three variables which are used in the Miles Per Gallon Program:______, ______, and ______.

2) Match the following functions to the corresponding Business Rules! symbols:

{| class="wikitable"
|a)  Addition
|1. *
|-
|b)  Subtraction
|2. + 
|-
|c)  Multiplication
|3. / 
|-
|d)  Division
|4. - 
|}

3) What punctuation mark is used in a PRINT statement to separate two or more 		items to be printed? (Hint: see line 60 of the MILEAGE program.) 

4) What does the INPUT statement do? 

a)  Tells Business Rules! to print a question that the user must answer with the letters MI or GAL. <br>
b)  Tells Business Rules! to perform an arithmetic operation.  <br>
c)  Tells Business Rules! to accept information from the user and assigns that information to a specific variable.  <br>

5) What does the LET statement do?
 
a)  Tells Business Rules! to perform an arithmetic operation and print the result.  <br>
b)  Tells Business Rules! to let the user answer a question.  <br>
c)  Assigns a value to a variable.  <br>

`Answers 3.1`

====Extra Practice: ====
Write a program which calculates the area of a circle. Use the INPUT and LET statements, calculate the area and assign it to a variable named Area.

As you progress through the next few chapters, we’ll continue to build on and modify this program as you learn different statements and commands.

===3.2 Getting an error and interrupting a program during a RUN ===

You have already learned about getting errors (called syntax errors) as you write a program, you can also get an error when you RUN a program. In the next few exercises, we'll use the MILEAGE program which you should have written and saved in the last lesson to learn about recovering from execution errors. 
  
When you have MILEAGE loaded and READY, go ahead and RUN it.  Answer the first question as shown below: 
  
 Total number of miles?       
 three hundred         		-Type this (yes, spell it out!) 

Now press ENTER. The following things should happen: one, the computer should beep; two, error code `0726` should appear in the center of the status line; and three, the word ERROR should appear in the left corner of the status line. This is called an "user error or run-time error because the error occurred when the user was running the program. 

A **run-time error** is an error detected during the execution a program.

As signified by the word ERROR in the status line, your program is now in error mode. When a program enters this mode, it stops executing and waits for instructions in the form of commands from the user. This leaves plenty of time for you to look up the error code in the Wiki.
  
When you have figured out what caused the 0726 error, you can tell Business Rules! to re-execute the last statement by entering the command GO (remember GO is a command and it doesn't use a line number). Business Rules! will then go back into RUN mode to the statement at which the error occurred and allow you to enter the information correctly. Go ahead and do this now: 

`image:3.2.png`
 

===GO===
As soon as you have entered the GO command and pressed ENTER, you can go through the steps illustrated in the following frame. 

The INPUT prompt in the left corner of the status line reminds you that you must enter information before the program can continue: 

  
`image:3.3.png`

===INPUT===
Now that you have successfully recovered from the 0726 error, we are going to ask you to make the same type of error again. Where the program asks for the number of gallons, enter "fifteen". This time instead of entering GO to get back into the program, you should enter STOP. Business Rules! will then terminate the RUN of the program and return to READY mode. During a program interruption, Business Rules! accepts and executes almost any command that you enter except SAVE, RUN, REPLACE, and SYSTEM. 
  
What if you want to execute a command while the program is running? There is a way to interrupt program execution by pressing CTRL + A.
  
After you press CTRL + A, your program will then go into ATTN (attention) mode. ATTN mode allows you to execute commands and assign values to variables. To continue running the program you interrupted, use the GO command. Everything you did in attention mode is erased when GO is entered, and the screen will look just as it did before you went into attention mode. 

For future reference:
From now on, if we refer to pressing several keys at the same time, we will use the plus sign between the desired keys. For example, to signify pressing the Ctrl, Alt, and Del keys at the same time, we will write Ctrl + Alt + Del.

====Quick Quiz 3.2 ====

1) What are two different kinds of errors that you can get? 

a)  Syntax and run-time errors. <br>
b)  user and data-mapping errors. <br>
c)  user and syntax errors. <br>
d)  Error codes and beeps. <br>

2) What happens when a program goes into ERROR mode? 

a)  The program stops executing and waits for instructions, in the form of commands, from the user. <br>
b)  Business Rules! terminates the program, clears memory and shows a listing of the directory. <br>
c)  Business Rules! looks up the error code, then executes the GO command and starts the program all over. <br>

3) Match the following:

{| class="wikitable"
|a)  ATTN||1. Terminate program 
|-
|b)  GO||2. Ctrl-A 
|-
|c)  STOP||3. Resume program execution 
|}

`Answers 3.2`

===3.3 Program Operation=== 
In the last section, you learned what to do when a run-time error occurs. But what happens when you give your MILEAGE program to somebody who knows nothing about programming encounters an error? How will the user know what went wrong, and how will he/she know how to get out of error mode? 

A partial answer to this problem is that you can code error conditions into your programs that catch (or trap) specific kinds of errors. For instance, the kind of error that you caused by entering letters instead of number was called a conversion (CONV) error.   

Often you can foresee that somebody might make a certain error such as entering letters instead of numbers and this is when error conditions can be helpful. To add the CONV error condition and its corresponding error-handling routine to your program, you should first LIST your code. 

Now, think back to the first error you caused. It happened when you were providing information for the INPUT statement in line 20. Since you must add the CONV error condition to the statement where the error could occur, it must go here.  The same error may also occur in line 40 as well, so move your cursor to line 20 and then to line 40 and change them to this: 
 00020 INPUT MI CONV 80  
 00040 input GAL CONV 80

By adding CONV 80 to the INPUT statement in lines 20 and 40, you are telling the program (in shorthand fashion) that when a conversion error occurs, it should jump to line 80 rather than going into error mode. The number 80 is an example of a line-ref (or line reference) which refers the BR system to a program line. A line-ref must be included every time you specify an error condition. A line-ref is a very specific item to BR: it must always be either a line number or a line label (which you will learn about in a later lesson). 

So what's at line 80, you ask? Well, that's your next step. Since BR keeps track of the statement where the error occurred (line 20 or 40, in this case), you could simply tell the program to re-execute that statement (and give the user a second chance at doing it right) by specifying RETRY: 

`image:3.4.png`

To see how well this error condition works, RUN your program. When the "Total number of miles?" question comes up, enter letters instead of numbers again. Try to imagine the execution order of your program as it is running. It might help to envision Zippy the Cursor dashing along from one statement to the next, executing each one. When Zippy reaches the INPUT statement in line 20 or 40, he patiently stands by (right next to the MI manila folder) and waits for you to enter a number that he can assign to MI. But when you enter letters instead, he double-checks line 20 or 40 to see if you told him what to do for such an error. Why yes! The CONV 80 portion of the line is practically screeching at him to go to line 80. So he takes a flying leap to line 80 (he even flew past the STOP statement in line 70), where he discovers that you want him to retry the error-causing statement. Back he goes to line 20 or 40, wherever the error had occurred, where he again patiently waits for you to enter a number. 

But wait a second. Pretend that you are the user now. You entered "three hundred" for the number of miles and Zippy did all that work just so you wouldn't have to deal with an error mode, but now nothing is happening on the screen. The only clue as to what should be done is the INPUT prompt in the status line, and who knows what that means (besides you, the computer programmer)? 

You know that Zippy is eagerly waiting, with MI manila folder open, for that number so go ahead and enter it, then let Zippy finish the program with no more mishaps.

Now do another LIST of your program and look at that line 80. Is there some way you can make it tell Winston what he did wrong, then send program execution back to line 20? 

Of course there is! It just takes two statements instead of one! Just so you know: your error-handling routine can be as long as is necessary. Try this: 

 00080 print "Please enter numbers, not letters." 
 00090 RETRY 

Once you have entered both of these statements, run the program and again answer the first question with letters instead of numbers. Does your error-handling routine work? Does it work well? Would Winston M. Meyerbottom figure it out?

Don't forget to REPLACE your old version of MILEAGE with this new version. 

====Quick Quiz 3.3 ====
1) How can you cause a CONV (conversion) error? 

a)  By entering feet and inches when the program expects metric units. <br> 
b)  By entering letters when the program expects numbers. <br> 
c)  By pressing Ctrl-A. <br> 

2) Where must the CONV error condition be coded when you use it with the INPUT statement? 

a)  At the beginning of the program.<br>  
b)  At the beginning of the statement where the error could occur. <br> 
c)  At the end of the statement where the error could occur. <br> 

3) What must be included with every error condition?

a)  ENTER. <br> 
b)  A line-reference. <br> 
c)  The number 80. <br> 

4) What does the RETRY statement do? 

a)  Starts execution of the program all over again. <br> 
b)  Prints a message that says, "Please enter numbers, not letters." <br> 
c)  Retries execution of the error-causing line. <br> 

`Answers 3.3`

====Extra Practice====
Continue with the program AREA that you created in section 3.1. Add a CONV statement to handle a similar error as described above, to prevent the user from entering the numbers in word form.

`Solutions#CHAPTER 3|Solution`

===3.4 Line Labels=== 
LIST your revised version of the MILEAGE program. It should now look like this: 

`image:3.5.jpg`

MILEAGE is a short program. Even if you look at it ten months from now, it will probably take only a minute or less to figure out its purpose and its flow. Eventually you will write programs that are quite a lot longer than this, and then it will be much more difficult to follow your original programming logic. 

Program code can sometimes look like gibberish to even experienced programmers, so Business Rules! allows you to help explain it to yourself with identifying labels at the beginnings of any or all program lines. 

A line label is simply a name for a line. If you have ever attended a school where students were referred to by numbers (which are hard to remember) rather than names, you will probably see the value of a line label without difficulty. The purpose of a line label is similar to a comment in that it helps someone who is reading the program to understand what the programmer is doing. LABELS tell the reader where a programmer is going with their LINE REFERENCE STATEMENTS. The label gives you an easily-remembered way to refer to a line. When you get more experienced, on a job you may be writing programs that consist of ten thousands of tens of thousands of lines! Wow! And when the reader of the program gets to line 120, and there is a line reference statement to line number 8060, how will they remember, when they finally get to line 8060, that it was referred to at line 120? We could remind them in the name! One part of your MILEAGE program which could be difficult to identify is the error-handling routine in lines 80 and 90. If MILEAGE were much longer, it would be difficult to trace these statements back to the CONV error in lines 20 and 40. A way to make it easier would be to use a line label that identifies the error condition (CONV) for which the routine was written. Here is how to apply a label to a program line: 

 00080 CONVRSN: PRINT "Please enter numbers, not letters." 
 00090 RETRY 

In this case, CONVRSN is the line label. When line labels are used, they must be placed immediately after the line number. They can be 1–30 characters of letters, numbers and underscores, and cannot include spaces. An underscore counts as a letter throughout, so a label may begin with one too. *(Corrected — the original said labels could be "any length" and had to "begin with a letter"; both are wrong. See `corrections:` in the frontmatter.)* 

Immediately after the label comes a colon, which tells BR that the preceding was a label and that the statement follows. Labels must be unique once you have used a line label in a program, you cannot use the same name as a label for another line. Labels can have the same name as a keyword or variable name, or as in the following case, they can also have the name of an error condition.

Line numbers and line labels perform essentially the same duties. The difference is that every line must have a number, but labels are optional. Both are considered to be line-refs, however; a line label can be used anywhere in a program that a line-ref (a line reference) is called for. Do you remember where you used line references in your MILEAGE program? 

You used line references when you coded error conditions into lines 20 and 40. Let's return to these lines now and test to see if line labels really do work as line references. Go ahead and change the lines as written: 

 00020 INPUT MI CONV CONVRSN 
 00030 PRINT "Number of gallons?" 
 00040 INPUT GAL CONV CONVRSN 

Also, change line 50 to
 00050 FORMULA: let MPG = MI / GAL

LIST the program to be sure that your changes are correct (did you remember to press ENTER after both changes?), then RUN it and see if it works when you type in an error. 

`image:3.6.png`

Can you envision a situation where a line label such as the one you used could be really helpful? Imagine that you are working on a program that is 200 or more lines long. You code the CONV error condition into lines 20 and 40, just as you have done above. And, just as above, you code the CONV error-handling routine into line 80. After writing another 140 lines, (bringing your line# into the thousands), you decide to use the same error-handling routing again, for another potential CONV error. But think about it: you've written 140 lines of code, probably taken two breaks and answered six phone calls since then. Will you be more likely to remember that the error-handling routine is at line 80, or will you remember that it's at the CONVRSN line label? Line Labels are important for both the programmer and the reader.

====Quick Quiz 3.4 ====
1) Which of the following statements is true: 

a)  Line labels can be up to 30 letters, numbers and underscores long. <br>
b)  As long as they are at least 140 lines apart, two line labels in the same program can have the same name. <br>
c)  Every line label must begin with a letter. 

2) Which of the following can be used as line labels: 

a)  PRINT <br>
b)  ZIPPY1 <br>
c)  SAVE <br>
d)  THIS_IS_A_LINE_LABEL(?): <br>
e)  123GRASS <br>
f)  C99887754321 <br>

`Answers 3.4`

===3.5 Comments ===
Another way that Business Rules! allows you to explain programs to yourself is through the addition of comments. Comments which are separated from the rest of a statement with an exclamation point (!) are non-executable, meaning Business Rules! completely ignores them. A comment is used to inform someone who is reading the program about what that certain part of the program is for. This is called increasing the "readability" of the program. If you ever work as a professional programmer, or you ever need to come back and look over an old program, your program needs to have good readability, and be very understandable. 

An example of a spot where you might want to use a comment in your MILEAGE program is with the INPUT statement at line 20. Here you have used the variable of MI to represent the number of miles. It may not be very difficult to figure this out, but you want it to be so clear that even Winston M. Meyerbottom would understand, so you should change the line to the following: 

`image:3.7.jpg|600px`
   
You could add a similar comment to line 40: 

 00040 INPUT GAL CONV CONVRSN ! GAL = Number of gallons 

Any comment you wish to make is legal. You can even put a comment on a line that has no other statements on it. It is in fact, a good practice to use comments to identify your name, the name of your program, and the date. Use the following lines as an example, and then add your own to the beginning of MILEAGE: 

`image:3.8.png`

Make sure that when adding these lines to the program, you give them the numbers 1-5 and not 10-50. These lines come before the first line that is executed (10).

====Quick Quiz 3.5 ====

1) Which symbol tells Business Rules! that a non-executable comment is following? 

a)  :  <br>
b)  !  <br>
c)  "  <br>

2) True or False - Business Rules! changes all lowercase letters in a comment to uppercase. 

`Answers 3.5`

 

===3.6 Numeric VS String Variables ===
Business Rules! distinguishes between two different types of variables: numeric and string. 

A numeric variable indicates to Business Rules! that an arithmetic operation will be performed with the value of this variable. The value of a numeric variable must be a number. When you assign the value to the variable, you must specify either a number, (also called a numeric constant), a numeric variable (i.e. PUMA = COUGAR), or a formula that computes to a number (i.e. MPG = MI/GAL). The following example shows each of these possibilities: 

`image:3.9.png`
 
A string variable indicates to Business Rules! that no mathematical operation will be performed with the value of the variable. Business Rules! will accept any value (either numbers or letters) for the variable. But it will refuse all attempts to use arithmetic with the variable, even if the value happens to be a number (there is a way to get around this rule; we will learn about it in a later chapter). The only way that Business Rules! can tell the difference between numeric and string variables is by the way that you name them: a string variable's name ends in `$`. Both types must begin with a letter or an underscore, which Business Rules! treats as a letter throughout. *(Corrected — the original said "must always begin with a letter". See `corrections:` in the frontmatter.)* 

The vital difference between them is that string variables must end with a dollar sign ($), and numeric variables must not. 
  
The following lines give examples of values which can be assigned to string variables: 
 
 10 let country$ = “Africa”
 20 let population$ = “9,876,543”
 30 let landmass$ = “5,654,342 square miles”

Note that even though on line 20, the string variable population$ is assigned the value “9876543”, you cannot perform any arithmetic operations with this value, because it is a string.

Also, note that the above LET statements all list the name of the variable on the left of the equal sign, and the value of the variable on the right of the equal sign. This syntax can be described with the following syntax sentence: 
  
 line# LET variable = value 
  
So far you have used only numeric variables in the programs that you have written: MI, GAL, and MPG, from your MILEAGE program, are all examples of numeric variables. 
  
Let's look at an example of how string variables are used. Key the following program lines into Business Rules!: 
  
 00010 PRINT "What is your first name?" 
 00020 INPUT NAME$ 
 00030 PRINT "How old are you, ";NAME$;"?" 
 00040 INPUT AGE$ 
 00050 PRINT NAME$;" is ";AGE$;" years old." 

When this program is run, it asks the question, "What is your first name?" If the user answers "Gladys", the INPUT statement in line 20 puts the name Gladys into the NAME$ manila folder. Line 30 then prints "How old are you," the value of NAME$ and a question mark: 

 How old are you, Gladys? 
  
Line 40 takes Gladys' answer to the age question and puts it into the AGE$ manila folder. Since AGE$ is a string variable (rather than numeric), Zippy the Cursor does not pay any attention to whether the answer to this question is numbers or letters. Gladys' answer to the question could be fifteen or it could be 15; either way, Zippy just drops the information into the AGE$ variable and dashes back to execute the next line.  RUN this program for yourself and see how it works. 

Now, let's try an experiment. You would like the above program to multiply the user's age by three and print the result. Can you explain why Business Rules! will not even allow you to enter the following expression?: 

 00060 PRINT AGE$*3 

Business Rules! sends an error when you attempt to enter the above statement because you are telling the system to perform a mathematical operation (* means multiply) with a string variable AGE$. Even if the value of the variable is 15 rather than "fifteen", Business Rules! will not perform arithmetic with this variable. 
  
Okay, so our first try didn't work. Will it work if you take the $ off the AGE$ variable? Change line 60 to the following statement, then RUN the program and see: 
  
 00060 PRINT "Your age multiplied by three is";AGE*3 

Well, this was a step in the right direction (at least Business Rules! allowed you to enter statement, right?), but it does not result in the correct answer. No matter what value you enter for the age question when you RUN this program, Business Rules! will tell you that three times your age is zero. 

The reason that this second line 60 does not work is that it introduces a brand new, undefined variable into the program. AGE$ and AGE are two completely different variables; each has its location in memory. They cannot be used interchangeably. If you wish to assign the answer to the age question to a numeric variable, you must go back to the point at which the variable is originally assigned and change that variable name. In this case, you would have to go back to line 40 and 50 and change them to: 

 00040 INPUT AGE 
 00050 PRINT NAME$;" is ";AGE;" years old." 

Line 60 will now work properly. RUN the program and see. Notice that Business Rules! will no longer allow you to enter letters instead of numbers for the age question. As an exercise, see if you can code the CONV error condition and an error-handling routine for a potential conversion error into the program. 

`image:3.9a.png`
  
====Quick Quiz 3.6====
1) A numeric variable: 

a)  Is a number which represents another number. <br>
b)  Must end with a dollar sign. <br>
c)  Indicates that a mathematical operation may be performed with the value of the variable. 

2) A string variable: 

a)  Cannot have a value which is a number. <br>
b)  Indicates that no mathematical operation may be performed with the value of the variable. <br>
c)  Must begin with a letter and end with a colon. 

3) Identify the following variables as either string (s), numeric (n), or invalid (i): 

a)  CL2R6$N <br>
b)  REG:1# <br>
c)  $66614$ <br>
d)  NUM$ <br>
e)  PENGUIN <br>
f)  PC12 <br>
g)  DASH-# <br>
h)  X <br>

4) True or False - When you assign the value 64 to the variable WIMPNUM, you are also assigning it to the variable WIMPNUM$. 

`Answers 3.6` 

 

===3.7 Assigning values to variables ===
The value of a variable is a specific piece of information that Business Rules! assigns under the name you give it. 

Remember in the AGE program when we asked you to insert a new line 60, which multiplied the value of AGE by three, into the sample program of the last lesson? And then, until you changed the previous AGE$ variable to AGE, the computer kept responding with an answer of zero? The following scenario should help you to understand why this happened: 

Imagine that Business Rules!'s memory has access to two huge rooms with rows and rows of filing cabinets in them. The door to one of the rooms is marked "Numeric Variables"; the door to the other is marked "String Variables". The filing cabinets in the two rooms are filled with manila folders which are labeled with every numeric and every string variable name that could possibly exist in Business Rules!. 

Whenever Business Rules! is started, all the manila folders in the String Variables room are empty, but all the folders in the Numeric Variables room contain the number 0. 

Now imagine that these two rooms have a caretaker named Windela. Windela is like a master librarian - she knows everything about anything to do with the variables in her two rooms. Whenever a statement in a program assigns a value to a variable, she is the one who makes sure that the value gets inserted into the right manila folder. Windela is also the one who goes back to the manila folders which were used with a program and empties them out. Every time that a RUN, LOAD or CLEAR is performed, Windela goes through all her manila folders, changing all the numeric variable values back to zero and all the string variable values back to empty space. 

Translating this story into real terms, there are 4 concepts that you should remember: <br>
#No matter what variable you use, it already contains a default value. 
#All numeric variables have a default value of zero. 
#All string variables have a default value of empty string, or a string of zero length. 
#No matter what values you assign to the variables in a program, they are reset to zero or zero length whenever you RUN, LOAD, or CLEAR a program. 

A default is a standard course of action that Business Rules! takes when you do not tell it how to handle a specific situation. BR's process of setting the value of unassigned variables to zero is a default. That's why the answer kept coming up as zero when you first coded the AGE variable into the sample program of the last lesson.  Business Rules! multiplied 0 by 3 and came up with 0. 

When you don't assign a value to a string variable, Business Rules! automatically gives it a default value of zero length. This essentially means that the value of the variable is empty space. The string has no characters; it is sometimes referred to as a null or empty string. 

You may have already noticed in your experimentation with Business Rules! that you can sometimes type in a letter, a word or a set of nonsense letters and numbers. Then, when you press ENTER, Business Rules! prints a zero on the next line of the screen. As an example, enter the letter "a" and press ENTER: 

  a
  0

Business Rules! thinks you are asking it to print the value of the variable "a". Since you have not yet changed the default value of a, the value is zero. You would get the same response if you had entered “PRINT a". As a default, Business Rules! automatically executes a PRINT statement when it finds no other statement or command (we'll explain why in this next section). 

Notice that "a" is a numeric variable. If you try the same experiment with a string variable, Business Rules! returns exactly what it finds in the manila folder - empty space: 
  `image:3.9b.png`

You have already learned the two most popular ways of assigning values to variables: with INPUT, and with LET. 

In the MILEAGE program and in the last lesson, your INPUT statements instructed Business Rules! to assign the program user's choice of a value to the specified variable. An example of this statement is: 

 20000 INPUT HORSE$ ! HORSE$=Name of fastest horse 

When you used the LET command, and when you used the LET statement in your MILEAGE program, you were assigning values to numeric variables. When you assign values to string variables with the LET statement, you must enclose the value within Quotation marks, as in the following example: 

 00010 LET REX$="Doggy" 

====Quick Quiz 3.7 ====
1) What is the value of a variable? 

a)  A manila folder that holds a number.  <br>
b)  A specific piece of information which is represented by the variable.  <br>
c)  The amount of money that a variable is worth.  <br>

2) What is a default? 

a)   An error that Business Rules! tries to correct by returning zero instead of a beep and an error code.  <br>
b)   A null string.  <br>
c)   A standard course of action that Business Rules! takes when the program does not tell it how to handle a specific situation.  <br>

3) The default for a numeric variable is: 

a)   A null string.  <br>
b)   Zero length.  <br>
c)   Zero.  <br>

4) Name two ways of assigning values to variables. 

5) Which of the following is not required when you specify the value of a string 		variable in a LET statement? 

a)   First character of the variable must be a letter.  <br>
b)   Last character of the variable must be a $.  <br>
c)   A comment at the end of the statement must clarify the variable's purpose.  <br>
d)   Value must be enclosed within quotation marks.  <br>

`Answers 3.7`

====Extra Practice:====
Type the following program into Business Rules! and try to run it:

 10 Print “What is your favorite color?”
 20 Input color$
 30 Print “What is your favorite number?”
 40 input numb
 50 Print “The square root of your favorite number is” SQR(numb)
 60 Print “Your favorite color is”; color
 70 Stop

You will encounter two errors in this code. Study the lines and what you’ve learned in the previous lessons to fix it. SQR( ) functions as a square root symbol in BR, its not an error.

`Solutions#CHAPTER 3|Solution`

===3.8 More about variables ===
We suggested that you think of a variable's reserved space for information as a "manila folder" with the name of the variable stamped on it. When you or the user specifies that the value of the MI variable is 300, Business Rules! places the number 300 into the MI manila folder. This process assigns the value 300 to the variable MI. But if you later specify that MI equals 329, Business Rules! will go back to the MI manila folder and replaces the number 300 with the number 329. Anytime that a command or program calls for use of the MI variable, Business Rules! returns to the manila folder and looks up the CURRENT value and uses it. You can test this with the following command exercises: 
  
Enter the following without a line number: 
  
 MI = 300 

Business Rules! puts the number 300 into its MI folder. Then it displays the value of the calculation. This acts as a LET statement as well as an immediate PRINT statement (we'll tell you why its a print statement soon). 
  
The computer will respond by printing the value of MI, which is 300. Your screen will say: 

 MI = 300
  300 

Now type in MI

 MI
  300

To change the value of MI, you need only specify a new number after the equal sign: 
  
 MI = 329
  329 

This command causes Business Rules! to replace 300 with 329 in the MI folder. It will keep 329, or any value you specify, in the folder until you do one of the following: 
  
#Specify a new value for MI. 
#Enter a CLEAR command. 
#RUN a program. RUN automatically sets all variables to zero or zero length. 
#LOAD a new program. LOAD automatically performs a CLEAR function.
#Exit Business Rules!. 
  
Type in K = 10, then NEWPAGE. Next type in K + MI
  
 K + MI 
  339 

Even after NEWPAGE, the variables have their same value in temporary memory until you use the CLEAR command. 

You may be wondering why Business Rules! does these things without commands, so here's the default order in which Business Rules! processes the information that you enter into it, (remember that a COMMAND is executed immediately and a STATEMENT WITH A LINE # requires RUN): 

#After pressing ENTER, Business Rules! takes your information and looks 			for a line number. A line number would indicate that the information is a statement that is not to be executed until a RUN occurs. So if it has a line number, Business Rules! does not have to worry about it until RUN is executed.  
#If there is no line number, then Business Rules! checks to see if it is a temporary informational statement such as LET. If it is, BR! takes note of it in temporary memory, but the statement cannot be saved to disk without a line number. 
#If it is not just an informational statement, then BR! checks to see if it is an immediate statement or a command. PRINT is a statement that acts like a command when used without a line number. So do INPUT and STOP. These are immediate statements that Business Rules! executes immediately. Some of the commands in BR that are never used with a line number are SAVE, REPLACE, CLEAR, LOAD, RUN, ATTN, GO, etc. These commands are always executed immediately, but any statement can be run immediately as a command if you don’t use a line number.
#If Business Rules! does not understand the purpose of what you are typing in, it assumes that it is a PRINT statement asking to print either a number or a variable (like a print statement that does not include quotes). You can type in any jumble of letters, numbers, and underscores and Business Rules! will assume that you are trying to print a numeric variable. If any symbol characters are included in this jumble, you will get error message 1030 (Invalid Character Expression), because symbol characters cannot be included in the name of a variable (except for the $ sign at the end of string variables). If there is a dollar sign on the end, BR! assumes that you want it to print that string variable. If you type in a number without any non-numeric characters and press ENTER, BR! will print that number below like this: 
  
 123
  123

Also, if you type in a letter, word, or letter/number mix before an = sign and a number after the = sign, i.e. 

 Tiger = 10

this acts as a LET statement. "LET" doesn't need to be typed in. The statement assigns 10 to the numeric variable Tiger and the prints this value. The value for that variable stays in temporary memory until CLEAR is used. 

====Quick Quiz 3.8 ====
1) True or False - When you assign a value to a variable and Business Rules! prints the value, then it resets the value to zero. 

2) True or False - If you type any mix of letters, numbers, and characters without a command, Business Rules! will always PRINT what you typed out below as a default. 

`Answers 3.8`

====Challenge Questions ====
a)  What will happen if you delete line 70 from your MILEAGE program, and then RUN it? Make a guess, then try it and see. Use the command DEL 70 to delete line 70.

b)  Look at the suggested comments for program lines 1-5 in the section called "comment". These five lines form a title similar to the one that you created for your own MILEAGE program. What changes could you make to these lines so that the user sees the information every time the program is run?

c)  Study the following section of the program code carefully. The program assigns values to the variables MI, G, and MPG, and then prints the value of MPG. It next assigns new values to MI and G and again prints the value of MPG: 

 00010 LET MI=600 
 00020 LET GAL=30 
 00030 LET MPG=MI/GAL 
 00040 PRINT MPG 
 00050 LET MI=900 
 00060 LET GAL=25 
 00070 PRINT MPG 
 00080 STOP 

What number does Business Rules! print when it executes line 40? What number does it print when it executes line 70? Type this program into Business Rules! and RUN it to see if your answers are correct. 

ANSWERS: 

Type the program into Business Rules! and find out the answers for yourself!

`Challenge 3.8|Check them here`

====Chapter Exercise ====
Write a program that asks the user to type in 3 things: 
a)  An employee's last name. 
b)  An employee's annual salary. 
c)  An employee's percentage salary increase. 
Then the program should calculate how much will be added to user's salary after the percentage increase is added. 

For example, the user should be able to enter JOHNSON with an annual salary of 18000, and a salary raise of 12.4 percent. Your program should then calculate the amount of the raise in dollars, and then print output like the following 2 lines: 

JOHNSON has a current salary of 18000 
A raise of 12.4 percent will be 2232 dollars. 

Be sure that there is a message to the user before each INPUT statement, so that he or she knows what to enter. We have an example here for you TO COMPARE WITH YOURS after you've finished: 

Example Answer:

`image:3.9e.png`

;To challenge yourself further, modify this program to calculate what the employee’s salary will be over the next 5 or 10 years. 

`Solutions#CHAPTER 3|Solution`

NEXT:`Chapter 4|Constants and Variables`

`BR Tutorial|Back to Index`
