{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
   ___         __
  |_ _| _ _   / _| ___  _ _  ___ ™
   | | | ' \ |  _|/ -_)| '_|/ _ \
  |___||_||_||_|  \___||_|  \___/
       LLM inference Library

Copyright © 2024-present tinyBigGAMES™ LLC
         All Rights Reserved.

Website: https://tinybiggames.com
Email  : support@tinybiggames.com
License: BSD 3-Clause License

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * }

unit Infero;

{$IFDEF FPC}
{$MODE DELPHIUNICODE}
{$ENDIF}

{$IFNDEF WIN64}
  {$MESSAGE Error 'Unsupported platform'}
{$ENDIF}

interface

const
  // Infero DLL
  INFERO_DLL = 'Infero.dll';

  // Console linefeed & carriage return
  LF   = #10;
  CR   = #13;
  CRLF = LF+CR;

  // Virtual Keys
  VK_ESC = 27;

  // Console colors
  BRIGHTYELLOW = 4 OR 2 OR 8;
  YELLOW       = 4 OR 2;
  WHITE        = 4 OR 2 OR 1;
  BRIGHTWHITE  = 4 OR 2 OR 1 OR 8;
  DARKGREEN    = 2;
  DARKGRAY     = 8;
  CYAN         = 2 OR 1;
  MAGENTA      = 4 OR 1;
  RED          = 4;

  // Message roles
  ROLE_SYSTEM    = 'system';
  ROLE_USER      = 'user';
  ROLE_ASSISTANT = 'assistant';
  ROLE_TOOL      = 'tool';

type
  // Callbacks types
  TInfero_ErrorCallback = procedure(const ASender: Pointer;
    const AError: PAnsiChar); cdecl;

  TInfero_InfoCallback = procedure(const ASender: Pointer;
    const ALevel: Integer; const AText: PAnsiChar); cdecl;

  TInfero_LoadModelProgressCallback = function(const ASender: Pointer;
    const AModelName: PAnsiChar; const AProgress: Single): Boolean; cdecl;

  TInfero_LoadModelCallback = procedure(const ASender: Pointer;
    const ASuccess: Boolean); cdecl;

  TInfero_InferenceStartCallback = procedure(const ASender: Pointer); cdecl;

  TInfero_InferenceDoneCallback = procedure(const ASender: Pointer;
    const AResponse: PAnsiChar); cdecl;

  TInfero_InferenceTokenCallback = procedure(const ASender: Pointer;
    const AToken: PAnsiChar); cdecl;

  // Callback record
  PInfero_Callbacks = ^TInfero_Callbacks;
  TInfero_Callbacks = record
    Sender: Pointer;
    ErrorCallback: TInfero_ErrorCallback;
    InfoCallback: TInfero_InfoCallback;
    LoadModelProgressCallback: TInfero_LoadModelProgressCallback;
    LoadModelCallback: TInfero_LoadModelCallback;
    InferenceStartCallback: TInfero_InferenceStartCallback;
    InferenceDoneCallback: TInfero_InferenceDoneCallback;
    InferenceTokenCallback: TInfero_InferenceTokenCallback;
  end;

  // Usage record
  PInfero_Usage = ^TInfero_Usage;
  TInfero_Usage = record
    TokenInputSpeed: Double;
    TokenOutputSpeed: Double;
    InputTokens: Int32;
    OutputTokens: Int32;
    TotalTokens: Int32;
  end;

{@@
Summary:
  Retrieve the Last Error Message.
Description:
  This function returns the last error message generated during operation.
Parameters:
  None.
Returns:
  A string representing the last error message.
}
function  Infero_GetLastError(): PAnsiChar;  cdecl; external INFERO_DLL;

{@@
Summary:
  Retrieve Infero Version Information.
Description:
  This function provides various pieces of version information about the Infero system.
Parameters:
  AName - The name associated with the version.
  ACodeName - The codename of the version.
  AMajorVersion - The major version number.
  AMinorVersion - The minor version number.
  APatchVersion - The patch version number.
  AVersion - The combined Major.Minor.Patch version string.
  AProject - The full version information string.
Returns:
  Returns specific version information if the respective parameter field is not NULL.
}
procedure Infero_GetVersionInfo(AName, ACodeName, AMajorVersion, AMinorVersion,
  APatchVersion, AVersion, AProject: PPAnsiChar); cdecl; external INFERO_DLL;

