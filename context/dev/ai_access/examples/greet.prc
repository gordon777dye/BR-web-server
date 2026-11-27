! A screen test of greet.brs: opens the channel in user mode, lends the
! keyboard for five minutes, runs the program, and ends BR when it stops.
! Run from the kit root:
!   br_mcp_driver uitest --start context\dev\ai_access\examples\greet.prc context\dev\ai_access\examples\greet.uis
! For your own program, copy this and change the LOAD line.
PROCERR RETURN
LET X=MSG("harness",8751)
LET X=MSG("grant",300)
LOAD context\dev\ai_access\examples\greet.brs source
RUN
SYSTEM
