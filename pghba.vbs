Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
	If strLine = "# IPv4 local connections:" then
		strNextLine = "host    all             all             0.0.0.0/0            trust"
		WScript.Echo strNextLine
	End If
	WScript.strLine
Loop
