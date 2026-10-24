00010 ! Read-only probe of data file record lengths and key composition (onboarding STEP 3)
00020    dim OUT$*200
00030    open #2: "name=context\scratch\probe_out.txt,replace,recl=200", display, output
00040    open #1: "name=data\customer,kfname=data\customer.key,shr", internal, input, keyed ioerr CUST_ERR
00050    print #2: "customer rln=";RLN(1);" lrec=";LREC(1);" krec=";KREC(1)
00060    for SEG = 1 to 6
00070       print #2: "  seg ";SEG;" kps=";KPS(1,SEG);" kln=";KLN(1,SEG)
00080    next SEG
00090    close #1: 
00100    goto COMMENTS
00110 CUST_ERR: print #2: "customer open error ";ERR
00120 COMMENTS: open #1: "name=data\comments.ind,shr", internal, input, relative ioerr COMM_ERR
00130    print #2: "comments.ind rln=";RLN(1);" lrec=";LREC(1)
00140    close #1: 
00150    goto LOGF
00160 COMM_ERR: print #2: "comments.ind open error ";ERR
00170 LOGF: print #2: "logfile.ind exists=";EXISTS("data\logfile.ind")
00180    close #2: 
00190    execute "system"
