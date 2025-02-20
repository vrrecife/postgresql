'Criado por Thiago Patriota - VR SOFTWARE - 25/09/2022 Atualizado em 20/02/2025
' Caminho do arquivo original
Dim originalFilePath
originalFilePath = "C:\Program Files\PostgreSQL\14\data\pg_hba.conf.bkp"

' Criar objeto de sistema de arquivos
Dim fso, textStream, lines, line
Set fso = CreateObject("Scripting.FileSystemObject")

' Verificar se o arquivo original existe
If fso.FileExists(originalFilePath) Then
    ' Abrir o arquivo original para leitura
    Set textStream = fso.OpenTextFile(originalFilePath, 1)
    lines = textStream.ReadAll
    textStream.Close
    
    ' Dividir o conteúdo em linhas
    lines = Split(lines, vbCrLf)
    
    ' Flag para controlar a inserção
    Dim inserted
    inserted = False
    
    ' Loop através de cada linha para modificar
    Dim i
    For i = 0 To UBound(lines)
        line = lines(i)
        
        ' Substituir 'md5' por 'trust', exceto na linha com explicação de métodos
        If InStr(line, "# METHOD can be ""trust"", ""reject"", ""md5"", ""password"", ""scram-sha-256""") = 0 Then
            line = Replace(line, "md5", "trust")
        End If
        
        ' Escrever a linha modificada na saída
        WScript.Echo line
        
        ' Encontrar a linha "# IPv4 local connections:" e adicionar a nova linha após ela
        If Trim(line) = "# IPv4 local connections:" And Not inserted Then
            WScript.Echo "host    all             all                   0.0.0.0/0            trust"
            inserted = True
        End If
    Next
    
    ' Limpar objetos
    Set textStream = Nothing
    Set fso = Nothing
Else
    WScript.Echo "O arquivo " & originalFilePath & " não existe."
End If
