Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
	strLine = objFile.ReadLine
	If InStr(strLine,"md5")> 0 Then
		strLine = Replace(strLine,"md5","trust")
	End If
	WScript.Echo strLine
Loop
