Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
	If InStr(strLine,"MD5")> 0 Then
		strLine = Replace(strLine,"MD5","TRUST")
	End If
	WScript.Echo strLine
Loop