! A GUI ON screen test of orders.brs: a caption and its field, a grid, a
! list and a button.  CONFIG GUI ON comes first, so the standard user-mode
! configuration (GUI OFF) can be used; under GUI ON uitest reads the
! program's controls instead of the console cells.
! Run from the kit root:
!   br_mcp_driver uitest --start context\dev\ai_access\examples\orders.prc context\dev\ai_access\examples\orders.uis
PROCERR RETURN
CONFIG GUI ON
LET X=MSG("harness",8751)
LET X=MSG("grant",300)
LOAD context\dev\ai_access\examples\orders.brs source
RUN
SYSTEM
