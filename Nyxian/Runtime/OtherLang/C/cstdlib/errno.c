#include <errno.h>
#include "../interpreter.h"

static int EACCESValue = EACCES;
static int EADDRINUSEValue = EADDRINUSE;
static int EADDRNOTAVAILValue = EADDRNOTAVAIL;
static int EAFNOSUPPORTValue = EAFNOSUPPORT;
static int EAGAINValue = EAGAIN;
static int EALREADYValue = EALREADY;
static int EBADFValue = EBADF;
static int EBADMSGValue = EBADMSG;
static int EBUSYValue = EBUSY;
static int ECANCELEDValue = ECANCELED;
static int ECHILDValue = ECHILD;
static int ECONNABORTEDValue = ECONNABORTED;
static int ECONNREFUSEDValue = ECONNREFUSED;
static int ECONNRESETValue = ECONNRESET;
static int EDEADLKValue = EDEADLK;
static int EDESTADDRREQValue = EDESTADDRREQ;
static int EDOMValue = EDOM;
static int EDQUOTValue = EDQUOT;
static int EEXISTValue = EEXIST;
static int EFAULTValue = EFAULT;
static int EFBIGValue = EFBIG;
static int EHOSTUNREACHValue = EHOSTUNREACH;
static int EIDRMValue = EIDRM;
static int EILSEQValue = EILSEQ;
static int EINPROGRESSValue = EINPROGRESS;
static int EINTRValue = EINTR;
static int EINVALValue = EINVAL;
static int EIOValue = EIO;
static int EISCONNValue = EISCONN;
static int EISDIRValue = EISDIR;
static int ELOOPValue = ELOOP;
static int EMFILEValue = EMFILE;
static int EMLINKValue = EMLINK;
static int EMSGSIZEValue = EMSGSIZE;
static int EMULTIHOPValue = EMULTIHOP;
static int ENAMETOOLONGValue = ENAMETOOLONG;
static int ENETDOWNValue = ENETDOWN;
static int ENETRESETValue = ENETRESET;
static int ENETUNREACHValue = ENETUNREACH;
static int ENFILEValue = ENFILE;
static int ENOBUFSValue = ENOBUFS;
static int ENODATAValue = ENODATA;
static int ENODEVValue = ENODEV;
static int ENOENTValue = ENOENT;
static int ENOEXECValue = ENOEXEC;
static int ENOLCKValue = ENOLCK;
static int ENOLINKValue = ENOLINK;
static int ENOMEMValue = ENOMEM;
static int ENOMSGValue = ENOMSG;
static int ENOPROTOOPTValue = ENOPROTOOPT;
static int ENOSPCValue = ENOSPC;
static int ENOSRValue = ENOSR;
static int ENOSTRValue = ENOSTR;
static int ENOSYSValue = ENOSYS;
static int ENOTCONNValue = ENOTCONN;
static int ENOTDIRValue = ENOTDIR;
static int ENOTEMPTYValue = ENOTEMPTY;
static int ENOTRECOVERABLEValue = ENOTRECOVERABLE;
static int ENOTSOCKValue = ENOTSOCK;
static int ENOTSUPValue = ENOTSUP;
static int ENOTTYValue = ENOTTY;
static int ENXIOValue = ENXIO;
static int EOPNOTSUPPValue = EOPNOTSUPP;
static int EOVERFLOWValue = EOVERFLOW;
static int EOWNERDEADValue = EOWNERDEAD;
static int EPERMValue = EPERM;
static int EPIPEValue = EPIPE;
static int EPROTOValue = EPROTO;
static int EPROTONOSUPPORTValue = EPROTONOSUPPORT;
static int EPROTOTYPEValue = EPROTOTYPE;
static int ERANGEValue = ERANGE;
static int EROFSValue = EROFS;
static int ESPIPEValue = ESPIPE;
static int ESRCHValue = ESRCH;
static int ESTALEValue = ESTALE;
static int ETIMEValue = ETIME;
static int ETIMEDOUTValue = ETIMEDOUT;
static int ETXTBSYValue = ETXTBSY;
static int EWOULDBLOCKValue = EWOULDBLOCK;
static int EXDEVValue = EXDEV;

