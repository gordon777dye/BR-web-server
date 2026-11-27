! A test that EXPECTS an untrapped error from oops.brs.  After the error the
! program waits at BR's error prompt, and oops.uis ends the session from
! there: CLEAR PROC, then SYSTEM.  The channel is opened in DEVELOP mode,
! because a user-mode channel's keys do not reach BR's command prompt.
! Run from the kit root:
!   br_mcp_driver uitest --start context\dev\ai_access\examples\oops.prc context\dev\ai_access\examples\oops.uis
PROCERR RETURN
LET X=MSG("harness",8751,"DEVELOP")
LET X=MSG("grant",300)
LOAD context\dev\ai_access\examples\oops.brs source
RUN
SYSTEM
