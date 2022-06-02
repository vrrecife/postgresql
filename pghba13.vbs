'Criado por Thiago Patriota - VR SOFTWARE - 31/12/2021
Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\13\data\pg_hba.conf.bkp"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
	strLine = objFile.ReadLine
	If InStr(strLine,"# IPv4 local connections:") > 0 Then
		strLine = strLine & vbNewLine & "host    all             all             0.0.0.0/0            trust"
	End If
	If InStr(strLine,"host    all             all             127.0.0.1/32            scram-sha-256") > 0 Then
		strLine = Replace(strLine,"host    all             all             127.0.0.1/32            scram-sha-256","host    all             all             127.0.0.1/32            trust")
	End If
	WScript.Echo strLine
Loop
