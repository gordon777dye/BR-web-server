# DATA STORE LIBRARY

## Quick Reference

- `FNPut_Object( object-name, string-variable$ )`
- `FNinsert_Object( object-name, string-variable$ )`
- `FNGet_Object( object-name, string-variable$ )`
- `FNSend_Object( object-name )`
- `FNDelete_Object( object-name )`
- `FNSend_string( string-variable$ )`
- `FNSend_Page( web-page-file-reference; mat args$, mat repl$ )`
- `FNPut_Json( fully-qualified-name, JSON-value-var$; must-exist-flag, as-is-flag )`
- `FNInsert_Json( fully-qualified-name, JSON-value-var$; as-is-flag )`
- `FNAppend_Json( fully-qualified-name, JSON-value-var$; as-is-flag )`
- `FNDelete_Json( fully-qualified-name; null-value-flag )`
- `FNGet_Json( fully-qualified-name, container-variable$; as-is-flag )`
- `FNCompile_Json( value-list-type, member-name, mat keys$, mat values$, container-variable$ [, quote_numeric_values] )`
- `FNCompile_Object( value-list-type, member-name, mat keys$, mat values$, object-name)`
- `FNParse_Json( string-expression, value-type, member-name, mat keys$, mat values$)`
- `FNParse_Object( object-name, value-type, member-name, mat keys$, mat values$)`

## DATA STORE

The WEB_SERVER program includes a data repository, called a data store. This enables your application to save data for processing on subsequent calls. Also, when you send information back to the web client, typically either JSON or HTML, you can place it into a named object and then FNSend_Object( object-name ).

**Data is received** from web clients in name-value pairs.  This is passed to your program as two arrays, MAT KEYS$ and MAT VALUES$. (Since BR matches parameters positionally, you can call them whatever you choose to. ) The data in MAT VALUES$ is a string that is either the value assigned to a URL parameter or the content of an HTML FORM field (POST data parameter value).  A value can be a complete JSON object. The maximum *key* length is 100. The maximum *value* length is 30,000. Values that came in the URL arrive in upper case, because BR's HTTP engine upper-cases the URL; POST data keeps its case. A POST with `Content-Type: application/json` arrives whole, as the parameter `JSON` (when it is no longer than 30,000 characters) and always as the data store object `POST_BODY` (up to 4 MB); see "JSON request bodies" in `03 BR WEB SERVER`.

### Data Store

String objects of any type, JSON or otherwise, may be stored in the data store. When the Web Server runs your function, the data store is the one belonging to the browser's **session**. It is kept on disk in `sessions\sesd<g>.dat`, beside the session's record in `sessions\sess<g>.dat`. Objects you store are there on the session's next request, whichever BR process answers it, and survive a restart. They are freed with the session (see "Sessions" in `03 BR WEB SERVER`). Another browser's session has its own store, and can't see yours. A request reads the store the first time it calls a data store function, and if it changed anything, writes it back before the response is sent. The object `POST_BODY` (a JSON request body) is the exception: it is never written to disk and lasts only for its own request. Use the object functions to work with non-JSON data or entire JSON objects, and the JSON functions when manipulating JSON data. Objects are referenced by their name. An object name may be up to 200 characters long, however a fully qualified JSON name (see JSON support below) may be up to 2000 characters long.

Object names are provided by you and do not need to describe object content. Object names are not case sensitive, but member names are. More than one object with the same name can be stored and subsequently referenced with *bracketed subscripts*.  Object names subscripted with brackets denote which instance within an *ordered list of that object* is being referenced. Note that this is different from subscripting member names. In this case the subscript refers to a list of entire objects. In JSON qualified names *member name subscripts* refer to values in lists associated with the member names.

While the Data Store Function Library is contained in the WEB_SERVER program, it is not necessary to use the web server in order to utilize the library support. But it does require BR 4.3 or later. Used that way, outside a request, the data store is held in memory only, as it was before 2.12.  LIBRARY statements contained in programs which are called by the web server that refer to data store functions should *omit* the library filename. This is because LIBRARY statements that name the library file create a separate instance of the library in memory. BR will search the loaded libraries for resolving linkage to functions in unnamed library statements.

