//
//  stdin.h
//  Nyxian
//
//  Created by fridakitten on 20.03.25.
//

#import <Foundation/Foundation.h>

/// Stdin hook support functions
void stdin_hook_prepare(void);
void stdin_hook_cleanup(void);

///
/// Function for Swift Term to call
///
void sendchar(const uint8_t *ro_buffer, size_t len);

///
/// Hooked getchar
///
/// Function to receive the output of SwiftTerm
///
int getchar(void);

///
/// Sister function of getchar called getbuff
///
id getbuff(void);
