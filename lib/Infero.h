/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
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
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#ifndef INFERO_H
#define INFERO_H

// check for supported platform
#ifndef _WIN64
#error "Unsupported platform"
#endif

// link in Infero.lib
#pragma comment(lib,"Infero.lib")

// includes
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

// Infero API
#define INFERO_API __declspec(dllimport)

// Infero DLL
#define Infero_DLL "Infero.dll"

// Console linefeed & carriage return
#define LF   '\n'
#define CR   '\r'
#define CRLF "\r\n"

// Virtual Keys
#define VK_ESC 27

// Console colors
#define BRIGHTYELLOW (4 | 2 | 8)
#define YELLOW       (4 | 2)
#define WHITE        (4 | 2 | 1)
#define BRIGHTWHITE  (4 | 2 | 1 | 8)
#define DARKGREEN    2
#define DARKGRAY     8
#define CYAN         (2 | 1)
#define MAGENTA      (4 | 1)
#define RED          4

// Message roles
#define ROLE_SYSTEM    "system"
#define ROLE_USER      "user"
#define ROLE_ASSISTANT "assistant"
#define ROLE_TOOL      "tool"

// Callbacks types
typedef void (*TInfero_ErrorCallback)(const void* ASender, const char* AError);
typedef void (*TInfero_InfoCallback)(const void* ASender, int ALevel, const char* AText);
typedef bool (*TInfero_LoadModelProgressCallback)(const void* ASender, const char* AModelName, float AProgress);
typedef void (*TInfero_LoadModelCallback)(const void* ASender, bool ASuccess);
typedef void (*TInfero_InferenceStartCallback)(const void* ASender);
typedef void (*TInfero_InferenceDoneCallback)(const void* ASender, const char* AResponse);
typedef void (*TInfero_InferenceTokenCallback)(const void* ASender, const char* AToken);

// Callback struct
typedef struct {
    void* Sender;
    TInfero_ErrorCallback ErrorCallback;
    TInfero_InfoCallback InfoCallback;
    TInfero_LoadModelProgressCallback LoadModelProgressCallback;
    TInfero_LoadModelCallback LoadModelCallback;
    TInfero_InferenceStartCallback InferenceStartCallback;
    TInfero_InferenceDoneCallback InferenceDoneCallback;
    TInfero_InferenceTokenCallback InferenceTokenCallback;
} TInfero_Callbacks;

// Usage struct
typedef struct {
    double TokenInputSpeed;
    double TokenOutputSpeed;
    int InputTokens;
    int OutputTokens;
    int TotalTokens;
} TInfero_Usage;

// Get Last Error
INFERO_API char* Infero_GetLastError();

// Get Infero version information
INFERO_API void Infero_GetVersionInfo(char** AName, char** ACodeName,
  char** AMajorVersion, char** AMinorVersion, char** APatchVersion,
  char** AVersion, char** AProject);

// Create an example config.json file  
INFERO_API int Infero_CreateExampleConfig(const char* AConfigFilename);

// Init Infero, loading a config.json file, init callbacks, call before any
// other routine except Infero_GetVersionInfo, Infero_CreateExampleConfig
INFERO_API bool Infero_Init(const char* AConfigFilename,
  const TInfero_Callbacks* ACallbacks);
  
// Quit Infero, call before program shutdown  
INFERO_API void Infero_Quit();

// Clear all messages
INFERO_API void Infero_ClearMessages();

// Add a new message for inference
INFERO_API void Infero_AddMessage(const char* ARole, const char* AContent);

// Get last "user" role message added to messages
INFERO_API const char* Infero_GetLastUserMessage();

// Do inference on model, up to AMaxTokens, get response, usage and error
INFERO_API bool Infero_Inference(const char* AModelName,
  const unsigned int AMaxTokens, char** AResponse,
  const TInfero_Usage* AUsage, char** AError);
  
// Do inference on model with a single call. It will return a response
// to your question or an error if failed.
INFERO_API char * Infero_Simple_Inference(const char * AConfigFilename,
  const char * AModelName, const char * AQuestion,
  const unsigned int AMaxTokens);
  
// Clear the current console line  
INFERO_API void Infero_ClearLine(unsigned short AColor);

// Print text to console
INFERO_API void Infero_Print(const char* AText, unsigned short AColor);

#ifdef __cplusplus
}
#endif

#endif // INFERO_H
