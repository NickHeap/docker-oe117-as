/* activation for appserver to connect to required database */

DEFINE VARIABLE cDbName   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDbHost AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDbPort   AS CHARACTER NO-UNDO.
DEFINE VARIABLE cDbAlias  AS CHARACTER NO-UNDO.

cDbName= OS-GETENV("OPENEDGE_DB").
cDbHost= OS-GETENV("OPENEDGE_HOST").
cDbPort= OS-GETENV("OPENEDGE_BROKER_PORT").
cDbAlias= OS-GETENV("OPENEDGE_ALIAS").

IF cDbName <> ?
  AND cDbName <> ""
THEN DO:
  IF NOT CONNECTED(cDbName) THEN DO:
    MESSAGE SUBSTITUTE("Connecting database '&1'...", cDbName).
    IF cDbAlias <> ?
      AND cDbAlias <> ""
    THEN DO:
      CONNECT -db VALUE(cDbName)
              -H  VALUE(cDbHost)
              -S  VALUE(cDbPort)
              -ld VALUE(cDbAlias).
    END.
    ELSE DO:
      CONNECT -db VALUE(cDbName)
              -H  VALUE(cDbHost)
              -S  VALUE(cDbPort).
    END.
  END.
  ELSE DO:
    MESSAGE SUBSTITUTE("Database '&1' already connected.", cDbName).
  END.
END.
ELSE DO:
  MESSAGE "No database connection required.".
END.
