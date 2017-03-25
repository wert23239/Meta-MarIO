// BizHawkThreader.cpp : Defines the entry point for the console application.
//


#include <stdio.h>
#include <cstdlib>
#include <string>
#include <vector>
#include <unistd.h>
#include <iostream>
#include <thread>


using namespace std;

/// path of emulator file 
string PATH_OF_EMULATOR = "./";

///
int THREAD_AMOUNT = 3;




/** progam converts string to char array & executes program 
  *@param: string 
  *
  */
void RunEmulator( string &command)
{
	 const char* thread_execution = command.c_str();
	 system(thread_execution);
}







int main(int argc, char *argv[])
{

	vector<thread> threads;

	// change of directory, will make more dynamic once ready to merge
	string current_command = PATH_OF_EMULATOR;
	const char* val = current_command.c_str();
	chdir(val);

	current_command = "./EmuHawkMulti.exe --thread-count=";


	for(int i= 1; i <= THREAD_AMOUNT; ++i)
	{
		current_command += to_string(i);

		threads.emplace_back(bind(&RunEmulator, current_command ));


	}



	for (auto &t : threads)
	{
		t.join();
	}		
		


    return EXIT_SUCCESS;

}
