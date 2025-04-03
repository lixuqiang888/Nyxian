/* all platform-specific includes and defines go in this file */
#ifndef PLATFORM_H
#define PLATFORM_H

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdarg.h>
#include <setjmp.h>
#include <math.h>
#include <stdbool.h>

# include <stdint.h>
# include <unistd.h>

#undef DEBUG_HEAP
#undef DEBUG_EXPRESSIONS
#undef FANCY_ERROR_MESSAGES
#undef DEBUG_ARRAY_INITIALIZER
#undef DEBUG_LEXER
#undef DEBUG_VAR_SCOPE


#if defined(__hppa__) || defined(__sparc__)
#define ALIGN_TYPE double
#else
#define ALIGN_TYPE void*
#endif

#define GLOBAL_TABLE_SIZE (97)                /* global variable table */
#define STRING_TABLE_SIZE (97)                /* shared string table size */
#define STRING_LITERAL_TABLE_SIZE (97)        /* string literal table size */
#define RESERVED_WORD_TABLE_SIZE (97)         /* reserved word table size */
#define PARAMETER_MAX (16)                    /* maximum number of parameters to a function */
#define LINEBUFFER_MAX (256)                  /* maximum number of characters on a line */
#define LOCAL_TABLE_SIZE (11)                 /* size of local variable table (can expand) */
#define STRUCT_TABLE_SIZE (11)                /* size of struct/union member table (can expand) */

#define INTERACTIVE_PROMPT_START "starting picoc " PICOC_VERSION " (\"exit;\" to exit)\n"
#define INTERACTIVE_PROMPT_STATEMENT "picoc> "
#define INTERACTIVE_PROMPT_LINE "     > "

extern jmp_buf ExitBuf;

#endif /* PLATFORM_H */
