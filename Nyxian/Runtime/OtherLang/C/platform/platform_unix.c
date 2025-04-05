#include "../picoc.h"
#include "../interpreter.h"
#include <Runtime/Hook/stdfd.h>

jmp_buf PicocExitBuf;
jmp_buf PicocExitRBuf;

void PlatformInit(Picoc *pc) {
    // do nothing
}

void PlatformCleanup(Picoc *pc) {
    // do nothing
}

char *PlatformGetLine(char *Buf, int MaxLen, const char *Prompt)
{
    if (Prompt != NULL)
        printf("%s", Prompt);

    fflush(stdfd_out_fp);
    return fgets(Buf, MaxLen, stdin);
}

int PlatformGetCharacter(void)
{
    fflush(stdfd_out_fp);
    return getchar();
}

void PlatformPutc(unsigned char OutCh, union OutputStreamInfo *Stream)
{
    putchar(OutCh);
}

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

void PicocPlatformScanFile(Picoc *pc, const char *FileName)
{
    char *SourceStr = PlatformReadFile(pc, FileName);

    if (SourceStr != NULL && SourceStr[0] == '#' && SourceStr[1] == '!') {
        SourceStr[0] = '/';
        SourceStr[1] = '/';
    }

    PicocParse(pc, FileName, SourceStr, (int)strlen(SourceStr), true, false, true, false);
}

void PlatformExit(Picoc *pc, int RetVal)
{
    pc->PicocExitValue = RetVal;
    longjmp(pc->PicocExitBuf, 1);
}