void StdErrnoSetupFunc(Picoc *pc)
{
    VariableDefinePlatformVar(pc, NULL, "EACCES", &pc->IntType,
        (union AnyValue*)&EACCESValue, false);
    VariableDefinePlatformVar(pc, NULL, "EADDRINUSE", &pc->IntType,
        (union AnyValue*)&EADDRINUSEValue, false);
    VariableDefinePlatformVar(pc, NULL, "EADDRNOTAVAIL", &pc->IntType,
        (union AnyValue*)&EADDRNOTAVAILValue, false);
    VariableDefinePlatformVar(pc, NULL, "EAFNOSUPPORT", &pc->IntType,
        (union AnyValue*)&EAFNOSUPPORTValue, false);
    VariableDefinePlatformVar(pc, NULL, "EAGAIN", &pc->IntType,
        (union AnyValue*)&EAGAINValue, false);
    VariableDefinePlatformVar(pc, NULL, "EALREADY", &pc->IntType,
        (union AnyValue*)&EALREADYValue, false);
    VariableDefinePlatformVar(pc, NULL, "EBADF", &pc->IntType,
        (union AnyValue*)&EBADFValue, false);
    VariableDefinePlatformVar(pc, NULL, "EBADMSG", &pc->IntType,
        (union AnyValue*)&EBADMSGValue, false);
    VariableDefinePlatformVar(pc, NULL, "EBUSY", &pc->IntType,
        (union AnyValue*)&EBUSYValue, false);
    VariableDefinePlatformVar(pc, NULL, "ECANCELED", &pc->IntType,
        (union AnyValue*)&ECANCELEDValue, false);
    VariableDefinePlatformVar(pc, NULL, "ECHILD", &pc->IntType,
        (union AnyValue*)&ECHILDValue, false);
    VariableDefinePlatformVar(pc, NULL, "ECONNABORTED", &pc->IntType,
        (union AnyValue*)&ECONNABORTEDValue, false);
    VariableDefinePlatformVar(pc, NULL, "ECONNREFUSED", &pc->IntType,
        (union AnyValue*)&ECONNREFUSEDValue, false);
    VariableDefinePlatformVar(pc, NULL, "ECONNRESET", &pc->IntType,
        (union AnyValue*)&ECONNRESETValue, false);
    VariableDefinePlatformVar(pc, NULL, "EDEADLK", &pc->IntType,
        (union AnyValue*)&EDEADLKValue, false);
    VariableDefinePlatformVar(pc, NULL, "EDESTADDRREQ", &pc->IntType,
        (union AnyValue*)&EDESTADDRREQValue, false);
    VariableDefinePlatformVar(pc, NULL, "EDOM", &pc->IntType,
        (union AnyValue*)&EDOMValue, false);
    VariableDefinePlatformVar(pc, NULL, "EDQUOT", &pc->IntType,
        (union AnyValue*)&EDQUOTValue, false);
    VariableDefinePlatformVar(pc, NULL, "EEXIST", &pc->IntType,
        (union AnyValue*)&EEXISTValue, false);
    VariableDefinePlatformVar(pc, NULL, "EFAULT", &pc->IntType,
        (union AnyValue*)&EFAULTValue, false);
    VariableDefinePlatformVar(pc, NULL, "EFBIG", &pc->IntType,
        (union AnyValue*)&EFBIGValue, false);
    VariableDefinePlatformVar(pc, NULL, "EHOSTUNREACH", &pc->IntType,
        (union AnyValue*)&EHOSTUNREACHValue, false);
    VariableDefinePlatformVar(pc, NULL, "EIDRM", &pc->IntType,
        (union AnyValue*)&EIDRMValue, false);
    VariableDefinePlatformVar(pc, NULL, "EILSEQ", &pc->IntType,
        (union AnyValue*)&EILSEQValue, false);
    VariableDefinePlatformVar(pc, NULL, "EINPROGRESS", &pc->IntType,
        (union AnyValue*)&EINPROGRESSValue, false);
    VariableDefinePlatformVar(pc, NULL, "EINTR", &pc->IntType,
        (union AnyValue*)&EINTRValue, false);
    VariableDefinePlatformVar(pc, NULL, "EINVAL", &pc->IntType,
        (union AnyValue*)&EINVALValue, false);
    VariableDefinePlatformVar(pc, NULL, "EIO", &pc->IntType,
        (union AnyValue*)&EIOValue, false);
    VariableDefinePlatformVar(pc, NULL, "EISCONN", &pc->IntType,
        (union AnyValue*)&EISCONNValue, false);
    VariableDefinePlatformVar(pc, NULL, "EISDIR", &pc->IntType,
        (union AnyValue*)&EISDIRValue, false);
    VariableDefinePlatformVar(pc, NULL, "ELOOP", &pc->IntType,
        (union AnyValue*)&ELOOPValue, false);
    VariableDefinePlatformVar(pc, NULL, "EMFILE", &pc->IntType,
        (union AnyValue*)&EMFILEValue, false);
    VariableDefinePlatformVar(pc, NULL, "EMLINK", &pc->IntType,
        (union AnyValue*)&EMLINKValue, false);
    VariableDefinePlatformVar(pc, NULL, "EMSGSIZE", &pc->IntType,
        (union AnyValue*)&EMSGSIZEValue, false);
    VariableDefinePlatformVar(pc, NULL, "EMULTIHOP", &pc->IntType,
        (union AnyValue*)&EMULTIHOPValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENAMETOOLONG", &pc->IntType,
        (union AnyValue*)&ENAMETOOLONGValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENETDOWN", &pc->IntType,
        (union AnyValue*)&ENETDOWNValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENETRESET", &pc->IntType,
        (union AnyValue*)&ENETRESETValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENETUNREACH", &pc->IntType,
        (union AnyValue*)&ENETUNREACHValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENFILE", &pc->IntType,
        (union AnyValue*)&ENFILEValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOBUFS", &pc->IntType,
        (union AnyValue*)&ENOBUFSValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENODATA", &pc->IntType,
        (union AnyValue*)&ENODATAValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENODEV", &pc->IntType,
        (union AnyValue*)&ENODEVValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOENT", &pc->IntType,
        (union AnyValue*)&ENOENTValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOEXEC", &pc->IntType,
        (union AnyValue*)&ENOEXECValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOLCK", &pc->IntType,
        (union AnyValue*)&ENOLCKValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOLINK", &pc->IntType,
        (union AnyValue*)&ENOLINKValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOMEM", &pc->IntType,
        (union AnyValue*)&ENOMEMValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOMSG", &pc->IntType,
        (union AnyValue*)&ENOMSGValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOPROTOOPT", &pc->IntType,
        (union AnyValue*)&ENOPROTOOPTValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOSPC", &pc->IntType,
        (union AnyValue*)&ENOSPCValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOSR", &pc->IntType,
        (union AnyValue*)&ENOSRValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOSTR", &pc->IntType,
        (union AnyValue*)&ENOSTRValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOSYS", &pc->IntType,
        (union AnyValue*)&ENOSYSValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTCONN", &pc->IntType,
        (union AnyValue*)&ENOTCONNValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTDIR", &pc->IntType,
        (union AnyValue*)&ENOTDIRValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTEMPTY", &pc->IntType,
        (union AnyValue*)&ENOTEMPTYValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTRECOVERABLE", &pc->IntType,
        (union AnyValue*)&ENOTRECOVERABLEValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTSOCK", &pc->IntType,
        (union AnyValue*)&ENOTSOCKValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTSUP", &pc->IntType,
        (union AnyValue*)&ENOTSUPValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENOTTY", &pc->IntType,
        (union AnyValue*)&ENOTTYValue, false);
    VariableDefinePlatformVar(pc, NULL, "ENXIO", &pc->IntType,
        (union AnyValue*)&ENXIOValue, false);
    VariableDefinePlatformVar(pc, NULL, "EOPNOTSUPP", &pc->IntType,
        (union AnyValue*)&EOPNOTSUPPValue, false);
    VariableDefinePlatformVar(pc, NULL, "EOVERFLOW", &pc->IntType,
        (union AnyValue*)&EOVERFLOWValue, false);
    VariableDefinePlatformVar(pc, NULL, "EOWNERDEAD", &pc->IntType,
        (union AnyValue*)&EOWNERDEADValue, false);
    VariableDefinePlatformVar(pc, NULL, "EPERM", &pc->IntType,
        (union AnyValue*)&EPERMValue, false);
    VariableDefinePlatformVar(pc, NULL, "EPIPE", &pc->IntType,
        (union AnyValue*)&EPIPEValue, false);
    VariableDefinePlatformVar(pc, NULL, "EPROTO", &pc->IntType,
        (union AnyValue*)&EPROTOValue, false);
    VariableDefinePlatformVar(pc, NULL, "EPROTONOSUPPORT", &pc->IntType,
        (union AnyValue*)&EPROTONOSUPPORTValue, false);
    VariableDefinePlatformVar(pc, NULL, "EPROTOTYPE", &pc->IntType,
        (union AnyValue*)&EPROTOTYPEValue, false);
    VariableDefinePlatformVar(pc, NULL, "ERANGE", &pc->IntType,
        (union AnyValue*)&ERANGEValue, false);
    VariableDefinePlatformVar(pc, NULL, "EROFS", &pc->IntType,
        (union AnyValue*)&EROFSValue, false);
    VariableDefinePlatformVar(pc, NULL, "ESPIPE", &pc->IntType,
        (union AnyValue*)&ESPIPEValue, false);
    VariableDefinePlatformVar(pc, NULL, "ESRCH", &pc->IntType,
        (union AnyValue*)&ESRCHValue, false);
    VariableDefinePlatformVar(pc, NULL, "ESTALE", &pc->IntType,
        (union AnyValue*)&ESTALEValue, false);
    VariableDefinePlatformVar(pc, NULL, "ETIME", &pc->IntType,
        (union AnyValue*)&ETIMEValue, false);
    VariableDefinePlatformVar(pc, NULL, "ETIMEDOUT", &pc->IntType,
        (union AnyValue*)&ETIMEDOUTValue, false);
    VariableDefinePlatformVar(pc, NULL, "ETXTBSY", &pc->IntType,
        (union AnyValue*)&ETXTBSYValue, false);
    VariableDefinePlatformVar(pc, NULL, "EWOULDBLOCK", &pc->IntType,
        (union AnyValue*)&EWOULDBLOCKValue, false);
    VariableDefinePlatformVar(pc, NULL, "EXDEV", &pc->IntType,
        (union AnyValue*)&EXDEVValue, false);

    VariableDefinePlatformVar(pc, NULL, "errno", &pc->IntType,
        (union AnyValue*)&errno, true);
}

