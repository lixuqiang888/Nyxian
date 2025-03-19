//
//  tcom.c
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#import <Runtime/Hook/tcom.h>
#import <Runtime/ReturnObjBuilder.h>

/// Holder for the Terminal Information
int tcom_rows = 0;
int tcom_coloumns = 0;

/// Slave side functions
void tcom_set_size(int r, int c)
{
    tcom_rows = r;
    tcom_coloumns = c;
}

/// Master side functions
id tcom_get_size(void)
{
    return ReturnObjectBuilder(@{
        @"rows": @(tcom_rows),
        @"coloumns": @(tcom_coloumns),
    });
}
