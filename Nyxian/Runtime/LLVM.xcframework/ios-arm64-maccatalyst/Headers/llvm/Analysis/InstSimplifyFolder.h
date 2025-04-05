//===- InstSimplifyFolder.h - InstSimplify folding helper --------*- C++-*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file defines the InstSimplifyFolder class, a helper for IRBuilder.
// It provides IRBuilder with a set of methods for folding operations to
// existing values using InstructionSimplify. At the moment, only a subset of
// the implementation uses InstructionSimplify. The rest of the implementation
// only folds constants.
//
// The folder also applies target-specific constant folding.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_ANALYSIS_INSTSIMPLIFYFOLDER_H
#define LLVM_ANALYSIS_INSTSIMPLIFYFOLDER_H

#include "llvm/ADT/ArrayRef.h"
#include "llvm/Analysis/InstructionSimplify.h"
#include "llvm/Analysis/TargetFolder.h"
#include "llvm/IR/IRBuilderFolder.h"
#include "llvm/IR/Instruction.h"

namespace llvm {
class Constant;

/// InstSimplifyFolder - Use InstructionSimplify to fold operations to existing
/// values. Also applies target-specific constant folding when not using
/// InstructionSimplify.
class InstSimplifyFolder final : public IRBuilderFolder {
  TargetFolder ConstFolder;
  SimplifyQuery SQ;

  virtual void anchor();

public:
  InstSimplifyFolder(const DataLayout &DL) : ConstFolder(DL), SQ(DL) {}

  //===--------------------------------------------------------------------===//
  // Value-based folders.
  //
  // Return an existing value or a constant if the operation can be simplified.
  // Otherwise return nullptr.
  //===--------------------------------------------------------------------===//

  Value *FoldBinOp(Instruction::BinaryOps Opc, Value *LHS,
                   Value *RHS) const override {
    return simplifyBinOp(Opc, LHS, RHS, SQ);
  }

  Value *FoldExactBinOp(Instruction::BinaryOps Opc, Value *LHS, Value *RHS,
                        bool IsExact) const override {
    return simplifyBinOp(Opc, LHS, RHS, SQ);
  }

  Value *FoldNoWrapBinOp(Instruction::BinaryOps Opc, Value *LHS, Value *RHS,
                         bool HasNUW, bool HasNSW) const override {
    return simplifyBinOp(Opc, LHS, RHS, SQ);
  }

  Value *FoldBinOpFMF(Instruction::BinaryOps Opc, Value *LHS, Value *RHS,
                      FastMathFlags FMF) const override {
    return simplifyBinOp(Opc, LHS, RHS, FMF, SQ);
  }

  Value *FoldUnOpFMF(Instruction::UnaryOps Opc, Value *V,
                      FastMathFlags FMF) const override {
    return simplifyUnOp(Opc, V, FMF, SQ);
  }

  Value *FoldICmp(CmpInst::Predicate P, Value *LHS, Value *RHS) const override {
    return simplifyICmpInst(P, LHS, RHS, SQ);
  }

  Value *FoldGEP(Type *Ty, Value *Ptr, ArrayRef<Value *> IdxList,
                 bool IsInBounds = false) const override {
    return simplifyGEPInst(Ty, Ptr, IdxList, IsInBounds, SQ);
  }

  Value *FoldSelect(Value *C, Value *True, Value *False) const override {
    return simplifySelectInst(C, True, False, SQ);
  }

  Value *FoldExtractValue(Value *Agg,
                          ArrayRef<unsigned> IdxList) const override {
    return simplifyExtractValueInst(Agg, IdxList, SQ);
  };

  Value *FoldInsertValue(Value *Agg, Value *Val,
                         ArrayRef<unsigned> IdxList) const override {
    return simplifyInsertValueInst(Agg, Val, IdxList, SQ);
  }

  Value *FoldExtractElement(Value *Vec, Value *Idx) const override {
    return simplifyExtractElementInst(Vec, Idx, SQ);
  }

  Value *FoldInsertElement(Value *Vec, Value *NewElt,
                           Value *Idx) const override {
    return simplifyInsertElementInst(Vec, NewElt, Idx, SQ);
  }

  Value *FoldShuffleVector(Value *V1, Value *V2,
                           ArrayRef<int> Mask) const override {
    Type *RetTy = VectorType::get(
        cast<VectorType>(V1->getType())->getElementType(), Mask.size(),
        isa<ScalableVectorType>(V1->getType()));
    return simplifyShuffleVectorInst(V1, V2, Mask, RetTy, SQ);
  }

  //===--------------------------------------------------------------------===//
  // Cast/Conversion Operators
  //===--------------------------------------------------------------------===//

  Value *CreateCast(Instruction::CastOps Op, Constant *C,
                    Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreateCast(Op, C, DestTy);
  }
  Value *CreateIntCast(Constant *C, Type *DestTy,
                       bool isSigned) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreateIntCast(C, DestTy, isSigned);
  }
  Value *CreatePointerCast(Constant *C, Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreatePointerCast(C, DestTy);
  }
  Value *CreateFPCast(Constant *C, Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreateFPCast(C, DestTy);
  }
  Value *CreateBitCast(Constant *C, Type *DestTy) const override {
    return ConstFolder.CreateBitCast(C, DestTy);
  }
  Value *CreateIntToPtr(Constant *C, Type *DestTy) const override {
    return ConstFolder.CreateIntToPtr(C, DestTy);
  }
  Value *CreatePtrToInt(Constant *C, Type *DestTy) const override {
    return ConstFolder.CreatePtrToInt(C, DestTy);
  }
  Value *CreateZExtOrBitCast(Constant *C, Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreateZExtOrBitCast(C, DestTy);
  }
  Value *CreateSExtOrBitCast(Constant *C, Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreateSExtOrBitCast(C, DestTy);
  }
  Value *CreateTruncOrBitCast(Constant *C, Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreateTruncOrBitCast(C, DestTy);
  }

  Value *CreatePointerBitCastOrAddrSpaceCast(Constant *C,
                                             Type *DestTy) const override {
    if (C->getType() == DestTy)
      return C; // avoid calling Fold
    return ConstFolder.CreatePointerBitCastOrAddrSpaceCast(C, DestTy);
  }

  //===--------------------------------------------------------------------===//
  // Compare Instructions
  //===--------------------------------------------------------------------===//

  Value *CreateFCmp(CmpInst::Predicate P, Constant *LHS,
                    Constant *RHS) const override {
    return ConstFolder.CreateFCmp(P, LHS, RHS);
  }
};

} // end namespace llvm

#endif // LLVM_ANALYSIS_INSTSIMPLIFYFOLDER_H
