---
title: RD
file: RD.md
category: 00-configuration
subcategory: 00-configuration/config-directives
kind: config-directive
related: [BRconfig.sys, AIDX, DIDX, INT, IP, STR$, Internal Functions, SORT, RECORD, IF]
---
The **RD** `BRconfig.sys` specification sets the tolerance level for assuming two values are equal. The value of the RD specification affects operation of the `AIDX`, `DIDX`, `INT` X, `IP` X and `STR$` `Internal Functions`, the `SORT` utility's `RECORD` specification, numeric comparisons used in `IF` and `FOR` `statements`, and the printing of a number in default format (PRINT X).

(Not available in BR! Version `4.03`jx or before)

====Comments and Examples====
Business Rules floating point numbers are precise up to the first 15 digits, whether the digits occur before or after the decimal point. The value of the RD specification indicates how many decimal digits should be considered meaningful in numeric comparisons. And when formatting a numeric value for output it rounds at the RD position. It has no effect on internal mathematical processing.

For most applications, the RD default should be used. The RD specification is only needed when the data includes very large numbers (100 million or greater) or very small numbers (less than .00001).

If changing the RD value is necessary, it is important that you change it properly. Using an RD value that is too high could cause unpredictable and invalid results. Using an RD value that is too low could cause Business Rules to overlook a significant difference between two numbers.

The best way to determine the appropriate setting for your needs is to find the largest number, with the most number of decimal positions, that your application will be using in numeric comparisons (remember, RD has no effect on actual math performed internally). Starting from the left-most digit of the number, you should then count 15 digits to the right and draw a line after that digit. (If there are less than 15 digits in your number, draw a line after the last digit.) Now, count the number of digits between the decimal point and your line. Subtract at least one, but preferably two. The number you end up with is the RD setting you should specify.

For example, assume that the following number is the largest that would be used in numeric comparisons for a particular application.

 123,456,789.01234567

Counting from the left-most digit, 15 digits over would bring you to the 5, after which you should draw a line:

 123,456,789.012345|67

The number of digits between the decimal point and the line is 6. Subtract two from that and the result is 4, which would be the appropriate value for your system. *What this accomplishes is to discard the rightmost two digits of precision for comparison and display purposes. * So even though BR uses an internal precision of 15, for situations where many additions and/or subtractions are performed this effectively drops the precision back to 13 significant digits.

To understand the significance of the RD specification, it is important to understand that adding or subtracting a number with other numbers many times has a predictable loss of precision. (Any language that uses binary floating point numbers will lose precision in this manner.)

A "worst case" illustration of the loss of precision that can occur would be if a very large number (99,000,000) were repeatedly added to a very small number (.01). As the following table shows, this process would have to occur 94 times before it would affect IF comparisons when the RD value is set to 6. When the RD value is set to 5, the same process would have to occur 932 times before it would affect IF comparisons.

{| border=1
| RD || Loop Count || Variance
|-
| 6  || 94 || 0.00000051
|-
| 5 || 932 || 0.00000501
|-
| 4|| 9321 || 0.00005001
|-
| 3 || over 10001 ||   
|}

While the above worst case is an unlikely occurrence with real data, it does highlight the potential for problems if more than 1000 numbers are added or subtracted and the resulting figure is in the 100 million or larger range. Note that the difference in a number printed on a report is still at least 1000 times too small to show up as a penny rounding error.

In contrast to the worst case, a more "typical case" illustration could add a very large number (99,000,000) to a randomly selected small number between .01 and .99. When RD is set to 6, it would take 1930 computations of this type to cause a rounding error. With an RD of 5, it would take more than 10,000 such computations to cause a rounding error:

{| border=1
| RD || Loop Count || Variance
|-
| 6  || 1930 || -0.00000051
|-
| 5 || over 10001 ||  
|}

The following table shows the various levels of addition/subtraction precision supported by RD settings:

{| border=1
!RD Precision
!# Digits
!Precision                       
|-
|RD 12
|1.12
|#.############
|-
|RD 11
|2.11
|##.###########
|-
|RD 10
|3.10
|###.##########
|-
|RD 9
|4.9
|#,###.#########
|-
|RD 8
|5.8
|##,###.########
|-
|RD 7
|6.7
|###,###.#######
|-
|RD 6
|7.6
|#,###,###.######
|-
|RD 5
|8.5
|##,###,###.#####
|-
|RD 4
|9.4
|###,###,###.####
|-
|RD 3
|10.3
|#,###,###,###.###
|-
|RD 2
|11.2
|##,###,###,###.##
|}

* The default value of 6 will allow a value of 999,999,999.999999 to be output, input and displayed. But if you were to add a large quantity of numbers in the 100,000,000 range that also had fractional amounts, you could get an inaccuracy at the fifth and sixth decimal positions.

====Syntax====
`Image:RD.png|300px`

====Parameter====
"Integer" is a number from zero to fifteen that represents the number of decimal places to be used in numeric comparisons.

====Start-up Default====
RD 6

====Technical Considerations====
:1.) The CONFIG command can be used during program execution to override the BRConfig.sys file's RD specification.
:2.) Using RD values larger than 8 will most likely result in unexpected rounding as RD 8 only support values up to 9 million.
:3.) When numbers larger than 99,999,999.99 are used in comparisons, the RD value should be set to three or four.
:4.) In special situations where changing the RD value is not desirable, the ROUND function may be used to stop rounding errors from accumulating. See `Functions` for more information.
:5.) The RD specification affects the STR$ function since the number of significant decimals is not specified by STR$. If the number to be converted is large and the number is the result of many computations, one of the following two techniques should be used to truncate the number and accomplish the required results instead. The CNVRT$ function may be used with a PIC format or N specification or the STR$ function may be used in conjunction with the ROUND function. The following examples show each of these techniques:

 CNVRT$("N 15.2",NBR)
 STR$(ROUND(NBR,DECIMALS))

:6.) If it is undesirable to do any rounding of a number, either with the RD specification or with the ROUND function, the next best way to get an accurate comparison is to subtract potentially large numbers that are the result of many calculations and compare the result. By using IF A-B>=.01 instead of IF A>B, the desired variance is specifically tested for.

:7.) A useful program for experimenting with extreme numeric values is;

 00010    INPUT FIELDS "5,10,L 20,u": num_var
 00020    PRINT FIELDS "7,10,L 20": num_var
