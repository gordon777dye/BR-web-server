06764    for ALLOW_SUB = 1 to UDIM(ALLOW$)
06766       if POS(URL$,"^"&ALLOW$(ALLOW_SUB)) then !:
               let NOT_AUTH = FALSE !:
               goto Process_Url_Parms
06768    next ALLOW_SUB
