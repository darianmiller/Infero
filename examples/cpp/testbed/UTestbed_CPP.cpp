//---------------------------------------------------------------------------

#pragma hdrstop

#include <stdio.h>
#include <Infero.h>
#include "UTestbed_CPP.h"
//---------------------------------------------------------------------------
#pragma package(smart_init)

void Pause()
{
    printf("\n\nPress Enter to continue...");
    while (getchar() != '\n')
    {
        // Empty loop body; just looping until Enter is pressed
    }
    printf("\n");
}

void Test01()
{
	if (!Infero_Init("config.json", NULL))
        return;

    Infero_AddMessage(ROLE_SYSTEM, "You are a helpful AI assistant.");
    Infero_AddMessage(ROLE_USER, "What is AI?");
    //Infero_AddMessage(ROLE_USER, "short story about an AI than become self-aware.");
    
    if (Infero_Inference("phi3", 1024, NULL, NULL, NULL))
    {
        // success
    }
  else
    {
    	// failed
    }

    Infero_Quit();
}

void RunTests()
{
    Test01();
    Pause();
}

