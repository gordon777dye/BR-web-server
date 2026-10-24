---
title: Json
file: Json.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: []
---
`http://brforum.brulescorp.com/viewtopic.php?p=3358#p3358`

Quick Reference

	FNPut_Object( object-name, string-variable$ )

	FNinsert_Object( object-name, string-variable$ )

	FNGet_Object( object-name, string-variable$ )

FNSend_Object( object-name [, suppress_header, suppress_length] ))

FNDelete_Object( object-name )

	FNSend_string( string-variable$ [, suppress_header, suppress_length] ))

	FNSend_Page( web-page-file-reference; mat args$, mat repl$ 
							[, suppress_header, suppress_length] )

FNPut_Json( fully-qualified-name, JSON-value-var$; must-exist-flag, as-is-flag )

FNInsert_Json( fully-qualified-name, JSON-value-var$; as-is-flag )

FNAppend_Json( fully-qualified-name, JSON-value-var$; as-is-flag )

FNDelete_Json( fully-qualified-name; null-value-flag )

FNGet_Json( fully-qualified-name, container-variable$; as-is-flag )

FNCompile_Json( value-list-type, member-name, mat keys$, mat values$, container-variable)

FNCompile_Object( value-list-type, member-name, mat keys$, mat values$, 
fully-qualified-name)

FNParse_Json( string-expression, value-type, member-name, mat keys$, mat values$)

FNParse_Object( object-name, value-type, member-name, mat keys$, mat values$)

DATA STORE

The WEB_SERVER program includes a data repository, called a data store. This enables your application to save data for processing on subsequent calls. Also, when you send information back to the web client, typically either JSON or HTML, you can place it into a named object and then FNSend_Object( object-name ).  

Data is received from web clients in name-value pairs.  This is passed to your program as two arrays, MAT KEYS$ and MAT VALUES$. (Since BR matches parameters positionally, you can call them whatever you choose to. ) The data in MAT VALUES$ is a string that is typically either the value assigned to a parameter or the content of an HTML FORM field. When supporting iPad or smart phone applications a value can be a complete JSON object. The maximum key length is 50. The maximum value length is 5000. 

String objects of any type, JSON or otherwise, may be stored in the data store, which is retained only in server memory. Such objects are referenced by their name. More than one object with the same name can be stored and subsequently referenced with bracketed subscripts.  An object name may be up to 200 characters long. 

While the Data Store Function Library is contained in the WEB_SERVER program, it is not necessary to use the web server to utilize the library support. But it does require BR 4.3 or later.  Although the library works with both 32 and 64 bit BR versions, the web server presently only works with the 32 bit model. Also LIBRARY statements contained in programs which are called by the web server that refer to data store functions should omit the library filename. This is because LIBRARY statements that name the library file create a separate instance of the library in memory. 

All parameters are string expressions. Parameters that send and receive data must be passed as single string variables.  Other parameters may be literals or other expressions.  Object names are provided by you and do not need to describe object content.  They are not case sensitive. 

Object Storage and Access Functions

	FNPut_Object( object-name, string-variable$ )

The named object is either created or replaced with string-value.  String-variable$ is passed by reference. There are no arbitrary restrictions on length. 

e.g.  FNPut_Object(“Masco-invoice-005460”, JSON-string$ )

This creates an object named Masco-invoice-005460 and stores the content of JSON-string$ as its value. If an object with the same name exists, its value is replaced with JSON-string$ content.  Object-name can be any string expression. The string-variable$ is passed by reference, so only a single variable is permitted.  The value can be any string and does not need to be JSON. 

	FNinsert_Object( object-name, string-variable$ )

The named object is inserted ahead of any other object with the same (case insensitive) name and relative position within a group of like named objects, or if one is not pre-existent the object is created.

e.g.  FNInsert_Object(“Masco-invoice-005460”, string$ )
or    FNINSERT_OBJECT(“Invoice[4]”,string$ )	[ fourth object named “INVOICE”  ]
This creates an object and stores the content of JSON-string$ as its value. If the same object name exists, this instance is inserted ahead of it. 

FNGet_Object( object-name, string_variable$ )

The value of the case insensitive named object is placed into string_variable$. 

If the object named doesn’t exist then -10 is returned ( see error codes below ).  

If a string overflow occurs during compiling, parsing or retrieving, the return code will be the negative number of the name segment that was being processed when the error occurred.  
e.g.  FNGET_JSON( “Invoice 1067.addr1.street”, STREET$ ) returns -3 if the value for street exceeds the dimensioned length of STREET$. 

FNSend_Object( object-name [, suppress_header, suppress_length] ))

The named object is sent to the current HTTP client.  (See HTTP Header discussion below)

FNDelete_Object( object-name )

The named object is deleted.

HTML Support

