/*
 MIT License

 Copyright (c) 2025 SeanIsTethered

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#pragma once
#include "common/mach-o.h"
#include "openssl.h"
#include <set>
class ZArchO
{
public:
	ZArchO();
	bool Init(uint8_t *pBase, uint32_t uLength);

public:
	bool Sign(ZSignAsset *pSignAsset, bool bForce, const string &strBundleId, const string &strInfoPlistSHA1, const string &strInfoPlistSHA256, const string &strCodeResourcesData);
	void PrintInfo();
	bool IsExecute();
	bool InjectDyLib(bool bWeakInject, const char *szDyLibPath, bool &bCreate);
	uint32_t ReallocCodeSignSpace(const string &strNewFile);
    void uninstallDylibs(set<string> dylibNames);

private:
	uint32_t BO(uint32_t uVal);
	const char *GetFileType(uint32_t uFileType);
	const char *GetArch(int cpuType, int cpuSubType);
	bool BuildCodeSignature(ZSignAsset *pSignAsset, bool bForce, const string &strBundleId, const string &strInfoPlistSHA1, const string &strInfoPlistSHA256, const string &strCodeResourcesSHA1, const string &strCodeResourcesSHA256, string &strOutput);

public:
	uint8_t *m_pBase;
	uint32_t m_uLength;
	uint32_t m_uCodeLength;
	uint8_t *m_pSignBase;
	uint32_t m_uSignLength;
	string m_strInfoPlist;
	bool m_bEncrypted;
	bool m_b64;
	bool m_bBigEndian;
	bool m_bEnoughSpace;
	uint8_t *m_pCodeSignSegment;
	uint8_t *m_pLinkEditSegment;
	uint32_t m_uLoadCommandsFreeSpace;
	mach_header *m_pHeader;
	uint32_t m_uHeaderSize;
};
