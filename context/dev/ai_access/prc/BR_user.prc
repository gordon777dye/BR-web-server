! BR_user - the working session, with an assistant attached in user mode.
!
! Brought up by:   br_mcp_driver start --user
! which launches BR with the command PROC BR_user.prc, claims the channel
! this opens, and then serves it on a pipe pair so an editor can reach it.
!
! EVERY LINE OF A PROCEDURE IS ON THE OPERATOR'S SCREEN, comments
! included - a procedure echoes itself as it runs.  So these comments ARE
! the display, and a PRINT saying the same thing would say it twice.  The
! reasoning that is not for the screen is in README.md, under the
! standard procedures.
!
! NOT RESTRICTED, deliberately: a restricted session may write only the
! files it created, so an application's own record updates would be
! refused.  User mode is the restriction here instead.
! PRINT NEWPAGE EARNS ITS PLACE HERE: everything above it has already
! been echoed and is cleared by it, so the notes for a reader stay off the
! operator's screen and only what follows is on it.  Moving it, or
! dropping it, puts this header in front of somebody who wanted a session.
PROCERR RETURN
PRINT NEWPAGE
!
! ==========================================================
!  Connecting an assistant to this session
! ==========================================================
!
! No third argument, so USER MODE rather than DEVELOP:
!   it may type only while a program is waiting for input, never at the
!   READY prompt, where FREE or SYSTEM would be one keystroke away;
!   and the AI-connected flag goes up when it greets, so any session
!   started from here comes up restricted while it stays connected.
LET X=MSG("harness",8721)
!
! The keyboard, for one hour, timed from now.  A negative number would
! mean exclusive - no expiry, no user present - which is for unattended
! verification and not for a session somebody is sitting at.
LET X=MSG("grant",3600)
!
! The assistant is connected and has the keyboard for one hour.
!
!   To take the keyboard back:   LET X=MSG("grant",0)
!   To send the assistant away:  LET X=MSG("harness",0)
!
! No SYSTEM at the end: the session stays up for the person using it.
