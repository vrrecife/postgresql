Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
	strLine = objFile.ReadLine
	If InStr(strLine,"# IPv4 local connections:")> 0 Then
		strLine = Replace(strLine,"# IPv4 local connections:","# IPv4 local connections:	host    all             all             0.0.0.0/0            trust")
	End If
	If InStr(strLine,"host    all             all             127.0.0.1/32            md5")> 0 Then
		strLine = Replace(strLine,"host    all             all             127.0.0.1/32            md5","host    all             all             127.0.0.1/32            trust")
	End If
	WScript.Echo strLine
Loop
