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

unit UTestbed_PAS;

interface

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  WinApi.Windows,
  Infero;

procedure RunTests();

implementation

procedure Pause();
begin
  Infero_Print(CRLF, WHITE);
  Infero_Print('Press ENTER to continue...', WHITE);
  ReadLn;
  Infero_Print(CRLF, WHITE);
end;

// Error callback
procedure OnError(const ASender: Pointer; const AError: PAnsiChar); cdecl;
begin
end;

// Inference Start callback
procedure OnInferenceStart(const ASender: Pointer); cdecl;
begin
  // display user message
  Infero_Print(CRLF, WHITE);
  Infero_Print(Infero_GetLastUserMessage(), DARKGREEN);
  Infero_Print(CRLF, WHITE);
end;

// Inference Done callback
procedure OnInferenceDone(const ASender: Pointer; const AResponse: PAnsiChar); cdecl;
begin
end;

// Inference Token callback
procedure OnInferenceToken(const ASender: Pointer; const AToken: PAnsiChar); cdecl;
begin
  Infero_Print(AToken, WHITE);
end;

// Information callback
procedure OnInfo(const ASender: Pointer; const ALevel: Integer; const AText: PAnsiChar); cdecl;
begin
  Infero_Print(AText, DARKGRAY); // comment out to not display info
end;

function OnLoadModelProgress(const ASender: Pointer; const AModelName: PAnsiChar; const AProgress: Single): Boolean; cdecl;
begin
  Infero_Print(PUTF8Char(UTF8Encode(Format(CR+'Loading model "%s" (%3.2f%s)...', [AModelName, AProgress*100, '%']))), CYAN);
  Result := True;
end;

// Load Model callback
procedure OnLoadModel(const ASender: Pointer; const ASuccess: Boolean); cdecl;
begin
  Infero_ClearLine(WHITE);
  Infero_Print(CR, WHITE);
end;

// Create an example config file
procedure Test01();
begin
  // create an example config.json for reference
  // you can manually edit this to change your Infero settings,
  // add new models, etc.
  Infero_Print('Creating example_config.json file...', WHITE);
  Infero_Print(CRLF, WHITE);
  Infero_CreateExampleConfig('example_config.json');
end;

// Simple Query
procedure Test02();
const
  CModel = 'phi3';
  //CModel = 'llama3';
  //CModel = 'wizardlm2';
  //CModel = 'hermes2';

  //CPrompt = 'Who are you?';
  //CPrompt = 'Who is Bill Gates?';
  //CPrompt = 'Why is the sky blue?';
  //CPrompt = 'A story about an AI coming to life.';
  CPrompt = 'What is AI?';
  //CPrompt = 'Почему снег холодный?'; //Why snow is cold?
  //CPrompt = 'Translate to Japanies, Spaish and Italian: Hello, how are you?';
  //CPrompt = 'List countries with provinces';

var
  LCallbacks: TInfero_Callbacks;
  LUsage: TInfero_Usage;
  LResponse: PAnsiChar;
  LError: PAnsiChar;
begin
  LCallbacks := Default(TInfero_Callbacks);
  LCallbacks.ErrorCallback := OnError;
  LCallbacks.InfoCallback := OnInfo;
  LCallbacks.LoadModelProgressCallback := OnLoadModelProgress;
  LCallbacks.LoadModelCallback := OnLoadModel;
  LCallbacks.InferenceStartCallback := OnInferenceStart;
  LCallbacks.InferenceDoneCallback := OnInferenceDone;
  LCallbacks.InferenceTokenCallback := OnInferenceToken;

  if not Infero_Init('config.json', @LCallbacks) then
    Exit;
  try
    Infero_AddMessage(ROLE_SYSTEM, 'You are a helpful AI assistant.');
    Infero_AddMessage(ROLE_USER, PUTF8Char(UTF8Encode(CPrompt)));
    if Infero_Inference(CModel, 1024, @LResponse, @LUsage, @LError) then
    begin
      Infero_Print(PUTF8Char(UTF8Encode(Format(CRLF+'Tokens :: Input: %d, Output: %d, Total: %d, Speed: %3.1f t/s',
        [LUsage.InputTokens, LUsage.OutputTokens, LUsage.TotalTokens, LUsage.TokenOutputSpeed]))), BRIGHTYELLOW);
    end
  else
    begin
      Infero_Print(PUTF8Char(UTF8Encode(Format('Error: %s', [LError]))), RED);
    end;
  finally
    Infero_Quit();
  end;
  Infero_Print(CRLF, WHITE);
end;

// Function Calling
procedure Test03();
begin
  Writeln('Q: What is AI?...');
  Writeln('A: ', Infero_Simple_Inference('config.json', 'phi3', 'what is AI?', 1024));
