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
#include "archo.h"

class ZMachO
{
public:
	ZMachO();
	~ZMachO();

public:
	bool Init(const char *szFile);
	bool InitV(const char *szFormatPath, ...);
	bool Free();
	void PrintInfo();
	bool Sign(ZSignAsset *pSignAsset, bool bForce, string strBundleId, string strInfoPlistSHA1, string strInfoPlistSHA256, const string &strCodeResourcesData);
	bool InjectDyLib(bool bWeakInject, const char *szDyLibPath, bool &bCreate);

private:
	bool OpenFile(const char *szPath);
	bool CloseFile();

	bool NewArchO(uint8_t *pBase, uint32_t uLength);
	void FreeArchOes();
	bool ReallocCodeSignSpace();

private:
	size_t m_sSize;
	string m_strFile;
	uint8_t *m_pBase;
	bool m_bCSRealloced;
	vector<ZArchO *> m_arrArchOes;
};
