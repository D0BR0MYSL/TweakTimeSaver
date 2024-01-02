If GetOS = GetOS = "Windows 10" Or GetOS = "Windows 11" Then
   If WScript.Arguments.length =0 Then
      Set objShell = CreateObject("Shell.Application")
      objShell.ShellExecute "wscript.exe", """" & _
      WScript.ScriptFullName & """" & " uac","", "runas", 1
   Else
      Const HKEY_LOCAL_MACHINE = &H80000002
      strComputer = "."
      Set oReg=GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\default:StdRegProv")
      strKeyPath = "SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore"
      strValueName = "SystemRestorePointCreationFrequency"
      oReg.SetDWORDValue HKEY_LOCAL_MACHINE,strKeyPath,strValueName, 0  
      CreateSRP
      oReg.DeleteValue HKEY_LOCAL_MACHINE, strKeyPath, strValueName
   End If
End If

Sub CreateSRP
   Set SRP = getobject("winmgmts:\\.\root\default:Systemrestore")
   
   If GetOS = "Windows 10" Or GetOS = "Windows 11" Then
      sOut = SRP.createrestorepoint ("Manual Restore Point", 7, 100)
   Else
      sDesc = "Manual Restore Point"
      sDesc = InputBox ("Enter a description.", "Manual Restore Point","Manual Restore Point")
      If Trim(sDesc) <> "" Then
         sOut = SRP.createrestorepoint (sDesc, 0, 100)
      End If
   End If
   
   If sOut <> 0 Then
      WScript.echo "Error " & sOut & _
      ": Unable to create Restore Point."
   End If
End Sub

Function GetOS    
   Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _
   ".\root\cimv2")
   Set colOS = objWMI.ExecQuery("Select * from Win32_OperatingSystem")
   For Each objOS In colOS
      strOSName = objOS.Caption
      If instr(strOSName, "Windows 7") Then
         GetOS = "Windows 7"    
      ElseIf instr(strOSName, "Vista") Then
         GetOS = "Windows Vista"
      ElseIf instr(strOSName, "Windows XP") Then
         GetOS = "Windows XP"
      ElseIf instr(strOSName, "Windows 8") Then
         GetOS = "Windows 8"
      ElseIf instr(strOSName, "Windows 10") Then
         GetOS = "Windows 10"
      ElseIf instr(strOSName, "Windows 11") Then
         GetOS = "Windows 11"
      End If
   Next
End Function