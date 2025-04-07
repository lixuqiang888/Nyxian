//
//  ANSIPrinter.m
//  Nyxian
//
//  Created by fridakitten on 07.04.25.
//

#import <Runtime/ANSIPrinter.h>
#include <Runtime/Hook/stdfd.h>

void printfakeansi(int color, NSString *string)
{
    NSString *ansicolor = @"";
    
    switch (color) {
        case AP_GREEN:
            ansicolor = @"";
            break;
            
        default:
            break;
    }
}