end;

// Simple Query
procedure Test04();
const
  CSystem =
  '''
  You are a function calling AI model.
  You are provided with function signatures within <tools></tools> XML tags.
  You may call one or more functions to assist with the user query.
  Don't make assumptions about what values to plug into functions.
  Here are the available tools: <tools> {"type": "function", "function": {"name": "get_stock_fundamentals", "description": "get_stock_fundamentals(symbol: str) -> dict - Get fundamental data for a given stock symbol using yfinance API.\\n\\n Args:\\n symbol (str): The stock symbol.\\n\\n Returns:\\n dict: A dictionary containing fundamental data.\\n Keys:\\n - \'symbol\': The stock symbol.\\n - \'company_name\': The long name of the company.\\n - \'sector\': The sector to which the company belongs.\\n - \'industry\': The industry to which the company belongs.\\n - \'market_cap\': The market capitalization of the company.\\n - \'pe_ratio\': The forward price-to-earnings ratio.\\n - \'pb_ratio\': The price-to-book ratio.\\n - \'dividend_yield\': The dividend yield.\\n - \'eps\': The trailing earnings per share.\\n - \'beta\': The beta value of the stock.\\n - \'52_week_high\': The 52-week high price of the stock.\\n - \'52_week_low\': The 52-week low price of the stock.", "parameters": {"type": "object", "properties": {"symbol": {"type": "string"}}, "required": ["symbol"]}}}  </tools> Use the following pydantic model json schema for each tool call you will make: {"properties": {"arguments": {"title": "Arguments", "type": "object"}, "name": {"title": "Name", "type": "string"}}, "required": ["arguments", "name"], "title": "FunctionCall", "type": "object"} For each function call return a json object with function name and arguments within <tool_call></tool_call> XML tags as follows:
  <tool_call>
  {"arguments": <args-dict>, "name": <function-name>}
  </tool_call>
  ''';

  CUser =
  '''
  Fetch the stock fundamentals data for Tesla (TSLA)
  ''';

  CAssistant =
  '''
  <tool_call>
  {"arguments": {"symbol": "TSLA"}, "name": "get_stock_fundamentals"}
  </tool_call>
  ''';

  CTool =
  '''
  <tool_response>
  {"name": "get_stock_fundamentals", "content": {'symbol': 'TSLA', 'company_name': 'Tesla, Inc.', 'sector': 'Consumer Cyclical', 'industry': 'Auto Manufacturers', 'market_cap': 611384164352, 'pe_ratio': 49.604652, 'pb_ratio': 9.762013, 'dividend_yield': None, 'eps': 4.3, 'beta': 2.427, '52_week_high': 299.29, '52_week_low': 152.37}}
  </tool_response>
  ''';
var
  LCallbacks: TInfero_Callbacks;
  LUsage: TInfero_Usage;
  LResponse: PAnsiChar;
  LError: PAnsiChar;
begin
  LCallbacks := Default(TInfero_Callbacks);
  LCallbacks.ErrorCallback := OnError;
  LCallbacks.InfoCallback := OnInfo;
  LCallbacks.LoadModelProgressCallback := OnLoadModelProgress;
  LCallbacks.LoadModelCallback := OnLoadModel;
  LCallbacks.InferenceStartCallback := OnInferenceStart;
  LCallbacks.InferenceDoneCallback := OnInferenceDone;
  LCallbacks.InferenceTokenCallback := OnInferenceToken;

  if not Infero_Init('config.json', @LCallbacks) then
    Exit;
  try
    Infero_AddMessage(ROLE_SYSTEM, CSystem);
    Infero_AddMessage(ROLE_USER, CUser);
    Infero_AddMessage(ROLE_ASSISTANT, CAssistant);
    Infero_AddMessage(ROLE_TOOL, CTool);

    if Infero_Inference('hermes2', 1024, @LResponse, @LUsage, @LError) then
    begin
      Infero_Print(PUTF8Char(UTF8Encode(Format(CRLF+'Tokens :: Input: %d, Output: %d, Total: %d, Speed: %3.1f t/s',
        [LUsage.InputTokens, LUsage.OutputTokens, LUsage.TotalTokens, LUsage.TokenOutputSpeed]))), BRIGHTYELLOW);
    end
  else
    begin
      Infero_Print(PUTF8Char(UTF8Encode(Format('Error: %s', [LError]))), RED);
    end;
  finally
    Infero_Quit();
  end;
  Infero_Print(CRLF, WHITE);
end;

procedure RunTests();
begin
  //Test01();
  Test02();
  //Test03();
  //Test04();
  Pause();
end;

end.
