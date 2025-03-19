//
//  tcom.h
//  FridaScript
//
//  Created by fridakitten on 19.03.25.
//

#ifndef TCOM_H
#define TCOM_H

#import <Foundation/Foundation.h>

/// Slave side functions
void tcom_set_size(int r, int c);

/// Master side functions
id tcom_get_size(void);

#endif
