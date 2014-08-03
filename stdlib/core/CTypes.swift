//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2015 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//
// C Primitive Types
//===----------------------------------------------------------------------===//

/// The C 'char' type.
///
/// This will be the same as either `CSignedChar` (in the common
/// case) or `CUnsignedChar`, depending on the platform.
public typealias CChar = Int8

/// The C 'unsigned char' type.
public typealias CUnsignedChar = UInt8

/// The C 'unsigned short' type.
public typealias CUnsignedShort = UInt16

/// The C 'unsigned int' type.
public typealias CUnsignedInt = UInt32

/// The C 'unsigned long' type.
public typealias CUnsignedLong = UInt

/// The C 'unsigned long long' type.
public typealias CUnsignedLongLong = UInt64

/// The C 'signed char' type.
public typealias CSignedChar = Int8

/// The C 'short' type.
public typealias CShort = Int16

/// The C 'int' type.
public typealias CInt = Int32

/// The C 'long' type.
public typealias CLong = Int

/// The C 'long long' type.
public typealias CLongLong = Int64

/// The C 'float' type.
public typealias CFloat = Float

/// The C 'double' type.
public typealias CDouble = Double

/// FIXME: long double

// FIXME: Is it actually UTF-32 on Darwin?
//
/// The C++ 'wchar_t' type.
public typealias CWideChar = UnicodeScalar

// FIXME: Swift should probably have a UTF-16 type other than UInt16.
//
/// The C++11 'char16_t' type, which has UTF-16 encoding.
public typealias CChar16 = UInt16

/// The C++11 'char32_t' type, which has UTF-32 encoding.
public typealias CChar32 = UnicodeScalar

/// The C '_Bool' and C++ 'bool' type.
public typealias CBool = Bool

/// A wrapper around an opaque C pointer.
///
/// Opaque pointers are used to represent C pointers to types that
/// cannot be represented in Swift, such as incomplete struct types.
public struct COpaquePointer : Equatable, Hashable, NilLiteralConvertible {
  var value: Builtin.RawPointer

  @transparent
  public init() {
    value = Builtin.inttoptr_Word(0.value)
  }

  @transparent
  init(_ v: Builtin.RawPointer) {
    value = v
  }

  /// Construct a `COpaquePointer` from a given address in memory.
  ///
  /// This is a fundamentally unsafe conversion.
  @transparent
  public init(bitPattern: Word) {
    value = Builtin.inttoptr_Word(bitPattern.value)
  }

  /// Construct a `COpaquePointer` from a given address in memory.
  ///
  /// This is a fundamentally unsafe conversion.
  @transparent
  public init(bitPattern: UWord) {
    value = Builtin.inttoptr_Word(bitPattern.value)
  }

  /// Convert a typed `UnsafePointer` to an opaque C pointer.
  @transparent
  public init<T>(_ value: UnsafePointer<T>) {
    self.value = value.value
  }

  /// Convert a typed `UnsafeMutablePointer` to an opaque C pointer.
  @transparent
  public init<T>(_ value: UnsafeMutablePointer<T>) {
    self.value = value.value
  }

  @transparent
  public static func null() -> COpaquePointer {
    return COpaquePointer()
  }

  /// Determine whether the given pointer is null.
  @transparent
  var _isNull : Bool {
    return self == COpaquePointer.null()
  }
  
  public var hashValue: Int {
    return Int(Builtin.ptrtoint_Word(value))
  }
  
  @transparent public
  static func convertFromNilLiteral() -> COpaquePointer {
    return COpaquePointer()
  }
}

extension COpaquePointer : DebugPrintable {
  public var debugDescription: String {
    return _rawPointerToString(value)
  }
}

public func ==(lhs: COpaquePointer, rhs: COpaquePointer) -> Bool {
  return Bool(Builtin.cmp_eq_RawPointer(lhs.value, rhs.value))
}

public struct CFunctionPointer<T> : Equatable, Hashable, NilLiteralConvertible {
  var value: COpaquePointer

  public init() {
    value = COpaquePointer()
  }

  public init(_ value: COpaquePointer) {
    self.value = value
  }

  public static func null() -> CFunctionPointer {
    return CFunctionPointer()
  }

  public var hashValue: Int {
    return value.hashValue
  }

  @transparent public
  static func convertFromNilLiteral() -> CFunctionPointer {
    return CFunctionPointer()
  }
}

extension CFunctionPointer : DebugPrintable {
  public var debugDescription: String {
    return value.debugDescription
  }
}

public func ==<T>(lhs: CFunctionPointer<T>, rhs: CFunctionPointer<T>) -> Bool {
  return lhs.value == rhs.value
}

extension COpaquePointer {
  public init<T>(_ from: CFunctionPointer<T>) {
    self = from.value
  }
}


// The C va_list type
public struct CVaListPointer {
  var value: UnsafeMutablePointer<Void>

  init(fromUnsafeMutablePointer from: UnsafeMutablePointer<Void>) {
    value = from
  }
}

extension CVaListPointer : DebugPrintable {
  public var debugDescription: String {
    return value.debugDescription
  }
}

/// Access to the raw argc value from C.
public var C_ARGC : CInt = CInt()

/// Access to the raw argv value from C. Accessing the argument vector
/// through this pointer is unsafe.
public var C_ARGV: UnsafeMutablePointer<UnsafeMutablePointer<Int8>> = nil

func _memcpy(
  #dest: UnsafeMutablePointer<Void>,
  #src: UnsafeMutablePointer<Void>,
  #size: UInt
) {
  let dest = dest.value
  let src = src.value
  let size = UInt64(size).value
  Builtin.int_memcpy_RawPointer_RawPointer_Int64(dest, src, size,
                                                 /*alignment*/Int32().value,
                                                 /*volatile*/false.value)
}
