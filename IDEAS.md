After main impl is finished:
- Add support for interacting with the DOM (and maybe have it act like Red/View)
- Make a JS ffi
- Make a variant of Red/System but for JS (kinda like the previous thing)
- Add a binary language mode like what Red has (Redbin)
- Add the DELECT native from Rebol
- Add the utype! type from Rebol (although it's not completely finished)
- Implement Rebol's module system (along with the `module!` type)

After main impl is finished if I'm still bored:
- JIT the Parse dialect using WebAssembly
- Allow compiling to/running on WebAssembly
- Make a C ffi for nodejs (and maybe use Rebol's `library!` type for it?)