'Criado por Thiago Patriota - VR SOFTWARE - 31/12/2021
strAnswer = InputBox("INFORME A QUANTIDADE DE CONEXOES AO BANCO (TOTAL + 10%):", "NUMERO DE CONEXOES AO BANCO", "50")
strComputer2 = "."
Set objWMI = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\" _ 
& strComputer2 & "\root\Microsoft\Windows\Storage")
Set colComputer2 = objWMI.ExecQuery _
("Select * from MSFT_PhysicalDisk")
For Each objComputer in colComputer2 
strComputer2=objComputer.MediaType
Next
strComputer1 = "."
Set objWMI = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\" _ 
& strComputer1 & "\root\cimv2") 
Set colComputer1 = objWMI.ExecQuery _
("Select * from Win32_Processor")
For Each objComputer in colComputer1 
strComputer1=objComputer.NumberOfCores
Next
strComputer = "."
Set objWMI = GetObject("winmgmts:" _
& "{impersonationLevel=impersonate}!\\" _ 
& strComputer & "\root\cimv2") 
Set colComputer = objWMI.ExecQuery _
("Select * from Win32_ComputerSystem")
For Each objComputer in colComputer 
strComputer=objComputer.TotalPhysicalMemory
Next
CPU_CORES = strComputer1
CPU_CORES_PARALLEL = CPU_CORES/2
MEM_TOTAL_B = strComputer
MEM_TOTAL_KB = ROUND(MEM_TOTAL_B/1024)
MEM_TOTAL_MB = ROUND(MEM_TOTAL_KB/1024)
MEM_TOTAL_GB = ROUND(MEM_TOTAL_MB/1024)
SHARED_BUFFERS = ROUND(MEM_TOTAL_MB/4)
EFFECTIVE_CACHE_SIZE = ROUND(MEM_TOTAL_MB/4*3)
MAINTENANCE_WORK_MEM = ROUND(MEM_TOTAL_MB/16)
WORK_MEM = ROUND(MEM_TOTAL_KB/16/strAnswer)
Set objFS = CreateObject("Scripting.FileSystemObject")
strFile = "C:\Program Files\PostgreSQL\12\data\postgresql.conf"
Set objFile = objFS.OpenTextFile(strFile)
Do Until objFile.AtEndOfStream
    strLine = objFile.ReadLine
	If InStr(strLine,"#random_page_cost = 4.0")> 0 Then
		If strComputer2 = 4 Then
			strLine = Replace(strLine,"#random_page_cost = 4.0","random_page_cost = 1.1")
		ElseIf strComputer2 = 3 Then
			strLine = Replace(strLine,"#random_page_cost = 4.0","random_page_cost = 4.0")
		End If
	End If
