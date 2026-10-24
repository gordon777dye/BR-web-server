00010 ! Read-only probe: which customer layout fits the data on disk (old customer.0 or current)
00020    dim S$(21)*30, N(19)
00030    open #2: "name=context\scratch\probe2_out.txt,replace,recl=300", display, output
00040    open #1: "name=data\customer,shr", internal, input, relative
00050    print #2: "version=";VERSION(1);" rln=";RLN(1);" lrec=";LREC(1)
00060    let LO = DAYS(19800101,"ccyymmdd") : let HI = DAYS(20301231,"ccyymmdd")
00070 FORMOLD: form C 8,C 2,C 9,3*C 30,C 18,C 3,C 9,C 10,C 4,C 3,C 20,C 2,3*C 1,C 4,C 6,C 1,2*BH 1,BH 2,BH 1,BH 2,BH 1,BH 4,BH 2.2,4*BH 3,5*PD 6.2,2*BH 3
00080 FORMNEW: form C 8,C 2,C 9,3*C 30,C 18,C 3,C 9,C 10,C 4,C 3,C 20,C 2,3*C 1,C 4,C 5,C 6,C 1,2*BH 1,BH 2,BH 1,BH 2,BH 1,BH 4,BH 2.2,4*BH 3,5*PD 6.2,2*BH 3
00090    for R = 1 to LREC(1)
00100       mat S$(20)
00110       read #1,using FORMOLD,rec=R: mat S$, mat N conv OLDCONV norec NEXTR
00120       let OLDOK += 1 : gosub DATECHK : let OLDDATES += DOK : let OLDDTOT += 4
00130       if OLDOK < 4 then print #2: "old rec ";R;" trans=[";S$(19);"] ppd=[";S$(20);"] class=";N(1);" invdate=";N(9);" balance=";N(13)
00140       goto TRYNEW
00150 OLDCONV: let OLDBAD += 1 : if OLDBAD < 4 then print #2: "old conv rec ";R;" err ";ERR
00160 TRYNEW: mat S$(21)
00170       read #1,using FORMNEW,rec=R: mat S$, mat N conv NEWCONV norec NEXTR
00180       let NEWOK += 1 : gosub DATECHK : let NEWDATES += DOK : let NEWDTOT += 4
00190       if NEWOK < 4 then print #2: "new rec ";R;" unused=[";S$(19);"] trans=[";S$(20);"] ppd=[";S$(21);"] class=";N(1);" invdate=";N(9);" balance=";N(13)
00200       goto NEXTR
00210 NEWCONV: let NEWBAD += 1 : if NEWBAD < 4 then print #2: "new conv rec ";R;" err ";ERR
00220 NEXTR: next R
00230    print #2: "OLD layout: read ok ";OLDOK;" conv errors ";OLDBAD;" plausible dates ";OLDDATES;" of ";OLDDTOT
00240    print #2: "NEW layout: read ok ";NEWOK;" conv errors ";NEWBAD;" plausible dates ";NEWDATES;" of ";NEWDTOT
00250    close #1: 
00260    close #2: 
00270    execute "system"
00280 DATECHK: let DOK = 0 ! Four BH 3 date fields: 0 or 1980-2030 counts as plausible
00290    for D = 9 to 12
00300       if N(D) = 0 OR (N(D) >= LO AND N(D) <= HI) then let DOK += 1
00310    next D
00350    return