All parameters are string expressions. Parameters that send and receive data must be passed as single string variables.  There are no maximum length restrictions on such variables. Other parameters may be literals or other expressions.

For debugging and educational  purposes, the variable names of the data store in the web_server program are MAT Objects$ and MAT Storage$. During a request they hold the session's store as read from disk (`FNDS_LOAD`), and they are written back by `FNDS_SAVE`. One `sesd<g>.dat` record holds one Storage$ element (up to 10,000 characters), keyed by session number and sequence.

### Object Storage and Access Functions

#### `FNPut_Object( object-name, string-variable$ )`

The named object is either created or replaced with string-value.  String-variable$ is passed by reference. *There are no arbitrary restrictions on length*.

e.g.  FNPut_Object(“Masco-invoice-005460”, JSON-string$ )

This creates an object named Masco-invoice-005460 and stores the content of JSON-string$ as its value. If an object with the same name exists, its value is replaced with JSON-string$ content.  Object-name can be any string expression. The string-variable$ is passed by reference, so only a single variable is permitted.  *The value can be any string and does not need to be JSON.*

#### `FNinsert_Object( object-name, string-variable$ )`

The named object is inserted ahead of any other object with the same (case insensitive) name and relative position within a group of like named objects, or if one is not pre-existent the object is created.

e.g.  FNInsert_Object(“Masco-invoice-005460”, string$ )

or    FNINSERT_OBJECT(“Invoice[4]”,string$ ) [ fourth object named “INVOICE”  ]

This creates an object and stores the content of string$ as its value. If the same object name exists, this instance is inserted ahead of it.

#### `FNGet_Object( object-name, string_variable$ )`

The value of the case insensitive named object is placed into string_variable$.

If the object named doesn’t exist then -10 is returned ( see error codes below ).

#### `FNSend_Object( object-name )`

The named object is sent to the current web client (the browser).

#### `FNDelete_Object( object-name )`

The named object is deleted.

## HTML Support

The Data Store Function Library supports HTML processing with the following functions:

#### `FNSend_string( string-variable$ )`

The content of string-variable (max 30,000 bytes) is sent to the client. Everything sent during one request, by FNSend_String, FNSend_Page and FNSend_Object, goes to the client as one response with one set of HTTP headers, so a page can be sent in pieces: a header page, then several strings, then a footer page.  FNSend_String is not content sensitive, so this is one way to send any HTML string to the client browser. If the client is a phone application it may be requesting data (typically JSON). In this case your program may need to send a block of data instead of HTML.

#### `FNSend_Page( web-page-file-reference; mat args$, mat repl$ )`

This sends the specified web page to the client. This action is not content sensitive, so the file can contain HTML or data. The optional array parameters contain string arguments and corresponding replacement values to be applied to the file content (in memory) before it is sent. The search and replacements are applied in the order given.

## JSON Support

### What Is JSON?

Classical Data Structure Definitions:

- arrays are element lists
- structures are member lists
- objects (classes) are structures with the addition of code (functions called methods)
- object members can be values, properties, events or methods
- property denotes type of value
- e.g. given a property called *name*, with a value M*able*, Mable would be the object’s name property

JSON stands for JavaScript Object Notation.  A JSON object consists of a structure JSON regards as an object:

