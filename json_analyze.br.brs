01000 ! Rep Json_Analyze
01020 ! Parse And Recompile Json
01040 ! 
01060 ! ***** 05/04/18
01080 ! 
01100    dim JSON_INPUT_FILE$*60,LEVELS(99),MEMBER$*2000
01120    dim WORK$*5000,INPUT$*32000,RECOMP$*32000
01140    dim TYPES$(99),MEMBERS$(99),PARENTS(99),SUBS(99)
01160 ! 
01180 ! ***** Create Dim Statements For This Program
01200    goto 1420 ! Remark This Line To Make Dims
01220    open #10: "name= dim.proc, replace",display,output 
01240    print #10: "load json_analyze"
01260    for X = 0 to 99
01280       print #10: "800";CNVRT$("ZD 02",X);"   dim keys";CNVRT$("ZD 02",X);"$(0)*300"
01300       print #10: "801";CNVRT$("ZD 02",X);"   dim values";CNVRT$("ZD 02",X);"$(0)*5000"
01320    next X
01340    print "run"
01360    close #10: 
01380 ! 
01400    execute "proc dim.proc"
01420 ! 
01440 ! ***** Get The Json Sample
01460    print "Specify JSON snippet file..."
01480    let JSON_INPUT_FILE$ = "xxx.json"
01500    rinput JSON_INPUT_FILE$ ioerr 1500
01520 ! 
01540    open #10: "Name= "&JSON_INPUT_FILE$, display, input ioerr 1460
01560 ! 
01580    linput #10: INPUT$
01600    close #10: 
01620 ! 
01640 ! ***** Parse Json Snippet
01660 ! 
01680    library "web_server": FNPARSE_JSON,FNCOMPILE_JSON
01700 ! 
01720    let QUOTE_NUMERICS = 1 ! Add Quotes To Numeric Values
01740    if FNJSON("input$") then !:
            let FNPARSE(INPUT$) ! ***** Parse One Value
01760    for SUB1 = 1 to OUTPUT
01780       print "Array ";SUB1
01800       if MEMBERS$(SUB1) > NULL$ then !:
               print "Member Name:"; MEMBERS$(SUB1)
01820       print "Parent: ";PARENTS(SUB1);" ";SUBS(SUB1)
01840    next SUB1
01860 ! 
01880    print  !:
         print " Success.." !:
         print OUTPUT; " Arrays used."
01900    print "Press Any Key..." !:
         let KSTAT$(1)
01920 ! 
01940    print "Now recompile the original value.."
01960    for SUB1 = OUTPUT to 1 step -1
01980       let KEYS_ARRAY$ = "keys"&CNVRT$("ZD 2",SUB1)&"$" !:
            let VALUES_ARRAY$ = "values"&CNVRT$("ZD 2",SUB1)&"$"
02000       execute "rtn = fncompile_json(types$(sub1), members$(sub1), mat "&KEYS_ARRAY$&", mat "&VALUES_ARRAY$&", work$, quote_numerics)"
02020       if RTN < 0 then pause 
02040       if SUB1 > 1 then !:
               execute 'let parent_values_array$ = "values'&CNVRT$("ZD 2",PARENTS(SUB1))&'$"' !:
               execute "let " & PARENT_VALUES_ARRAY$ & "(subs(sub1)) = work$" !:
               print WORK$ !:
               let KSTAT$(1)
02060    next SUB1
02080    if WORK$ == INPUT$ then !:
            print "Success.. Work$ = Input$" !:
         else !:
            print "Failure.. Work$ <> Input$" !:
            print "Len(Input$)=";LEN(INPUT$),"Len(Work$)=";LEN(WORK$)
02090    stop 
02100 ! 
02120    def FNPARSE(INPUT$*32000;PARENT,SUB1,KEYS_ARRAY$,VALUES_ARRAY$,PARENT_VALUES_ARRAY$)
02140       let OUTPUT += 1 ! Current Output Array Number !:
            let PARENTS(OUTPUT) = PARENT !:
            let SUBS(OUTPUT) = SUB1
02160       let KEYS_ARRAY$ = "keys"&CNVRT$("ZD 2",OUTPUT)&"$" !:
            let VALUES_ARRAY$ = "values"&CNVRT$("ZD 2",OUTPUT)&"$"
02180       execute "let rtn = FNPARSE_JSON(INPUT$,TYPES$(output),MEMBERS$(output),MAT "&KEYS_ARRAY$&",MAT "&VALUES_ARRAY$&")"
02200       if RTN < 0 then !:
               print "Parse Error: "; -RTN !:
               print INPUT$ !:
               pause 
02220       rem execute "print rtn;tab(1); mat "&KEYS_ARRAY$ : linput Z$ !:                     execute "print mat "&VALUES_ARRAY$ : linput Z$
02240       let PARENT = OUTPUT !:
            let PARENT_VALUES_ARRAY$ = VALUES_ARRAY$
