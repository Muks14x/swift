//===--- IndexSymbol.h - Index symbol data types ----------------*- C++ -*-===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

#ifndef SWIFT_INDEX_INDEXSYMBOL_H
#define SWIFT_INDEX_INDEXSYMBOL_H

#include "swift/Basic/LLVM.h"
#include "clang/Index/IndexSymbol.h"
#include "llvm/ADT/SmallString.h"

namespace swift {
class Decl;
class ValueDecl;

namespace index {

enum class SymbolKind {
  Unknown,

  Module,
  ClangModule, // FIXME: collapse into Module and use a separate Language field.

  Enum,
  Struct,
  Class,
  Protocol,
  Extension,

  TypeAlias,
  AssociatedType,
  GenericTypeParam,

  Function,
  Variable,
  PrefixOperator,
  PostfixOperator,
  InfixOperator,
  Accessor,
  Subscript,
  EnumElement,

  InstanceMethod,
  ClassMethod,
  StaticMethod,
  InstanceProperty,
  ClassProperty,
  StaticProperty,

  Constructor,
  Destructor,
};

enum class SymbolSubKind : uint32_t {
  None                          = 0,

  AccessorGetter                = 1 << 0,
  AccessorSetter                = 1 << 1,
  AccessorWillSet               = 1 << 2,
  AccessorDidSet                = 1 << 3,
  AccessorAddressor             = 1 << 4,
  AccessorMutableAddressor      = 1 << 5,

  ExtensionOfStruct             = 1 << 6,
  ExtensionOfClass              = 1 << 7,
  ExtensionOfEnum               = 1 << 8,
  ExtensionOfProtocol           = 1 << 9,

  UnitTest                      = 1 << 10,
};

typedef uint32_t SymbolSubKindSet;

inline SymbolSubKindSet operator&(SymbolSubKindSet SKSet, SymbolSubKind SK) {
  return SKSet & (SymbolSubKindSet)SK;
}
inline SymbolSubKindSet operator|(SymbolSubKindSet SKSet, SymbolSubKind SK) {
  return SKSet | (SymbolSubKindSet)SK;
}
inline SymbolSubKindSet &operator|=(SymbolSubKindSet &SKSet, SymbolSubKind SK) {
  return SKSet = SKSet | SK;
}

using SymbolRole = clang::index::SymbolRole;
using SymbolRoleSet = clang::index::SymbolRoleSet;

struct IndexRelation {
  const ValueDecl *decl;
  SymbolKind kind;
  SymbolSubKindSet subKinds = SymbolSubKindSet(0);
  SymbolRoleSet roles = SymbolRoleSet(0);

  // The following strings are guaranteed to live at least as long as the
  // current indexing action.
  StringRef name;
  StringRef USR; // USR may be safely compared by pointer.
  StringRef group;

  IndexRelation(SymbolRoleSet Roles, const ValueDecl *Sym, SymbolKind Kind, SymbolSubKindSet SubKinds, StringRef Name, StringRef USR)
  : decl(Sym), kind(Kind), subKinds(SubKinds), roles(Roles), name(Name), USR(USR) {}

  IndexRelation() = default;
};

struct IndexSymbol : IndexRelation {
  SmallVector<IndexRelation, 3> Relations;
  unsigned line = 0;
  unsigned column = 0;

  IndexSymbol() = default;

  StringRef getReceiverUSR() const {
    for(auto Relation: Relations) {
      if (Relation.roles & (SymbolRoleSet) SymbolRole::RelationReceivedBy)
        return Relation.USR;
    }
    return StringRef();
  }
};

SymbolKind getSymbolKindForDecl(const Decl *D);

StringRef getSymbolKindString(SymbolKind K);

void applyForEachSymbolSubKind(SymbolSubKindSet SubKinds,
                               llvm::function_ref<void(SymbolSubKind)> Fn);
void printSymbolSubKinds(SymbolSubKindSet SubKinds, raw_ostream &OS);

} // end namespace index
} // end namespace swift

#endif // SWIFT_INDEX_INDEXSYMBOL_H
