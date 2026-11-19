# Reviewing unsafe code, FFI and untrusted input in Rust

Read this before reviewing `unsafe` code, an FFI boundary, or a crate that parses input it does not
control. Safe Rust prevents memory errors only if every `unsafe` block upholds its contract. One wrong
block breaks the guarantee for the whole program.

## Contents
1. Plan the review
2. Unsafe blocks
3. FFI
4. Panics and resource exhaustion
5. Async hazards
6. Reporting

## 1. Plan the review

1. List the attack surface: every entry point that takes outside data (network, files, CLI, IPC, FFI
   callbacks).
2. List every `unsafe` block, `unsafe fn`, `unsafe impl` (`Send`, `Sync`) and `extern` block
   (`grep -rn "unsafe" src/`).
3. List the dependencies that contain unsafe code or native code (`cargo geiger` if available, or
   `build.rs` and `-sys` crates).
4. Review each unsafe site against section 2, each entry point against section 4.
5. For a large crate, split the work by module, then merge and remove duplicate findings before judging
   severity.

## 2. Unsafe blocks

For each block, write down the invariants it relies on, then check each one:

- **Pointer validity:** non-null, aligned, points to initialised memory of the right type, and the memory
  lives for as long as the reference made from it.
- **Aliasing:** no `&mut` exists at the same time as any other reference to the same memory. Creating two
  `&mut` from one raw pointer is undefined behaviour even if neither is used badly.
- **Initialisation:** `MaybeUninit` is fully written before `assume_init`. `Vec::set_len` only after every
  element up to the new length is initialised.
- **Lengths and bounds:** every length that reaches `from_raw_parts`, `get_unchecked` or pointer
  arithmetic is checked first, and arithmetic on it cannot overflow.
- **`unsafe impl Send` / `Sync`:** the type really is safe to move or share across threads. A raw pointer
  or `Cell` inside is the usual reason it is not.
- **Panic safety:** if code inside the block can panic halfway (a user callback, an allocation), the data
  structure is still valid when the panic unwinds. Partly moved or doubly dropped values are the classic
  failure.
- **Soundness of the safe wrapper:** can any sequence of safe calls on the public API break the invariant?
  If yes, the API is unsound even if no current caller does it.

Run Miri on tests that exercise each block. Miri finds much undefined behaviour at runtime but only on
the paths the tests reach.

## 3. FFI

- Every pointer crossing the boundary: who allocates, who frees, with which allocator. Memory allocated
  by C freed by Rust (or the reverse) is undefined behaviour.
- Strings: `CStr` / `CString` and explicit encoding. A Rust `&str` is not NUL-terminated.
- Panics must not unwind across an `extern "C"` boundary. Catch them (`std::panic::catch_unwind`) at the
  boundary, or use an `extern "C-unwind"` ABI deliberately.
- Callbacks from C into Rust: the context pointer is valid for every call, and the callback cannot run
  after the Rust side is dropped.
- Thread rules of the C library (is it thread-safe? does it need calls from one thread?) are reflected in
  whether the wrapper type is `Send` and `Sync`.
- Struct layout: `#[repr(C)]` on every type shared with C.

## 4. Panics and resource exhaustion

From each entry point, follow untrusted data and flag:
- Indexing, slicing (including `str` at non-character boundaries), `unwrap`, `expect`, division,
  unchecked arithmetic.
- Allocation sized by input: `Vec::with_capacity(n)` where `n` comes from a header. Cap it.
- Recursion on nested input without a depth limit.
- Unbounded collections or channels fed by outside data.
- Regexes compiled from user input (the `regex` crate is linear time, but compile cost and memory are not
  free).

## 5. Async hazards

- Blocking calls on executor threads (rule 4 in `SKILL.md`).
- Lock guards held across `.await`.
- Non-cancel-safe futures inside `select!`.
- Tasks spawned without a handle, whose panics are never observed.
- Missing timeouts on network I/O, which let a slow client hold resources for ever.

## 6. Reporting

For each finding: file and line, the invariant or rule broken, how it is reached from outside input (or
"not reachable", which lowers severity), the impact (undefined behaviour, crash, resource exhaustion,
logic error), and the fix. Mark a finding as confirmed only with a reproducing test or a Miri report.
Otherwise mark it as suspected and say what evidence would settle it.
