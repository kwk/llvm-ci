# Welcome

to an interesting approach to testing LLVM.

As you may or may not know, LLVM has different kind of test systems.
For example, for post-merge tests, we're using [buildbot](https://llvm.org/docs/HowToAddABuilder.html)
and for pre-merge tests we're using a hosted service called
[buildkite](https://buildkite.com/llvm-project/premerge-checks).

Note that none of the above test systems provides any resources on which to
run the LLVM tests.

For buildkite as of the time of writing this (Sept. 2020), there are 4 dedicated
Debian Linux machines and 6 Windows machines that build LLVM. Those machines are
operated in Google's data center.

For buildbot, you can contribute your own builder by following
[this guide](https://llvm.org/docs/HowToAddABuilder.html).

We have two so called buildmasters running:

 * The main buildmaster at http://lab.llvm.org:8011. All builders attached to
   this machine will notify commit authors every time they break the build.

 * The staging buildbot at http://lab.llvm.org:8014. All builders attached to
   this machine will be completely silent by default when the build is broken.
   Builders for experimental backends should generally be attached to this
   buildmaster.

When you only look at the number of [builders attached to the master buildbot](http://lab.llvm.org:8011/builders)
you'll notice that there are builds for all kinds of combination of

 * projects (e.g. clang, lldb),
 * compilers (e.g. clang, gcc, msvc),
 * linkers (e.g. ldd, ld, gold),
 * options (e.g. LTO),
 * architectures (e.g. x86_64, ppc64l, aarch, etc.),
 * operating systems (e.g. Linux, Windows, Mac)

and so forth.

In fact, the number of [configuration options](https://llvm.org/docs/CMake.html#llvm-specific-variables)
LLVM is quite large.





