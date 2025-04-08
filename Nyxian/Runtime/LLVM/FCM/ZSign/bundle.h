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
#include "common/common.h"
#include "common/json.h"
#include "openssl.h"

class ZAppBundle
{
public:
	ZAppBundle();

public:
    bool SignFolder(ZSignAsset *pSignAsset, const string &strFolder, const string &strBundleID, const string &strBundleVersion, const string &strDisplayName, const string &strDyLibFile, bool bForce, bool bWeakInject, bool bEnableCache);

private:
	bool SignNode(JValue &jvNode);
	void GetNodeChangedFiles(JValue &jvNode);
	void GetChangedFiles(JValue &jvNode, vector<string> &arrChangedFiles);
	void GetPlugIns(const string &strFolder, vector<string> &arrPlugIns);

private:
	bool FindAppFolder(const string &strFolder, string &strAppFolder);
	bool GetObjectsToSign(const string &strFolder, JValue &jvInfo);
	bool GetSignFolderInfo(const string &strFolder, JValue &jvNode, bool bGetName = false);

private:
	bool GenerateCodeResources(const string &strFolder, JValue &jvCodeRes);
	void GetFolderFiles(const string &strFolder, const string &strBaseFolder, set<string> &setFiles);

private:
	bool m_bForceSign;
	bool m_bWeakInject;
	string m_strDyLibPath;
	ZSignAsset *m_pSignAsset;

public:
	string m_strAppFolder;
};
