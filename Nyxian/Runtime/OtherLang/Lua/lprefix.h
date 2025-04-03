/*
** $Id: lprefix.h $
** Definitions for Lua code that must come before any other header file
** See Copyright Notice in lua.h
*/

#ifndef lprefix_h
#define lprefix_h

#if !defined(LUA_USE_C89)

#if !defined(_XOPEN_SOURCE)
#define _XOPEN_SOURCE           600
#elif _XOPEN_SOURCE == 0
#undef _XOPEN_SOURCE
#endif

#if !defined(LUA_32BITS) && !defined(_FILE_OFFSET_BITS)
#define _LARGEFILE_SOURCE       1
#define _FILE_OFFSET_BITS       64
#endif

#endif

#endif

