macro
: \  refill drop ;
: (  41 word drop drop ;

forth
: dup   dup ;
: drop  drop ;
: swap  swap ;
: over  over ;
: nip   nip ;

: a     a ;
: a!    a! ;
: @     @ ;
: @+    @+ ;
: b@    b@ ;
: b@+   b@+ ;
: !     ! ;
: !+    !+ ;
: b!    b! ;
: b!+   b!+ ;

: +     + ;
: -     - ;
: /mod  /mod ;
: /     /mod nip ;
: mod   /mod drop ;

: cr  10 emit ;
: bl  32 ;

: char  bl word drop b@ ;

: reljmp,  ( dst src -> )  5 + -  233 b, 4, ;

macro
: then  ( a -> )  here  over 1 + -  swap b! ;

: [compile]  ( "name" -> )
  bl word mlatest dfind dup if >cfa @ call, exit then drop ;

: begin  ( -> 'begin )  here ;
: while  ( 'begin -> 'if 'begin )  [compile] if swap ;
: again  ( 'begin -> )  here reljmp, ;
: repeat  ( 'if 'begin -> )  [compile] again [compile] then ;

: [char]  bl word drop b@ [compile] lit ;

forth

( Dictionary )
: +!  ( n a -> )  swap over  @ +  swap ! ;


: variable  create 0 , ;

: allot  ( n -> )  here +  h ! ;


( Strings )
: /string  ( a u n -> a+n u-n )  swap over  - push + pop ;

: move  ( src dst u -> )
  push push a! pop pop
  begin dup while
    over b@+ swap b!
    1 /string
  repeat
  drop drop ;

: ,"  ( -> u )  [char] " word  dup push  here swap move  pop ;
: z"  ( -> u )  ,"  0 over here + b!  1 + ;
: s>z  ( a u -> )  dup push  here swap move  0 here pop + b! ;

: ."  [char] " word type ;

( File )
: open-file  ( a u mode -> fd )  push s>z here pop sysopen ;
: read-file  ( a u fd -> u )  sysread ;
: close-file  ( fd -> u )  sysclose ;


create   /buf  256 ,
create   buf  /buf @ allot
variable fd

: input@  ( -> fd buf tot used pos )
  infd @ inbuf @ intot @ inused @ inpos @ ;

: input!  ( fd buf tot used pos -> )
  inpos ! inused ! intot ! inbuf ! infd ! ;

: included  ( a u -> )
  push push input@ pop pop
  0 open-file dup 0 < if abort then
  dup buf /buf @ 0 0 input!  readloop
  close-file drop  input! ;

: include  ( "name" -> )  bl word included ;

bye