- A JSON object is a brace enclosed list of zero or more comma separated pairs called members.
- Each pair consists of a "name" followed by a colon and a value such as:
- "name": value
- A value can be a "string", number, {JSON object}, [array of values], true, false, or null.
- The double quotes enclosing strings are a required part of JSON syntax. A double quote inside a string value is written as two double quotes, as in a BR string literal: `"say ""hi"""`. You can also give the text itself: `FNPut_Json("T.a.v", 'say "hi"')` stores `"say ""hi"""`, doubling the quotes as it adds the enclosing ones. A value that *begins* with a double quote is taken as a JSON string already written this way, and is stored as given. FNGet_Json returns a string as its text: without the enclosing quotes, and with `""` turned back into `"` (`say "hi"`). With the as-is-flag it returns the value exactly as stored (`"say ""hi"""`). Inside the data store, JSON's backslash escape (`\"`) is not used, and a backslash is ordinary data. At the web boundary the Web Server converts for you: standard JSON arriving in a request (`\"`, `\\`, `\n`) reaches your program in this form, and JSON you send with FNSend_String or FNSend_Object leaves in standard form. See "JSON is converted at the boundary" in `03 BR WEB SERVER`.
- An array is a comma separated list of values enclosed in brackets.
- Apostrophes are regarded as data. The only punctuation that is recognized is { } [ ] , " :

( JavaScript Object Notation formal specifications can be found at JSON.ORG. )

JSON Example:

```
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
```

### JSON Library Functions

#### `FNPut_Json( fully-qualified-name, JSON-value-var$; must-exist-flag, as-is-flag )`

The named JSON value is either created or replaced by the value in JSON-value-var$.  Pre-existing values are replaced whether the must-exist-flag is present or absent. If the member does not exist it is inserted unless the must-exist-flag is non-zero.

Fully-qualified-name is the name of an object followed by a period and the name of each *nested member* being referenced, separated by periods.

*Member names within the fully qualified name may also be subscripted.* When member names are followed by a bracketed number it indicates which of an ordered list of values associated with that name is being referenced. Note this subtlety because it is important.  Members are named pairs that appear in unordered lists. Zero or more values appear in ordered lists. Members are referenced by name. Values in lists are referenced by number.

Object names are not case sensitive, but member names are. Stored objects can be any string and are not content sensitive, but JSON objects must conform to a strict specification (at JSON.ORG). Object and member names may be up to 200 characters in length and a fully qualified name may be up to 2000 characters in length.

Examples

A Fully Qualified Name:  "**invoice[3].header.cust-name**"

This refers to the customer name in the third invoice object.

The object name is "invoice".

JSON for this scenario could be:

```
{"header":{
   "cust-name:":"Tom Peterson",
   "ship-to":{
      "name":"Advanced Systems",
      "street-addr": ...}}}
```

Another example:

"**I0004852.ship-to.street-addr[2]**"

This refers to the second ship-to street address element in the object named I0004852 (see below). The system finds the first object named I0004852 (case insensitive). Then it finds the member named “ship-to” within that object. The value set for the ship-to member is a set of members. The system then searches for the “street-addr” member within the ship-to value list. Next it finds the second value in the street-addr value ordered list.   Note that naming an object by its content (i.e. Invoice Number) is not required.

JSON for this scenario could be:

```
{"invc-num":"I0004852",
 "cust-name":"George Bradley",
 "ship-to":{
    "name":"Advanced Systems",
    "street-addr":["5471 Main Street","Rear Building"],
    "city":"Pittsburg",...}}
```

If a JSON-value does not begin with a double quote, a brace or a bracket, it is stored as a number only if it is written the way JSON writes numbers (RFC 8259): an optional minus sign, then `0` or a digit 1-9 followed by more digits, then an optional fraction (`.` and digits) and an optional exponent (`e` or `E`, an optional sign, and digits). Any other value is enclosed in double quotes when it is stored. So `5`, `-5`, `0.5`, `12.50` and `1e3` are stored as numbers, while `01234` (a leading zero, as in a zip code), `1,000`, `+5`, `.5`, `5.`, `true` and an empty value are stored as strings. A value longer than 100 characters is always quoted. The same rule applies to FNPut_Json, FNInsert_Json, FNAppend_Json and FNCompile_Json. Quoting can be suppressed with the as-is-flag, and FNCompile_Json's quote_numeric_values quotes numbers too. Note that single quotes (apostrophes) have no special significance and are regarded as normal data. Objects are not quoted when stored. Only values and field names are quoted.

