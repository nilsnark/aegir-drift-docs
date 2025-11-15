# SLISP Specification

## 1. Syntax
- Lisp-like
- Fully parenthesized expressions
- Symbols, ints, floats, lists

## 2. Determinism
- No randomness without explicit seed
- No global time access
- No access to real-world clock

## 3. Capabilities
Functions only available if device grants them:
- navigation.*
- reactor.*
- sensors.*
- logistics.*

## 4. Execution Model
- Each tick: bounded number of evaluations
- Memory quota per program
- Recursion depth limits enforced

## 5. Safe Interop
Systems provide pure or capability-limited functions.

