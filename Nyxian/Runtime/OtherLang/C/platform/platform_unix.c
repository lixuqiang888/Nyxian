#include "../picoc.h"
#include "../interpreter.h"

#ifdef USE_READLINE
//#include <readline/readline.h>
//#include <readline/history.h>
#endif

#ifdef DEBUGGER
static int gEnableDebugger = true;
#else
static int gEnableDebugger = false;
#endif

/* mark where to end the program for platforms which require this */
jmp_buf PicocExitBuf;
jmp_buf PicocExitRBuf;

#ifdef DEBUGGER
#include <signal.h>

Picoc *break_pc = NULL;

static void BreakHandler(int Signal)
{
    break_pc->DebugManualBreak = true;
}

void PlatformInit(Picoc *pc)
{
    /* capture the break signal and pass it to the debugger */
    break_pc = pc;
    signal(SIGINT, BreakHandler);
}
#else
void PlatformInit(Picoc *pc) { }
#endif

void PlatformCleanup(Picoc *pc) { }

char *getbuffc(void);

// regardless no filestream
char *fgetsnyxian(char *buffer, int size) {
    if (size <= 1) return NULL;
    
    int csize = 0, cursor = 0;
    
    while (csize < size - 1) {
        fflush(stdout);
        char *seq = getbuffc();
        
        if(seq[0] != '\033')
        {
            if(seq[0] == 8 | seq[0] == 127)
            {
                if(csize != 0)
                {
                    printf("\b \b");
                    fflush(stdout);
                    cursor--;
                    csize--;
                    buffer[cursor] = '\0';
                }
            } else if (seq[0] == '\n' || seq[0] == '\r') {
                buffer[cursor] = seq[0];
                //putchar(seq[0]);
                break;
            } else {
                buffer[cursor] = seq[0];
                putchar(seq[0]);
                cursor++;
                csize++;
            }
        }
    }
    
    buffer[csize] = '\0';
    return buffer;
}

/* get a line of interactive input */
char *PlatformGetLine(char *Buf, int MaxLen, const char *Prompt)
{

    if (Prompt != NULL)
        printf("%s", Prompt);

    fflush(stdout);
    char *buffer = fgetsnyxian(Buf, MaxLen);
    printf("\n");
    return buffer;
}

/* get a character of interactive input */
int PlatformGetCharacter(void)
{
    fflush(stdout);
    return getchar();
}

/* write a character to the console */
void PlatformPutc(unsigned char OutCh, union OutputStreamInfo *Stream)
{
    putchar(OutCh);
}

/* read a file into memory */
char *PlatformReadFile(Picoc *pc, const char *FileName)
{
    struct stat FileInfo;
    char *ReadText;
    FILE *InFile;
    unsigned long BytesRead;
    char *p;

    if (stat(FileName, &FileInfo))
        ProgramFailNoParser(pc, "can't read file %s\n", FileName);

    ReadText = malloc(FileInfo.st_size + 1);
    if (ReadText == NULL)
        ProgramFailNoParser(pc, "out of memory\n");

    InFile = fopen(FileName, "r");
    if (InFile == NULL)
        ProgramFailNoParser(pc, "can't read file %s\n", FileName);

    BytesRead = fread(ReadText, 1, FileInfo.st_size, InFile);
    if (BytesRead == 0)
        ProgramFailNoParser(pc, "can't read file %s\n", FileName);

    ReadText[BytesRead] = '\0';
    fclose(InFile);

    if ((ReadText[0] == '#') && (ReadText[1] == '!')) {
        for (p = ReadText; (*p != '\0') && (*p != '\r') && (*p != '\n'); ++p) {
            *p = ' ';
        }
    }

    return ReadText;
}

/* read and scan a file for definitions */
void PicocPlatformScanFile(Picoc *pc, const char *FileName)
{
    char *SourceStr = PlatformReadFile(pc, FileName);

    /* ignore "#!/path/to/picoc" .. by replacing the "#!" with "//" */
    if (SourceStr != NULL && SourceStr[0] == '#' && SourceStr[1] == '!') {
        SourceStr[0] = '/';
        SourceStr[1] = '/';
    }

    PicocParse(pc, FileName, SourceStr, (int)strlen(SourceStr), true, false, true,
        gEnableDebugger);
}

/* exit the program */
void PlatformExit(Picoc *pc, int RetVal)
{
    pc->PicocExitValue = RetVal;
    longjmp(pc->PicocExitBuf, 1);
}

