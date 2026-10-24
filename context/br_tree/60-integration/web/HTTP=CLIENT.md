---
title: HTTP=CLIENT
file: HTTP=CLIENT.md
category: 60-integration
subcategory: 60-integration/web
kind: reference
related: [Open Display, CURL, HTTP]
---
HTTP INPUT/OUTPUT

The `Open Display|OPEN` string for DISPLAY files requires a parameter called HTTP=CLIENT. The CLIENT designation denotes processing in the following sequence:  

1) HTTP=CLIENT
#OPEN 
##NAME=Full URL - web page or service reference -
##CONTROL= optional display filename
#[ PRINT ] Optional - accumulate post data.
#[ PRINT ] Optional - additional post data. When the first LINPUT is issued POSTing of all print lines occurs and all responses are buffered before the LINPUT returns data. If no POST data is provided (no PRINT is issued) GET is used at LINPUT instead of POST. 
#LINPUT - until EOF is reached or until another PRINT is issued. A PRINT clears the LINPUT buffer.

Processing must be performed in the above sequence or an error is generated. 

FILE$(fileno,”HTTPINFO”) returns LOG info for the latest action.

2) CONTROL STATEMENTS    (case insensitive)

LOG filename - Writes all HTTPINFO messages and the RESULTS string into filename.

USER-AGENT  string - Specifies  the  User-Agent string to send to the HTTP server. Some badly done CGIs fail if its  not  set to "Mozilla/4.0".  To encode blanks in the string, surround the string with single quote marks.

REFERER - the linked-from URL

COOKIE-OUT  “NAME=data” - For example, “NAME1=value1; NAME2=value2" 

COOKIE-FILE-OUT - If  no '=' letter is used in the line, it is treated as a filename to use to read previously stored cookie lines  from, which should be used in this session if they match. Using this method also activates the "cookie  parser" which will record incoming cookies too, which may be handy if you're using this in combination with the -L/--location  option. The file format of the file to read cookies from should be plain HTTP headers or the Netscape/Mozilla cookie file format. 

NOTE - that the file specified with COOKIE is only used as input. No cookies will be stored in the file. To store cookies, save the HTTP headers to a file using DUMP-HEADER.

COOKIE-FILE-IN filename - The name of a file that is to contain a copy of all cookies encountered either inbound or outbound.

DATA filename - This is an alternative to PRINT to be used when significant amounts of data are stored in files in FORM format (keyword / vale pairs ). 

Sends  the  specified data in a POST request to the HTTP server, in a way that can emulate as if a user has filled in a HTML form and pressed the submit button. The data is sent exactly as specified with all newlines cut off. It is expected to be "url-encoded". This will cause curl to pass the data to the server using the content-type application/x-www-form-urlencoded. If more than one DATA option is used on the same command line, the data pieces specified  will be merged together with a separating semicolon. Thus, using 'DATA name=daniel skill=great' would generate a post chunk that looks like 'name=daniel&amp;skill=great'. 

If you start the data with the letter @, the rest should be a file name to read the data from. The contents of the file must already be url-encoded. Multiple files can also be specified. Posting data from a file named 'footbar' would thus be done with "DATA @footbar".

HEADER additional header parameters - Extra header to use when getting a web page. You may specify any number of extra headers.

DUMP-HEADERS filename - Write  the HTTP headers to this file.

HEAD – retrieve headers only

SSLV2 -  force SSL version 2
SSLV3 -  force SSL version 3

RESULTS string - Logs a string with the following optional substitution values:

<B>url_effective</B>  The URL that was fetched last.  

<B>http_code</B>  The numerical code that was found in the last retrieved HTTP(S) page.

<B>time_total</B>  The  total  time,  in  seconds, that the full operation lasted. The time will  be displayed with millisecond resolution.

<B>time_namelookup</B>  The  time,  in seconds, it took from the start until the name resolving was completed.

<B>time_connect</B>   The  time,  in seconds, it took from the start until the connect  to  the  remote host (or proxy) was completed.

<B>time_pretransfer</B>  The  time,  in seconds, it took from the start until the file  transfer  is  just about  to  begin. This includes all pre-transfer commands and negotiations  that are  specific  to  the particular protocol(s) involved.

<B>time_starttransfer</B>  The time, in seconds, it took  from  the start until the first byte is just about to be transfered.   This includes time_pretransfer  and  also the time the server needs to calculate the result. 
<B>size_download</B>  The total amount of bytes that were downloaded.

<B>size_upload</B>  The total amount of bytes that were uploaded.

<B>size_header</B>  The total amount of bytes of  the downloaded headers.

<B>size_request</B>  The total amount of bytes that were sent in the HTTP request.

<B>speed_download</B> The average download speed that BR measured for the complete download.

<B>speed_upload</B>  The average upload speed that BR measured for the complete upload.

<B>content_type</B>   The Content-Type of the requested  document, if there was any.
