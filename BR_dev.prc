! BR_dev - a development session with an assistant attached.
!
! Brought up by:   br_mcp_driver start
! which launches BR with the command PROC BR_dev.prc, claims the channel
! this opens, and then serves it on a pipe pair so an editor can reach it.
! `start --user` does the same with BR_user.prc; the only difference
! between the two arrangements is which of these procedures runs.
!
! EVERY LINE OF A PROCEDURE IS ON THE OPERATOR'S SCREEN, comments
! included - a procedure echoes itself as it runs.  So these comments ARE
! the display.  The reasoning that is not for the screen is in README.md,
! under the standard procedures.
!
! THIS PROCEDURE DOES NOT START THE DRIVER, and it used to.  A SYSTEM line
! here launched `serve` itself, which made the session self-sufficient but
! put two actors on one channel: the driver it started claimed the channel
! and removed the token file, which is the very thing `start` waits for, so
! `start` reported a failure for a session that had come up perfectly.
! Leaving the serving to whatever launched BR removes the second actor
! instead of sequencing them.
!
! PRINT NEWPAGE EARNS ITS PLACE HERE: everything above it has already
! been echoed and is cleared by it, so the notes for a reader stay off the
! operator's screen and only what follows is on it.  Moving it, or
! dropping it, puts this header in front of somebody who wanted a session.
PROCERR RETURN
PRINT NEWPAGE
!
! ==========================================================
!  Development session with an assistant
! ==========================================================
!
! DEVELOP MODE, which is chosen here or not at all - it is the third
! argument to MSG("harness") and nothing outside BR can set it:
!   the assistant may type at the READY prompt, which in a development
!   session is where the work is;
!   and this session does NOT raise the AI-connected flag, so a test
!   session started from here can still write its own application files.
! It is refused to a session that has already opened the channel in user
! mode, and to a restricted session.
LET X=MSG("harness",8720,"DEVELOP")
!
! The channel is open and waiting to be claimed.  Point your editor at:
!
!     br_mcp_driver connect
!
! The assistant can READ this session - screen, fields, cursor - with no
! grant at all.  NO GRANT IS GIVEN HERE, because a development session
! usually wants an assistant that reads:
!
!   To let it TYPE, for ten minutes:  LET X=MSG("grant",600)
!   To take that back:                LET X=MSG("grant",0)
!   To send it away entirely:         LET X=MSG("harness",0)
!
! No SYSTEM at the end: this hands you a session to work in.