'	If InStr(strLine,"#effective_io_concurrency = 0")> 0 Then
'		If strComputer2 = 4 Then
'			strLine = Replace(strLine,"#effective_io_concurrency = 0","effective_io_concurrency = 200")
'		ElseIf strComputer2 = 3 Then
'			strLine = Replace(strLine,"#effective_io_concurrency = 0","effective_io_concurrency = 2")
'		End If
'	End If
	If InStr(strLine,"port = 5432")> 0 Then
        strLine = Replace(strLine,"port = 5432","port = 8745")
    End If
	If InStr(strLine,"#wal_buffers = -1")> 0 Then
        strLine = Replace(strLine,"#wal_buffers = -1","wal_buffers = 16MB")
    End If
	If InStr(strLine,"#default_statistics_target = 100")> 0 Then
        strLine = Replace(strLine,"#default_statistics_target = 100","default_statistics_target = 100")
    End If
	If InStr(strLine,"max_connections = 100")> 0 Then
        strLine = Replace(strLine,"max_connections = 100","max_connections = "&strAnswer)
    End If
	If InStr(strLine,"shared_buffers = 128MB")> 0 Then
		strLine = Replace(strLine,"shared_buffers = 128MB","shared_buffers = "&SHARED_BUFFERS&"MB")
	End If
	If InStr(strLine,"#maintenance_work_mem = 64MB")> 0 Then
		strLine = Replace(strLine,"#maintenance_work_mem = 64MB","maintenance_work_mem = "&MAINTENANCE_WORK_MEM&"MB")
	End If
	If InStr(strLine,"#max_worker_processes = 8")> 0 Then
		strLine = Replace(strLine,"#max_worker_processes = 8","max_worker_processes = "&CPU_CORES)
	End If
	If InStr(strLine,"#max_parallel_maintenance_workers = 2")> 0 Then
		strLine = Replace(strLine,"#max_parallel_maintenance_workers = 2","max_parallel_maintenance_workers = "&CPU_CORES_PARALLEL)
	End If
	If InStr(strLine,"#max_parallel_workers_per_gather = 2")> 0 Then
		strLine = Replace(strLine,"#max_parallel_workers_per_gather = 2","max_parallel_workers_per_gather = "&CPU_CORES_PARALLEL)
	End If
	If InStr(strLine,"#max_parallel_workers = 8")> 0 Then
		strLine = Replace(strLine,"#max_parallel_workers = 8","max_parallel_workers = "&CPU_CORES)
	End If
	If InStr(strLine,"#autovacuum_max_workers = 3")> 0 Then
		strLine = Replace(strLine,"#autovacuum_max_workers = 3","autovacuum_max_workers = 2")
	End If
	If InStr(strLine,"#autovacuum_vacuum_cost_limit = -1")> 0 Then
		strLine = Replace(strLine,"#autovacuum_vacuum_cost_limit = -1","autovacuum_vacuum_cost_limit = 3000")
	End If
	If InStr(strLine,"#idle_in_transaction_session_timeout = 0")> 0 Then
		strLine = Replace(strLine,"#idle_in_transaction_session_timeout = 0","idle_in_transaction_session_timeout = 300000")
	End If
	If InStr(strLine,"#cpu_tuple_cost = 0.01")> 0 Then
		strLine = Replace(strLine,"#cpu_tuple_cost = 0.01","cpu_tuple_cost = 0.03")
	End If
	If InStr(strLine,"#tcp_keepalives_idle = 0")> 0 Then
        strLine = Replace(strLine,"#tcp_keepalives_idle = 0","tcp_keepalives_idle = 10")
    End If
	If InStr(strLine,"#tcp_keepalives_interval = 0")> 0 Then
        strLine = Replace(strLine,"#tcp_keepalives_interval = 0","tcp_keepalives_interval = 10")
    End If
	If InStr(strLine,"#tcp_keepalives_count = 0")> 0 Then
        strLine = Replace(strLine,"#tcp_keepalives_count = 0","tcp_keepalives_count = 10")
    End If
	If InStr(strLine,"#effective_cache_size = 4GB")> 0 Then
		strLine = Replace(strLine,"#effective_cache_size = 4GB","effective_cache_size = "&EFFECTIVE_CACHE_SIZE&"MB")
	End If
	If InStr(strLine,"#checkpoint_completion_target = 0.5")> 0 Then
		strLine = Replace(strLine,"#checkpoint_completion_target = 0.5","checkpoint_completion_target = 0.9")
	End If
	If InStr(strLine,"#work_mem = 4MB")> 0 Then
		strLine = Replace(strLine,"#work_mem = 4MB","work_mem = "&WORK_MEM&"kB")
	End If
	If InStr(strLine,"min_wal_size = 80MB")> 0 Then
		strLine = Replace(strLine,"min_wal_size = 80MB","min_wal_size = 1GB")
	End If
	If InStr(strLine,"max_wal_size = 1GB")> 0 Then
		strLine = Replace(strLine,"max_wal_size = 1GB","max_wal_size = 4GB")
	End If
	WScript.Echo strLine
Loop
