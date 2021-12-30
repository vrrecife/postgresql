Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
	If InStr(strLine,"host    all             all             127.0.0.1/32            md5")> 0 Then
		strLine = Replace(strLine,"host    all             all             127.0.0.1/32            md5","host    all             all             0.0.0.0/0            trust")
	End If
	WScript.Echo strLine
	If InStr(strLine,"host    all             all             ::1/128                 md5")> 0 Then
		strLine = Replace(strLine,"host    all             all             ::1/128                 md5","host    all             all             ::1/128                 trust")
	End If
	WScript.Echo strLine
Loop