{@@
Summary:
  Create an Example Configuration File.
Description:
  This function generates an example configuration file with default settings and all validated model definitions.
Parameters:
  None.
Returns:
  TRUE on successful creation, FALSE on failure.
}
function  Infero_CreateExampleConfig(
  const AConfigFilename: PAnsiChar): Boolean; cdecl; external INFERO_DLL;

{@@
Summary:
  Initialize Infero.
Description:
  This function initializes the Infero system and prepares it for inferencing
  tasks. It is imperative to call this function prior to invoking any routines,
  except for Infero_GetLastError, Infero_CreateExampleConfig and
  Infero_Simple_Inference.
Parameters:
  AConfigFilename - Specifies the JSON configuration filename.
  ACallbacks - Defines the callback functions.
Returns:
}
function  Infero_Init(const AConfigFilename: PAnsiChar;
  const ACallbacks: PInfero_Callbacks): Boolean; cdecl; external INFERO_DLL;

{@@
Summary:
  Terminate Infero.
Description:
  This function shuts down the Infero system and releases all allocated
  resources. It must be invoked before the program terminates.
Parameters:
  None.
Returns:
  None.
}
procedure Infero_Quit(); cdecl; external INFERO_DLL;

{@@
Summary:
  Clear All Messages.
Description:
  This function clears all messages that have been added via the
  Infero_AddMessage function.
Parameters:
  None.
Returns:
  None.
}
procedure Infero_ClearMessages(); cdecl; external INFERO_DLL;

{@@
Summary:
  Add a New Message.
Description:
  This function adds a new chat message for inference purposes.
Parameters:
  ARole - The role of the message.
  AContent - The content of the message.
Returns:
  None.
}
procedure Infero_AddMessage(const ARole,
  AContent: PAnsiChar); cdecl; external INFERO_DLL;

{@@
Summary:
   Retrieve the Last User Message.
Description:
  This function returns the last message added with a role of "user" via
  Infero_AddMessage.
Parameters:
  None.
Returns:
  The last "user" message string.
}
function  Infero_GetLastUserMessage(): PAnsiChar; cdecl; external INFERO_DLL;

{@@
Summary:
  Run Inference on Loaded Model.
Description:
  This function performs inference on the loaded model using the questions
  added via Infero_AddMessage.
Parameters:
  AModelName - The reference name of the model.
  AMaxTokens - The maximum number of tokens to output.
  AResponse  - The inference response.
  AUsage     - The inference usage.
  AError     - The inference error message.
Returns:
  TRUE on success, FALSE on failure.
}
function  Infero_Inference(const AModelName: PAnsiChar;
  const AMaxTokens: UInt32; AResponse: PPAnsiChar=nil;
  const AUsage: PInfero_Usage=nil;
  const AError: PPAnsiChar=nil): Boolean; cdecl; external INFERO_DLL;

{@@
Summary:
  Simplified Inference Execution.
Description:
  This function performs a one-shot, fast inference using the specified
  configuration and model.
Parameters:
  AConfigFilename - The JSON configuration file.
  AModelName - The reference name of the model.
  AQuestion - The question for inference.
  AMaxTokens - The maximum number of output tokens.
Returns:
  The inference response string.
}
function  Infero_Simple_Inference(const AConfigFilename, AModelName,
  AQuestion: PAnsiChar; const AMaxTokens: UInt32): PAnsiChar;
  cdecl; external INFERO_DLL;

{@@
Summary:
  Clear Current Console Line.
Description:
  This function clears the current line on the console using the specified
  color.
Parameters:
  AColor - The console color constant.
Returns:
  None.
}
procedure Infero_ClearLine(AColor: WORD); cdecl; external INFERO_DLL;

{@@
Summary:
  Print to Console.
Description:
  This function prints text to the current console line in the specified color.
Parameters:
  AText - TThe text to print.
  AColor - he console color constant.
Returns:
}
procedure Infero_Print(const AText: PAnsiChar;
  const AColor: WORD=WHITE); cdecl; external INFERO_DLL;

implementation

{$IFNDEF FPC}
{$IF CompilerVersion < 36.0} // Delphi 12 corresponds to version 36.0
uses
  System.Math;
{$IFEND}
{$ENDIF}

initialization

{$IFNDEF FPC}
  ReportMemoryLeaksOnShutdown := True;

  {$IF CompilerVersion < 36.0} // Delphi 12 corresponds to version 36.0
  // disable floating point exceptions
  SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide, exOverflow, exUnderflow, exPrecision]);
  {$IFEND}

{$ENDIF}

finalization

end.
