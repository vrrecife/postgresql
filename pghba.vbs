Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
	If strNextLine = "# IPv4 local connections:" then
		strLine = strLine + "host    all             all             0.0.0.0/0            trust"
	End If
	WScript.Echo strLine
Loop
