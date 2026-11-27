00010    DIM A$*1
00020    PRINT NEWPAGE
00030    PRINT FIELDS "1,2,C 20": "OOPS TEST"
00040    RINPUT FIELDS "3,2,C 1,U": A$
00050    OPEN #1: "name=context\dev\ai_access\examples\nosuch.dat", INTERNAL, INPUT
00060    STOP
