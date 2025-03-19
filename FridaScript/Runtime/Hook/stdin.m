//
//  stdin.m
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>

int stdin_hook_send_data = 0;
dispatch_semaphore_t stdin_hook_semaphore;
pthread_mutex_t data_safety_mutex;

/// Stdin hook support functions
void stdin_hook_prepare(void)
{
    stdin_hook_semaphore = dispatch_semaphore_create(0);
    pthread_mutex_init(&data_safety_mutex, NULL);
}

void stdin_hook_cleanup(void)
{
    pthread_mutex_destroy(&data_safety_mutex);
}

///
/// Function for Swift Term to call
///
void sendchar(int data)
{
    // mutex because hypothetically this could be called twice
    pthread_mutex_lock(&data_safety_mutex);
    
    // setting the data provided to us
    stdin_hook_send_data = data;
    
    // fire semaphore
    dispatch_semaphore_signal(stdin_hook_semaphore);
    
    // mutex unlock so another hypothetical call can process further
    pthread_mutex_unlock(&data_safety_mutex);
}

///
/// Hooked getchar
///
/// Function to receive the output of SwiftTerm
///
int getchar(void)
{
    // waiting on the signal from the swift term
    dispatch_semaphore_wait(stdin_hook_semaphore, DISPATCH_TIME_FOREVER);
    
    // sending input of swift term back to requestor
    return stdin_hook_send_data;
}
