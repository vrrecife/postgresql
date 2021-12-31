Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
	If InStr(strLine,"#random_page_cost = 4.0")> 0 Then
		strLine = Replace(strLine,"#random_page_cost = 4.0","random_page_cost = 1.1")
	End If
	WScript.Echo strLine
Loop