#### `FNInsert_Json( fully-qualified-name, JSON-value-var$ )`

This is like Put  JSON except duplicates are appended instead of replacing original values. While inserting after really is appending, this action differs from FNAppend_Json in some important and subtle ways described in the FNAppend_Json section.

*More than one insertion of the same member name creates an array of values for that member.* The insertion routine will insert *after any pre-existing values* for members of the same name unless a subscript is given, in which case the new value is inserted at ( ahead ) of the referenced position.

FNPut_JSON and FNInsert_JSON examples:

Simple List: ( assumes  city$, state$ and zip$ are populated )

```
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     Fninsert_json("main-obj.address.city-st-zip",city$)
     fninsert_json("main-obj.address.city-st-zip",state$)
     fninsert_json("main-obj.address.city-st-zip",zip$)
```

Result:

```
     {"address":{“city-st-zip”:["Dallas","TX","11223"]}}
```

Unordered List of JSON Members – { }

```
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fninsert_json("main-obj.address.city-st-zip.city",city$)
     fninsert_json("main-obj.address.city-st-zip.state",state$)
     fninsert_json("main-obj.address.city-st-zip.zip",zip$)
```

Result:

```
{"address":{“city-st-zip”:{"city":"Dallas",
"state":"TX","zip":11223}}}
```

Ordered List of JSON Objects – [ ]

Subscripting indicates which item in a list is referenced. This causes each named pair to become its own JSON *member* enclosed in braces instead of an unadorned *named pair*.

```
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fninsert_json("main-obj.address.city-st-zip[1].city",city$)
     fninsert_json("main-obj.address.city-st-zip[2].state",state$)
     fninsert_json("main-obj.address.city-st-zip[3].zip",zip$)
```

Result:

```
{"address":{“city-st-zip”:[{"city":"Dallas"},
{"state":"TX"},{"zip":"11223"}]}}
```

#### `FNAppend_Json( fully-qualified-name, JSON-value-var$ )`

Append works exactly like insert with the following exceptions:

- When the low order member name is subscripted, indicating where in a list an insertion is to take place, the new value is inserted *after the specified value* instead of ahead of it.
- When the second from lowest ordered member name is subscripted (e.g. city-st-zip[].member-name), indicating a new member is being added, insert will create a separate member, whereas append will simply *add a named pair to the specified member*. See the following examples.

Create Member With Multiple Pairs Using Append

Note that this is the same result as FNInsert_JSON without subscripting.

```
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fnappend_json("main-obj.address.city-st-zip[1].city",city$)
     fnappend_json("main-obj.address.city-st-zip[1].state",state$)
     fnappend_json("main-obj.address.city-st-zip[1].zip",zip$)
```

Result:

```
{"address":{“city-st-zip”:{"city":"Dallas", 
      		"state":"TX","zip":11223}}}
```

Create Member With List of Multiple Members Using Insert

Since the subscript is not being incremented, each insertion is *ahead* of any existing value in the specified location. Therefore the sequence of fields is reversed.

```
     Fnput_json(“main-obj”,’{“address”:{}}’) ! init object
     fninsert_json("main-obj.address.city-st-zip[1].zip",zip$)
     fninsert_json("main-obj.address.city-st-zip[1].state",state$)
     fninsert_json("main-obj.address.city-st-zip[1].city",city$)
```

Result:

```
{"address":{“city-st-zip”:[{"city":"Dallas"}, 
            		{"state":"TX"},{"zip":"11223"}]}}
```

#### `FNDelete_Json( fully-qualified-name; null-value-flag )`

The specified JSON value is deleted. If the null-value-flag is set, the value is set to an empty string. If the null-value-flag is not set, the value is removed. If the value is not part of an ordered list (removing it from the list) then the member name and enclosing punctuation is removed, and if that leaves the parent with no value then it will be removed also.

#### `FNGet_Json( fully-qualified-name, container-variable; as-is-flag )`

The named JSON value is placed into the container-variable. If the as-is-flag is nonzero, string values returned are not trimmed of their outermost quotes.

