' This script will gather:
' Manufacturer, Model, Operating System, OS Build, OS Version, Product Key, this script's runtime,
' and then create a new txt file named with the hostname and containing the information it collected.
' This script will only gather information from the localhost that it is run on. I personally use it
' as a startup script on my domain and have it save all the text files to a shared folder. This script
' will not overwrite the file it created if it exists. The txt file must be deleted or save location
' must be changed.
'
' All you have to configure is the save path and the ID.
'  - The save path MUST end with a trailing slash \
' -----------------------------------------
' !VALID PATH REQUIRED!
'  - examples: C:\Users\Bob\Desktop\    -or-    \\192.168.1.5\shares\Company Product Keys\
filePath = "C:\Users\"
'
' Identifier is optional.
'  - examples: productKey    -or-    pkey    -or-    info
fileID = "Nfo"
' Now you can save this script and execute (run) it.
' -----------------------------------------
'
' I8,        8        ,8I    db         88888888ba   888b      88  88  888b      88    ,ad8888ba,
' `8b       d8b       d8'   d88b        88      "8b  8888b     88  88  8888b     88   d8"'    `"8b
'  "8,     ,8"8,     ,8"   d8'`8b       88      ,8P  88 `8b    88  88  88 `8b    88  d8'
'   Y8     8P Y8     8P   d8'  `8b      88aaaaaa8P'  88  `8b   88  88  88  `8b   88  88
'   `8b   d8' `8b   d8'  d8YaaaaY8b     88""""88'    88   `8b  88  88  88   `8b  88  88      88888
'    `8a a8'   `8a a8'  d8""""""""8b    88    `8b    88    `8b 88  88  88    `8b 88  Y8,        88
'     `8a8'     `8a8'  d8'        `8b   88     `8b   88     `8888  88  88     `8888   Y8a.    .a88
'      `8'       `8'  d8'          `8b  88      `8b  88      `888  88  88      `888    `"Y88888P"
'
'           DO NOT CHANGE ANYHING BELOW THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING.
'---------------------------------------------------------------------------------------------------
' execute the main function
SaveToFile filePath, fileID


Function SaveToFile(strSavePath, strSaveName)
  Set wshShell = CreateObject("WScript.Shell")
  Set fso = CreateObject("Scripting.FileSystemObject")
  ' get hostname from registry
  objHostname = wshShell.RegRead("HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Hostname")
  ' set filename and file object
  Set objSaveFile = fso.CreateTextFile(strSavePath & objHostname & "_" & strSaveName & ".txt")
  ' write information to file
  objSaveFile.WriteLine GetOEMInfo("localhost") & GetSysInfo("localhost") & GetProductKey
  objSaveFile.Write "Last Runtime:  " & Date & " - " & Time
End Function

Function GetProductKey()
  Set wshShell = CreateObject("WScript.Shell")
  ' get product key from registry and convert it to proper format
  objPkey = ConvertToKey(wshShell.RegRead("HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\DigitalProductId"))
  objPkey = "Product Key:   " & objPkey
  ' output product key
  GetProductKey = objPkey
End Function

Function ConvertToKey(Key)
  ' found this function on the internet but lost the source...
  ' kudos to whoever originally came up with this function
  Const KeyOffset = 52
  i = 28
  Chars = "BCDFGHJKMPQRTVWXY2346789"
  Do
    Cur = 0
    x = 14
    Do
      Cur = Cur * 256
      Cur = Key(x + KeyOffset) + Cur
      Key(x + KeyOffset) = (Cur \ 24) And 255
      Cur = Cur Mod 24
      x = x -1
    Loop While x >= 0
    i = i -1
    KeyOutput = Mid(Chars, Cur + 1, 1) & KeyOutput
    If (((29 - i) Mod 6) = 0) And (i <> -1) Then
      i = i -1
      KeyOutput = "-" & KeyOutput
    End If
  Loop While i >= 0
  ' output product key
  ConvertToKey = KeyOutput
End Function

Function GetOEMInfo(strComputer)
  Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
  Set results = objWMIService.ExecQuery("Select * from Win32_ComputerSystem")
  ' create results array of manufacturer info
  Dim OEMInfo(2)
  For Each result in results
    OEMInfo(0) = "Manufacturer:  " & result.Manufacturer
    OEMInfo(1) = "Model:         " & result.Model
  next
  ' output array
  GetOEMInfo = Join(OEMInfo, vbNewLine)
End Function

Function GetSysInfo(strComputer)
  Set objWMIService = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
  Set results = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
  ' create results array of system info
  Dim SysInfo(2)
  For Each result in results
    SysInfo(0) = "OS (Build):    " & result.Caption & "(" & result.BuildNumber & ")"
    SysInfo(1) = "Version:       " & result.Version
  next
  ' output array
  GetSysInfo = Join(SysInfo, vbNewLine)
End Function