The Data Store Function Library supports HTML processing with the following functions:

	FNSend_string( string-variable$ [, suppress_header, suppress_length] ))

The content of string-variable (max 30,000 bytes) is sent to the client. The action is not content sensitive, so this is one way to send any HTML string to the client browser. If the client is a phone application it may be requesting data. In this case your program may need to send a block of data instead of HTML.   (See the HTTP Header discussion below)

	FNSend_Page( web-page-file-reference; mat args$, mat repl$ 
						[, suppress_header, suppress_length] ))

This sends the specified web page to the client. This action is not content sensitive, so the file can contain HTML or data. The optional array parameters contain string arguments and corresponding replacement values to be applied to the file content (in memory) before it is sent. The search and replacements are applied in the order given.    (See HTTP Header discussion below)
JSON Support

What Is JSON?
Classical Data Structure Definitions:
•	arrays are element lists
•	structures are member lists

•	objects (classes) are structures with the addition of code (functions called methods)
•	object members can be values, properties, events or methods
•	property denotes type of value or refers to an actual individual value
•	e.g. given a property called name, with a value Mable, Mable would be the object’s name property

JSON stands for JavaScript Object Notation.  A JSON object consists of a structure JSON calls an object:
•	A JSON object is a brace enclosed list of zero or more comma separated pairs called members.
•	Each pair consists of a "name" followed by a colon and a value.  e.g.  "name": value
•	A value can be a "string", number, {JSON object}, [array of values], true, false, or null.
•	The double quotes enclosing strings are a required part of JSON syntax.
•	An array is a comma separated list of values enclosed in brackets.
•	Apostrophes are regarded as data. The only punctuation that is recognized is { } [ ] , " :
( JavaScript Object Notation formal specifications can be found at JSON.ORG. )

JSON Example:

{"widget": {
    "debug": "on",
    "window": {
        "title": "Sample Konfabulator Widget",
        "name": "main_window",
        "width": 500,
        "height": 500
    },
    "image": { 
        "src": "Images/Sun.png",
        "name": "sun1",
        "hOffset": 250,
        "vOffset": 250,
        "alignment": "center"
    },
    "text": {
        "data": "Click Here",
        "size": 36,
        "style": "bold",
        "name": "text1",
        "hOffset": 250,
        "vOffset": 100,
        "alignment": "center",
        "onMouseUp": "sun1.opacity = (sun1.opacity / 100) * 90;"
    }
}}

JSON Library Functions

FNPut_Json( fully-qualified-name, JSON-value-var$; must-exist-flag, as-is-flag )

The named JSON value is either created or replaced by the value in JSON-value-var$.  If the member does not exist it is inserted unless the must-exist-flag is non-zero. 

Fully-qualified-name is the name of an object followed by a period and the name of each nested member being referenced, separated by periods.  Object names are provided by you and do not need to describe object content. Duplicate object names may be subscripted with brackets denoting which instance within an ordered list of that object is being referenced.  

Member names within the fully qualified name may also have subscripted values. When member names are followed by a bracketed number it indicates which of an ordered list of values associated with that name is being referenced. Note this subtlety because it is important.  Members are named pairs that appear in unordered lists. Zero or more values appear in ordered lists. Members are referenced by name. Values are referenced by number. 

Object names are not case sensitive, but member names are. Stored objects can be any string and are not content sensitive, but JSON objects must conform to a strict specification (at JSON.ORG). Object and member names may be up to 200 characters in length and a fully qualified name may be up to 2000 characters in length. 

Examples  
A Fully Qualified Name:  "invoice[3].header.cust-name"

This refers to the customer name in the third invoice object.
The object name is "invoice".
 
JSON for this scenario could be:
{"header":{
   "cust-name:":"Tom Peterson",
   "ship-to":{
      "name":"Advanced Systems",
      "street-addr": ...}}}

e.g. "I0004852.ship-to.street-addr[2]"

This refers to the second ship-to street address element in the object named I0004852. The system finds the first object named I0004852 (case insensitive). Then it finds the member named “ship-to” within that object. The value set for the ship-to member is a set of members. The system then searches for the “street-addr” member within the ship-to value list. Next it finds the second value in the street-addr value ordered list.   Note that naming an object by its content (i.e. Invoice Number) is not required. 

JSON for this scenario could be:
{"invc-num":"I0004852",
 "cust-name":"George Bradley",
 "ship-to":{
    "name":"Advanced Systems",
    "street-addr":["5471 Main Street","Rear Building"],
    "city":"Pittsburg",...}}

If a JSON-value is not quoted, BR tests it for a valid numeric content by using VAL(). If VAL() produces a conversion error, the value will automatically be enclosed in double quotes when it is stored. This feature can be suppressed with the as-is-flag. Note that single quotes (apostrophes) have no special significance and are regarded as normal data. Objects are not quoted when stored. Only values and field names are quoted. 