### Creating JSON Objects

Two functions are provided for creating and parsing JSON objects and value sets independently from the data store.

#### `FNCompile_Json( value-list-type, member-name, mat keys$, mat values$, container-variable$ [, quote_numeric_values] )`

The first four parameters are compiled into a string which is returned in the container-variable.  Value-type$ must be either "{" or "[" and may be a literal. A valid JSON member or value list is created suitable for insertion into a JSON object. The type character refers to the type of value list only. *The overall type* (member {} or list []) *is determined by whether or not a non-null name is provided.* This can be a fast way to create a JSON object or member from a value array or a pair of key-value arrays.

If a member name is provided, then a member is created. The maximum length of an unqualified member name is 200 bytes.  If no member name is provided then a value set is created in accordance with the type. A value set can be an ordered list of one or more JSON values separated by commas and (if more than one) enclosed in brackets. Or a value set can be a brace enclosed unordered group of name-value pairs separated by commas.

If type is "[" then any keys provided indicate a brace enclosed independent key-value pair is to be inserted as the value.

If type is a "{" then null keys are not permitted and a member or unordered list is produced with one or more comma separated pairs enclosed in braces. This function returns the number of values successfully processed. If a string overflow error occurs, the negative return value indicates the element number where the error occurred.

Note that a brace enclosed list cannot be subscripted to reference particular values, but the names in the list are used as keys to reference particular values.  If **quote_numeric_variables** is greater than zero then all values in the compiled JSON will be quoted, otherwise only non-numeric values are quoted.

Examples of JSON Compilation

```
     Keys$(1) = “city” : Keys$(2) = “state” : Keys$(3) = “zip”
     Values$(1) = “Dallas” : Values$(2) = “TX” : Values$(3) = “11223”

     FNCOMPILE_JSON("{","city-st-zip",MAT KEYS$, MAT VALUES$, WORK$)
```

Result in Work$:

```
     {“city-st-zip”:{"city":"Dallas","state":"TX","zip":11223}}
```

```
     FNCOMPILE_JSON("[","city-st-zip",MAT KEYS$, MAT VALUES$, WORK$)
```

Result in Work$:

```
        {“city-st-zip”:[{"city":"Dallas"},{"state":"TX"},{"zip":11223}]}
```

List with only one key specified:

```
     let KEYS$(1) = KEYS$(2) = ""
     FNCOMPILE_JSON("[","city-st-zip",MAT KEYS$, MAT VALUES$, WORK$)
```

Result in Work$:

```
        {“city-st-zip”:["Dallas","TX",{"zip":11223}]}
```

#### `FNCompile_Object(value-list-type, member-name, mat keys$, mat values$, object-name)`

This works like FNCompile_Json except instead of producing a string, it stores the result in the specified object.

#### `FNParse_Json(string-expression, value-type, member-name, mat keys$, mat values$)`

String-expression is parsed into the remaining parameters. String can be either a member a value set. A value set can be a member with one or more named pairs, or a bracket enclosed list of values. Mat keys$ and mat values$ are redimensioned as needed. If a string overflow occurs, the subscript of the erroneous element is returned as a negative value.

Unlike FNCompile_Json, *value-type$ and member-name$ must be variables*.  String-expression may be any string expression no longer than 30,000 bytes.

#### `FNParse_Object( object-name, value-type, member-name, mat keys$, mat values$)`

This works like FNParse_Json except instead of parsing a string, it parses the specified object.

## Capacities

Combining many large rows into a giant JSON object is poor design and results in slower processing than using chunks (objects) less than 30,000 bytes long.  Therefore, for performance reasons, the maximum size JSON object, referenced in the compile and parse functions, has been set to 30,000 bytes. Also FNSend_String is limited to 30,000 bytes. (The limit was 50,000 in releases 1.89 and 1.90, and was lowered to work around a BR problem.)

Data moved to and from the Data Store is not size restricted by the program.  Such data is passed by reference. So if you need to send a string in excess of 30,000 bytes, store it and then send the stored object.

