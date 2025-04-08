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
#include "openssl.h"

bool ParseCodeSignature(uint8_t *pCSBase);
bool SlotBuildEntitlements(const string &strEntitlements, string &strOutput);
bool SlotBuildDerEntitlements(const string &strEntitlements, string &strOutput);
bool SlotBuildRequirements(const string &strBundleID, const string &strSubjectCN, string &strOutput);
bool GetCodeSignatureCodeSlotsData(uint8_t *pCSBase, uint8_t *&pCodeSlots1, uint32_t &uCodeSlots1Length, uint8_t *&pCodeSlots256, uint32_t &uCodeSlots256Length);
bool SlotBuildCodeDirectory(bool bAlternate,
							uint8_t *pCodeBase,
							uint32_t uCodeLength,
							uint8_t *pCodeSlotsData,
							uint32_t uCodeSlotsDataLength,
							uint64_t execSegLimit,
							uint64_t execSegFlags,
							const string &strBundleId,
							const string &strTeamId,
							const string &strInfoPlistSHA,
							const string &strRequirementsSlotSHA,
							const string &strCodeResourcesSHA,
							const string &strEntitlementsSlotSHA,
							const string &strDerEntitlementsSlotSHA,
							bool isExecuteArch,
							string &strOutput);
bool SlotBuildCMSSignature(ZSignAsset *pSignAsset,
						   const string &strCodeDirectorySlot,
						   const string &strAltnateCodeDirectorySlot,
						   string &strOutput);
bool GetCodeSignatureExistsCodeSlotsData(uint8_t *pCSBase,
										 uint8_t *&pCodeSlots1Data,
										 uint32_t &uCodeSlots1DataLength,
										 uint8_t *&pCodeSlots256Data,
										 uint32_t &uCodeSlots256DataLength);
uint32_t GetCodeSignatureLength(uint8_t *pCSBase);