FNInsert_Json( fully-qualified-name, JSON-value-var$ )

This is like Put  JSON except duplicates are appended instead of replacing original values. While inserting after really is appending, this action differs from FNAppend_Json in some important and subtle ways described in the FNAppend_Json section. 

More than one insertion of the same member name creates an array of values for that member. The insertion routine will insert after any pre-existing values for members of the same name unless a subscript is given, in which case the new value is inserted at ( ahead ) of the referenced position. 

FNPut_JSON and FNInsert_JSON examples:
Simple List:	( assumes  city$, state$ and zip$ are populated )
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     Fninsert_json("main-obj.address.city-st-zip",city$)
     fninsert_json("main-obj.address.city-st-zip",state$)
     fninsert_json("main-obj.address.city-st-zip",zip$)
Result:
     {"address":{“city-st-zip”:["Dallas","TX","11223"]}}
     
Unordered List of JSON Members – { }
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fninsert_json("main-obj.address.city-st-zip.city",city$)
     fninsert_json("main-obj.address.city-st-zip.state",state$)
     fninsert_json("main-obj.address.city-st-zip.zip",zip$)
Result:
{"address":{“city-st-zip”:{"city":"Dallas",
"state":"TX","zip":11223}}}

Ordered List of JSON Objects – [ ]
Subscripting indicates which item in a list is referenced. This causes each named pair to become its own JSON member enclosed in braces instead of an unadorned named pair. 
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fninsert_json("main-obj.address.city-st-zip[1].city",city$)
     fninsert_json("main-obj.address.city-st-zip[2].state",state$)
     fninsert_json("main-obj.address.city-st-zip[3].zip",zip$)
Result:
{"address":{“city-st-zip”:[{"city":"Dallas"},
{"state":"TX"},{"zip":"11223"}]}}

FNAppend_Json( fully-qualified-name, JSON-value-var$ )

  Append works exactly like insert with the following exceptions:
  
•	When the low order member name is subscripted, indicating where in a list an insertion is to take place, the new value is inserted after the specified value instead of ahead of it.
•	When the second from lowest ordered member name is subscripted (e.g. city-st-zip[].member-name), indicating a new member is being added, insert will create a separate member, whereas append will simply add a named pair to the specified member. See the following examples. 

Create Member With Multiple Pairs Using Append
Note that this is the same result as FNInsert_JSON without subscripting. 
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fnappend_json("main-obj.address.city-st-zip[1].city",city$)
     fnappend_json("main-obj.address.city-st-zip[1].state",state$)
     fnappend_json("main-obj.address.city-st-zip[1].zip",zip$)

Result:
{"address":{“city-st-zip”:{"city":"Dallas", 
      		"state":"TX","zip":11223}}}

Create Member With List of Multiple Members Using Insert
Since the subscript is not being incremented, each insertion is ahead of any existing value in the specified location. Therefore the sequence of fields is reversed. 
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fninsert_json("main-obj.address.city-st-zip[1].zip",zip$)
     fninsert_json("main-obj.address.city-st-zip[1].state",state$)
     fninsert_json("main-obj.address.city-st-zip[1].city",city$)
Result:
{"address":{“city-st-zip”:[{"city":"Dallas"}, 
            		{"state":"TX"},{"zip":"11223"}]}}

FNDelete_Json( fully-qualified-name; null-value-flag )

The specified JSON value is deleted. If the null-value-flag is set, the value is set to an empty string. If the null-value-flag is not set, the value is removed. If the value is not part of an ordered list (removing it from the list) then the member name and enclosing punctuation is removed, and if that leaves the parent with no value then it will be removed also.

FNGet_Json( fully-qualified-name, container-variable; as-is-flag )

The named JSON value is placed into the container-variable. If the as-is-flag is nonzero, string values returned are not trimmed of their outermost quotes.

Creating JSON Objects
Two functions are provided for creating and parsing JSON objects and value sets independently from the data store. 

FNCompile_Json( value-list-type, member-name, mat keys$, mat values$, container-variable)

The first four parameters are compiled into a string which is returned in the container-variable.  Value-type$ must be either "{" or "[" and may be a literal. A valid JSON member or value list is created suitable for insertion into a JSON object. The type character refers to the type of value list only. The overall type (member {} or list []) is determined by whether or not a non-null name is provided. This can be a fast way to create a JSON object or member from a value array or a pair of key-value arrays. 

If a member name is provided, then a member is created. If no member name is provided then a value set is created in accordance with the type. A value set can be an ordered list of one or more JSON values separated by commas and (if more than one) enclosed in brackets. Or a value set can be a brace enclosed unordered group of name-value pairs separated by commas. 