The Web Server output buffer capacity is 4 megabytes (4194304 bytes).

## Return Codes

| Code | Meaning |
|---|---|
| 1 | Success |
| 1++ | Number of array elements parsed |
| -10 | Object not found |
| -21 | First level member not found |
| -22 | Second level member not found |
| ... |  |
| -29 | Ninth level member not found |
| -31 | First level invalid member subscript |
| -41 | First level unbalanced quotes or braces |
| -50 | Page not found |
| -52 | Not a file |
| -54 | Cannot open page file |
| -60 | Object name contains a period |
| -80 | Invalid object subscript |
| -500 | The number of elements in the Keys$ array s not equal to those of mat values$. |
| -510 | Compile value-type$ is not "{" or "[". |
| -520 | Invalid JSON string. |
| -530 | A member key is null. |
| -540 | Data source is empty (null). |

If a string overflow occurs during compiling, parsing or retrieving, the return code will be the negative number of the name segment that was being processed when the error occurred.

e.g.  FNGET_JSON( “Invoice 1067.addr1.street”, STREET$ ) returns -3 if the value for street exceeds the dimensioned length of STREET$.

## Fixes in Recent Releases

If your programs run on an older web_server, these differences matter:

- **2.12: the data store is on disk, one per session.** Before 2.12, the data store was held in the memory of each BR process. Every client of that process shared one store, an object stored by one process was not seen by the others, and everything was lost when the process restarted. Now each session has its own store, in `sessions\sesd<g>.dat`. One client's objects can't be seen by another, so a program that used the store to pass data *between* clients must keep that data in a file of its own. `POST_BODY` now lasts only for its own request. Also fixed: reading an empty object after another object had been read returned that other object's contents.
- **2.11: quotes in text values, and what FNGet_Json returns.** Before 2.11, text containing a double quote, given without enclosing quotes (`'He said "hi"'`), was stored with its quotes as they were, which corrupted the object. FNGet_Json returned inner quotes still doubled (`say ""hi""`). It also stripped *every* quote at either end, so the string `"""hi"""` came back as `hi` instead of `"hi"`. Programs that undoubled the quotes themselves after FNGet_Json should stop doing so.
- **2.10: JSON request bodies.** Before 2.10, every POST body was treated as form data: URL-decoded (so `+` became a space and `%xx` was decoded) and split on `&` and `=`. A JSON body without `=` never reached the program, and the server wrote "Parameter missing '=' char" into the response. POST data was limited to 100,000 characters.
- **2.09: standard JSON at the web boundary.** Before 2.09, JSON was sent to clients in the store's form, with `""` inside strings, raw backslashes and raw line breaks. Standard JSON parsers such as a browser's `JSON.parse` reject that. JSON responses were also sent with no `Content-Type` header, because the test that should have marked them `application/json` never matched. Standard JSON arriving in a request reached your program unconverted. A program that built standard JSON by hand, with `\"`, now has its backslashes escaped on the way out; it should write `""` instead.
- **2.08: member lookup past string values containing `,` `}` or `]`.** Before 2.08, when a member followed another member whose quoted value contained one of those characters, the JSON functions could not find it. With `{"a":{"p":"1,000","q":"x"}}`, `FNPut_Json("W.a.q", Y$)` added a second `"q"` instead of replacing the first. With `"p":"a}b"`, it wrote into the middle of that string and corrupted the object. FNGet_Json and FNDelete_Json returned "member not found" (-22). A value with doubled quotes followed by a comma, such as `"say ""hi"", ok"`, was also misread: FNGet_Json returned it cut short, and FNDelete_Json corrupted the object.
- **2.07: JSON value quoting.** Before 2.07, negative numbers, `0` and decimals such as `0.5` were stored as strings, and `5.` was stored unquoted. FNCompile_Json lists could produce invalid JSON such as `{"zip":01234}`. FNInsert_Json of a whole object at a subscript that does not exist stopped BR with error 0122 instead of returning -80.
