---
title: Connecting_to_browsers_online_Tutorial
file: Connecting_to_browsers_online_Tutorial.md
category: 60-integration
subcategory: 60-integration/web
kind: tutorial
related: []
---
BR can also be connected to websites (and therefore also smart phones) to display or accept information. This is completed by using simple html and css. Studying these languages is recommended in order to maximize the benefits of connecting your BR programs to a web page. 

===A simple overview of how a website works=== 
A website is simply a text document written in HTML and CSS. Your web browser reads the text document, and follows the instructions on what to display and how to display it. When you click on or open something, it sends a message to the webserver which changes what HTML is sent back to your browser, to determine what is to be displayed next. You can use BR as the language at the webserver to do this (instead of PHP etc). 

BR sends HTML code to the user's browser to determine what is displayed on their screen. When the user enters information, it is sent back to your BR program and then can be used as you like. 

There are three rings in this circus: the HTML based webpage, the BR webserver, and the BR program that you are writing. Each is described below as you build your very first web-connected BR program.

===Step 1===
To start with, you'll need BR's WEB_SERVER12.BR program, which works as a server to connect BR to a webpage. Run this every time you update your BR program. Errors that occur when testing your webpage will be listed in the BR Server program. Also, using the BR WebForm library is highly recommended (though not necessary), which provides the user-defined functions which will make the whole process much easier. Remember that if you use the library, you must reference it in your BR program.

There are two ways to go about this: the first is by creating a webpage using HTML in a text editor and then adding functions which run your BR program; the second is writing (or using the Webform library's) functions to send HTML to a very simple text document. We will briefly go over both of them, the main difference is where the majority of your html text is stored. 

===Step 2===
Create a simple webpage using html. This can be done in any text editor and should be saved in the www folder under the title index.html for the Webserver to access. Any pictures or css files that are used in your webpage should also be in this folder. If you are unfamiliar with the basics of HTML, tutorials are available online, for example at www.w3schools.org. For the purposes of this tutorial, you may want to just borrow from the sample available on the 
`Solutions 2#10.3 Sample webpage|solutions` page. 

Basically, you will need to create a portion of the webpage with a form for input. 

In order to receive the input from the user via a form on the webpage to your BR program, you will need a line like this to run the function:

 <form action="?BR_FUNC=fnTravelSurvey" method="get">
 
 ....
 
 </form> 

The question mark is required. BR_FUNC communicates with the BR server. The fnTravelSurvey is the name of the function and the method can be “get” or “post”. When input from a webform is sent, it can be done two ways: POST is more secure, and GET is the default, and is less secure because the input shows up in the address like this: %YES%. </form> must be placed at the end of your form to close it. 

Each line of your form will require something like this line, which demonstrates how to set variables from your index to describe the data a user will enter:

 <input type="text" value="name" name="namefield" cols="20">

In this case it allows text input. value=”name” is the text that will be in the field waiting until the user inputs something else. name=“namefield” provides the variable name, which can be referenced in your BR program. Cols and rows can be set to determine the size of the text box. 

Your HTML must also have a submit line like this, which will provide a button called 'Click to Record' to send the information to your BR program:

 <input type="submit" value="Click to Record">

===Step 3===
Lastly, this line in your index.html will reference the BR function entitled ThankYouPage, which provides them with a confirmation that their input was received: 

 <nowiki>
 <p><a href="?BR_FUNC=fnthankyoupage"</a>Click to go to the page named ThankYouPage</p>
 </nowiki> 

A second way to do all this is entirely from your BR program using the function fnHTML (and others) to write the html to your webpage. The final portion of our sample page demonstrates this.

===Step 4===
So far, we've covered the HTML text side of this connection. Next, let's look at the BR program that will make sense of the input from the webpage and send information back to it. Remember that you must dim the values and reference the library. 

Since fnTravelSurvey was referenced on our page, we will need to define it in the BR program. 

 def library fntravelsurvey(mat Keys$,mat Values$)

mat Keys$ and mat Values$ will allow you to change the subsripts and variables added into names that are easier to work with:

 let fnRequestSubs(mat Keys$)

Web_server12 will record the user's input from the webpage and send it to your BR program. It sends it with a subscript value, which needs to be changed into a more usable variable name. Here we provide a function that will do it for you, put it at the bottom of your program:

 dim RequestSubscripts$(1)*800
 RequestSubs: ! This function sets the subscripts for the request string
 def FnRequestSubs(Mat Subs$;___,Index)
    library "webform" : fnBuildSubsList
    let fnBuildSubsList(mat Subs$,mat RequestSubscripts$,"R_")
    for Index=1 to Udim(Mat RequestSubscripts$)
       execute RequestSubscripts$(Index)
    next Index
 fnend

Then, use mat Value$ to rename your variables as follows. The “R_” portion is what fnrequestsubs recognizes and works with:

 let fnRequestSubs(mat Keys$)
        if r_dallas then dallas$=values$(r_dallas)
        if r_stlouis then stlouis$=values$(r_stlouis)
        if r_sanfran then sanfran$=values$(r_sanfran)
 
        if r_one then one$=values$(r_one)
        if r_two then two$=values$(r_two)
        if r_more then more$=values$(r_more)
        if r_commentfield then commentfield$=values$(r_commentfield)

For this sample program, the values entered are then saved to a file, so next, open and write to the file. (See solutions if you need help). 

The last portion of the website, which references fnThankyoupage, is handled like this:

 <nowiki> library "webform":fnhtml,fnHeading,fnfooter,fnsend</nowiki> 
 <nowiki>    let fnHeading("Thank You")</nowiki> 
 <nowiki>   let fnHTML("<h1>Thank You</h1>")</nowiki> 
 <nowiki>   let fnHTML("<p>We appreciate your input and will keep it in our records.</p>")</nowiki> 
 <nowiki>   let fnHTML("<p>Click <a href=index.html>here</a> to go back to the main page.</p>")</nowiki> 
 <nowiki>   let fnFooter</nowiki> 
 <nowiki>   let fnSend</nowiki> 

See the webform library for details about how each of these functions work.

===Step 5===
The last piece of the puzzle is the Brserver. Using Web_server12.br as a server will connect your website and your BR programs. Load and run after making any changes to your index.html file. Web_server12.br needs to recognize and access the functions in your program. This is how it works:

Edit the .ini file to resemble this, where Websample.br is the name of your program, and fnfirstpage and fntheysavedit are the functions called from your HTML text page:

 url_base=www
 logfile=weblog.txt
 debugfile=webdebug.txt
 library=websample.br,functions=fnfirstpage,fntheysavedit

Next, run the webserver. Open your web browser and put LOCALHOST in the address bar. Your webpage should appear and run perfectly. If errors occur, the webserver program will beep and show you the error number and line number.

===Test===
To test your results, you may want to create a short program that will print the contents of the file where these values are stored.