If type is "[" then any keys provided indicate a brace enclosed independent key-value pair is to be inserted as the value. 

If type is a "{" then null keys are not permitted and a member or unordered list is produced with one or more comma separated pairs enclosed in braces. This function returns the number of values successfully processed. If a string overflow error occurs, the negative return value indicates the element number where the error occurred.
  
Note that a brace enclosed list cannot be subscripted to reference particular values, but the names in the list are used as keys to reference particular values.
Examples of JSON Compilation
     Keys$(1) = “city” : Keys$(2) = “state” : Keys$(3) = “zip”
     Values$(1) = “Dallas” : Values$(2) = “TX” : Values$(3) = “11223”

     FNCOMPILE_JSON("{","city-st-zip",MAT KEYS$, MAT VALUES$, WORK$)
Result in Work$:
     {“city-st-zip”:{"city":"Dallas","state":"TX","zip":11223}}

     FNCOMPILE_JSON("[","city-st-zip",MAT KEYS$, MAT VALUES$, WORK$)
Result in Work$:
        {“city-st-zip”:[{"city":"Dallas"},{"state":"TX"},{"zip":11223}]}

List with only one key specified:
     let KEYS$(1) = KEYS$(2) = ""
     FNCOMPILE_JSON("[","city-st-zip",MAT KEYS$, MAT VALUES$, WORK$)
Result in Work$:
        {“city-st-zip”:["Dallas","TX",{"zip":11223}]}

FNCompile_Object(value-list-type, member-name, mat keys$, mat values$, 
fully-qualified-name)

This works like FNCompile_Json except instead of producing a string, it stores the result in the specified object element. 

FNParse_Json(string-expression, value-type, member-name, mat keys$, mat values$)

String-expression is parsed into the remaining parameters. String can be either a member a value set. A value set can be a member with one or more named pairs, or a bracket enclosed list of values. Mat keys$ and mat values$ are redimensioned as needed. If a string overflow occurs, the subscript of the erroneous element is returned as a negative value. 
  
Unlike FNCompile_Json, value-type$ and member-name$ must be variables.  String-expression may be any string expression no longer than 30,000 bytes. 

FNParse_Object( object-name, value-type, member-name, mat keys$, mat values$)

This works like FNParse_Json except instead of parsing a string, it parses the specified object. 

Capacities
Note that the configuration file stack size should be 500000 or greater. Combining many large rows into a giant JSON object is poor design and results in slower processing than using chunks (objects) less than 100k long.  Therefore the maximum size JSON object supported by the JSON compiler has been set to 300000 bytes. The limit of data stored in multiple objects is 100 megabytes. Objects are stored in 5000 byte increments.

HTTP Headers
In addition to HTML headers, HTTP (the web transport protocol) has its own headers that the BR Web Server automatically applies ahead of the HTML. This HTTP header normally specifies the length of the data object (e.g. HTML or JSON) that follows it. However, if the total data length of all parts is not known (as when looping through a data file), it is permissible to send a header without the length. The facility is provided to suppress the entire header or just the length. 

The first send operation in the preparation of a web page should not suppress headers. All remaining send operations must suppress headers or BR will insert a HTTP header in the middle of your HTML. 
Additionally, when more than one send is used to compile a web page, the first send should suppress the length specification.  This is done by placing a nonzero value in the SUPPRESS_LENGTH parameter.

e.g.
To send the first part of an order display web page suppressing the length in the HTTP header:
FNSend_Page( order_header.html, mat args$, mat repl$, 0, 1 )

This might be followed with one or more send_strings and then another send_page for the footer.

HTTP headers also indicate the type of content being sent to the browser. BR specifies “text/html” if the first non-space character is a less-than symbol ( < ).  If the first character is a brace ( { ), bracket ( [ ) or quote ( “ ) then BR specifies content type “application/json”.  If it is none of these, content type is omitted from the HTTP header. Note that this only applies to the first send operation or a group because thereafter HTTP headers should be suppressed. 

Return Codes

1	Success
1++	Number of array elements parsed

-10	Object not found

-21	First level member not found
-22	Second level member not found
...
-29	Ninth level member not found

-31	First level invalid member subscript
-41	First level unbalanced quotes or braces
-50	Page not found
-52	Not a file
-54	Cannot open page file	
-60	Object name contains a period
-80	Invalid object subscript

-500    The number of elements in the Keys$ array s not equal to those of
        mat values$.
-510    Compile value-type$ is not "{" or "[".
-520    Invalid JSON string.
-530    A member key is null.
-540    Data source is empty (null).

If a string overflow occurs during compiling, parsing or retrieving, the return code will be the negative number of the name segment that was being processed when the error occurred.  
e.g.  FNGET_JSON( “Invoice 1067.addr1.street”, STREET$ ) returns -3 if the value for street exceeds the