02260 ! Since Parent_Values_Array$ Is A Local Variable And Is Not Subject To !:
            ! The Output Variable, It Will Not Change During Fnparse Recursion !:
            ! Unlike Values_Array$ Which Keeps Incrementing With The Output Counter
02280       for SUB1 = 1 to RTN ! For Each Resulting Value
02300          execute "let WORK$ = " & PARENT_VALUES_ARRAY$ & "(" &STR$(SUB1) & ")" !:
               if FNJSON(PARENT_VALUES_ARRAY$ & "(" &STR$(SUB1) & ")") then !:
                  execute "Let fnparse(WORK$,parent,sub1)"
02320       next SUB1
02340    fnend 
02360 ! 
02380 Json: ! ***** Test String Value To See If It Is Json
02400    def FNJSON(STRING_REF$;JSON)
02420       execute "let json = (" & STRING_REF$ & "(1:1) == '{' OR " & STRING_REF$ & "(1:1) == '[' )"
02440       let FNJSON = JSON
02460    fnend 
02480 ! 
02500    dim KEYS00$(0)*300
02520    dim KEYS01$(1)*300
02540    dim KEYS02$(0)*300
02560    dim KEYS03$(0)*300
02580    dim KEYS04$(0)*300
02600    dim KEYS05$(0)*300
02620    dim KEYS06$(0)*300
02640    dim KEYS07$(0)*300
02660    dim KEYS08$(0)*300
02680    dim KEYS09$(0)*300
02700    dim KEYS10$(0)*300
02720    dim KEYS11$(0)*300
02740    dim KEYS12$(0)*300
02760    dim KEYS13$(0)*300
02780    dim KEYS14$(0)*300
02800    dim KEYS15$(0)*300
02820    dim KEYS16$(0)*300
02840    dim KEYS17$(0)*300
02860    dim KEYS18$(0)*300
02880    dim KEYS19$(0)*300
02900    dim KEYS20$(0)*300
02920    dim KEYS21$(0)*300
02940    dim KEYS22$(0)*300
02960    dim KEYS23$(0)*300
02980    dim KEYS24$(0)*300
03000    dim KEYS25$(0)*300
03020    dim KEYS26$(0)*300
03040    dim KEYS27$(0)*300
03060    dim KEYS28$(0)*300
03080    dim KEYS29$(0)*300
03100    dim KEYS30$(0)*300
03120    dim KEYS31$(0)*300
03140    dim KEYS32$(0)*300
03160    dim KEYS33$(0)*300
03180    dim KEYS34$(0)*300
03200    dim KEYS35$(0)*300
03220    dim KEYS36$(0)*300
03240    dim KEYS37$(0)*300
03260    dim KEYS38$(0)*300
03280    dim KEYS39$(0)*300
03300    dim KEYS40$(0)*300
03320    dim KEYS41$(0)*300
03340    dim KEYS42$(0)*300
03360    dim KEYS43$(0)*300
03380    dim KEYS44$(0)*300
03400    dim KEYS45$(0)*300
03420    dim KEYS46$(0)*300
03440    dim KEYS47$(0)*300
03460    dim KEYS48$(0)*300
03480    dim KEYS49$(0)*300
03500    dim KEYS50$(0)*300
03520    dim KEYS51$(0)*300
03540    dim KEYS52$(0)*300
03560    dim KEYS53$(0)*300
03580    dim KEYS54$(0)*300
03600    dim KEYS55$(0)*300
03620    dim KEYS56$(0)*300
03640    dim KEYS57$(0)*300
03660    dim KEYS58$(0)*300
03680    dim KEYS59$(0)*300
03700    dim KEYS60$(0)*300
03720    dim KEYS61$(0)*300
03740    dim KEYS62$(0)*300
03760    dim KEYS63$(0)*300
03780    dim KEYS64$(0)*300
03800    dim KEYS65$(0)*300
03820    dim KEYS66$(0)*300
03840    dim KEYS67$(0)*300
03860    dim KEYS68$(0)*300
03880    dim KEYS69$(0)*300
03900    dim KEYS70$(0)*300
03920    dim KEYS71$(0)*300
03940    dim KEYS72$(0)*300
03960    dim KEYS73$(0)*300
03980    dim KEYS74$(0)*300
04000    dim KEYS75$(0)*300
04020    dim KEYS76$(0)*300
04040    dim KEYS77$(0)*300
04060    dim KEYS78$(0)*300
04080    dim KEYS79$(0)*300
04100    dim KEYS80$(0)*300
04120    dim KEYS81$(0)*300
04140    dim KEYS82$(0)*300
04160    dim KEYS83$(0)*300
04180    dim KEYS84$(0)*300
04200    dim KEYS85$(0)*300
04220    dim KEYS86$(0)*300
04240    dim KEYS87$(0)*300
04260    dim KEYS88$(0)*300
04280    dim KEYS89$(0)*300
04300    dim KEYS90$(0)*300
04320    dim KEYS91$(0)*300
04340    dim KEYS92$(0)*300
04360    dim KEYS93$(0)*300
04380    dim KEYS94$(0)*300
04400    dim KEYS95$(0)*300
04420    dim KEYS96$(0)*300
04440    dim KEYS97$(0)*300
04460    dim KEYS98$(0)*300
04480    dim KEYS99$(0)*300
04500    dim VALUES00$(0)*5000
04520    dim VALUES01$(1)*5000
04540    dim VALUES02$(0)*5000
04560    dim VALUES03$(0)*5000
04580    dim VALUES04$(0)*5000
04600    dim VALUES05$(0)*5000
04620    dim VALUES06$(0)*5000
04640    dim VALUES07$(0)*5000
04660    dim VALUES08$(0)*5000
04680    dim VALUES09$(0)*5000
04700    dim VALUES10$(0)*5000
04720    dim VALUES11$(0)*5000
04740    dim VALUES12$(0)*5000
04760    dim VALUES13$(0)*5000
04780    dim VALUES14$(0)*5000
04800    dim VALUES15$(0)*5000
04820    dim VALUES16$(0)*5000
04840    dim VALUES17$(0)*5000
04860    dim VALUES18$(0)*5000
04880    dim VALUES19$(0)*5000
04900    dim VALUES20$(0)*5000
04920    dim VALUES21$(0)*5000
04940    dim VALUES22$(0)*5000
04960    dim VALUES23$(0)*5000
04980    dim VALUES24$(0)*5000
05000    dim VALUES25$(0)*5000
05020    dim VALUES26$(0)*5000
05040    dim VALUES27$(0)*5000
05060    dim VALUES28$(0)*5000
05080    dim VALUES29$(0)*5000
05100    dim VALUES30$(0)*5000
05120    dim VALUES31$(0)*5000
05140    dim VALUES32$(0)*5000
05160    dim VALUES33$(0)*5000
05180    dim VALUES34$(0)*5000
05200    dim VALUES35$(0)*5000
05220    dim VALUES36$(0)*5000
05240    dim VALUES37$(0)*5000
05260    dim VALUES38$(0)*5000
05280    dim VALUES39$(0)*5000
05300    dim VALUES40$(0)*5000
05320    dim VALUES41$(0)*5000
05340    dim VALUES42$(0)*5000
05360    dim VALUES43$(0)*5000
05380    dim VALUES44$(0)*5000
05400    dim VALUES45$(0)*5000
05420    dim VALUES46$(0)*5000
05440    dim VALUES47$(0)*5000
05460    dim VALUES48$(0)*5000
05480    dim VALUES49$(0)*5000
05500    dim VALUES50$(0)*5000
05520    dim VALUES51$(0)*5000
05540    dim VALUES52$(0)*5000
05560    dim VALUES53$(0)*5000
05580    dim VALUES54$(0)*5000
05600    dim VALUES55$(0)*5000
05620    dim VALUES56$(0)*5000
05640    dim VALUES57$(0)*5000
05660    dim VALUES58$(0)*5000
05680    dim VALUES59$(0)*5000
05700    dim VALUES60$(0)*5000
05720    dim VALUES61$(0)*5000
05740    dim VALUES62$(0)*5000
05760    dim VALUES63$(0)*5000
05780    dim VALUES64$(0)*5000
05800    dim VALUES65$(0)*5000
05820    dim VALUES66$(0)*5000
05840    dim VALUES67$(0)*5000
05860    dim VALUES68$(0)*5000
05880    dim VALUES69$(0)*5000
05900    dim VALUES70$(0)*5000
05920    dim VALUES71$(0)*5000
05940    dim VALUES72$(0)*5000
05960    dim VALUES73$(0)*5000
05980    dim VALUES74$(0)*5000
06000    dim VALUES75$(0)*5000
06020    dim VALUES76$(0)*5000
06040    dim VALUES77$(0)*5000
06060    dim VALUES78$(0)*5000
06080    dim VALUES79$(0)*5000
06100    dim VALUES80$(0)*5000
06120    dim VALUES81$(0)*5000
06140    dim VALUES82$(0)*5000
06160    dim VALUES83$(0)*5000
06180    dim VALUES84$(0)*5000
06200    dim VALUES85$(0)*5000
06220    dim VALUES86$(0)*5000
06240    dim VALUES87$(0)*5000
06260    dim VALUES88$(0)*5000
06280    dim VALUES89$(0)*5000
06300    dim VALUES90$(0)*5000
06320    dim VALUES91$(0)*5000
06340    dim VALUES92$(0)*5000
06360    dim VALUES93$(0)*5000
06380    dim VALUES94$(0)*5000
06400    dim VALUES95$(0)*5000
06420    dim VALUES96$(0)*5000
06440    dim VALUES97$(0)*5000
06460    dim VALUES98$(0)*5000
06480    dim VALUES99$(0)*5000
