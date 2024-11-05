' Caminho do arquivo original e do novo arquivo
Dim originalFilePath, newFilePath
originalFilePath = "C:\Program Files\PostgreSQL\12\data\pg_hba.conf.bkp"
newFilePath = "C:\vr\tmp\pg_hba.conf" ' Novo caminho para o arquivo de saída

' Criar objeto de sistema de arquivos
Dim fso, textStream, lines, modifiedLines, line
Set fso = CreateObject("Scripting.FileSystemObject")

' Verificar se o arquivo original existe
If fso.FileExists(originalFilePath) Then
    ' Abrir o arquivo original para leitura
    Set textStream = fso.OpenTextFile(originalFilePath, 1)
    lines = textStream.ReadAll
    textStream.Close
    
    ' Dividir o conteúdo em linhas
    lines = Split(lines, vbCrLf)
    Set modifiedLines = CreateObject("Scripting.Dictionary")
    
    ' Flag para controlar a inserção
    Dim inserted
    inserted = False
    
    ' Loop através de cada linha para modificar
    Dim i, newIndex
    newIndex = 0
    For i = 0 To UBound(lines)
        line = lines(i)
        
        ' Substituir 'md5' por 'trust', exceto na linha com explicação de métodos
        If InStr(line, "# METHOD can be ""trust"", ""reject"", ""md5"", ""password"", ""scram-sha-256""") = 0 Then
            line = Replace(line, "md5", "trust")
        End If
        
        modifiedLines.Add newIndex, line
        newIndex = newIndex + 1
        
        ' Encontrar a linha "# IPv4 local connections:" e adicionar a nova linha após ela
        If Trim(line) = "# IPv4 local connections:" And Not inserted Then
            modifiedLines.Add newIndex, "host    all             all             0.0.0.0/0            trust"
            newIndex = newIndex + 1
            inserted = True
        End If
    Next
      
    ' Gravar o conteúdo modificado no novo arquivo
    Set textStream = fso.CreateTextFile(newFilePath, True)
    For Each line In modifiedLines.Items
        textStream.WriteLine line
    Next
    textStream.Close
    
    WScript.Echo "Arquivo editado e salvo em: " & newFilePath ' Mensagem de sucesso
    ' Limpar objetos
    Set textStream = Nothing
    Set fso = Nothing
Else
    WScript.Echo "O arquivo " & originalFilePath & " não existe."
End If
