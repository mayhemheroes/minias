#!/bin/sh
set -eu

tmps="$(mktemp --suffix .s)"
tmpo="$(mktemp --suffix .o)"
tmpb="$(mktemp --suffix .bin)"

trap "rm -f \"$tmps\" \"$tmpo\" \"$tmpb\"" EXIT

t () {
	echo "$1" > "$tmps"
	clang -Wno-everything -c -s "$tmps" -o "$tmpo" 
	objcopy -j ".text" -O binary "$tmpo" "$tmpb"
	want="$(xxd -ps "$tmpb" | head -n 1 | cut  -d ' ' -f 2-)"
	./minias < "$tmps" > "$tmpo" 
	objcopy -j ".text" -O binary "$tmpo" "$tmpb"
	got="$(xxd -ps "$tmpb" | head -n 1 | cut  -d ' ' -f 2-)"
	if test "$got" != "$want"
	then
	  echo ""
	  echo "want: $1 -> $want"
	  echo "got:  $1 -> $got"
	  exit 1
	fi
	echo -n "."
}

# TODO Tidy and be more systematic, we could just loop

t "xchg %rax, %rax"
t "xchg %eax, %eax"
t "xchg %ax, %ax"
t "xchg %al, %al"
t "xchg %rax, (%rax)"
t "xchg %eax, (%rax)"
t "xchg %ax, (%rax)"
t "xchg %al, (%rax)"
t "xchg (%rax), %rax"
t "xchg (%rax), %eax"
t "xchg (%rax), %ax"
t "xchg (%rax), %al"

exit 0

t "addb %al, %al"
t "addb (%rax), %al"
t "addb %al, (%rax)"

t "subb %al, %al"
t "subb (%rax), %al"
t "subb %al, (%rax)"

t "xorb %al, %al"
t "xorb (%rax), %al"
t "xorb %al, (%rax)"

t "orb %al, %al"
t "orb (%rax), %al"
t "orb %al, (%rax)"

t "andb %al, %al"
t "andb (%rax), %al"
t "andb %al, (%rax)"

t "movb %al, %al"
t "movb (%rax), %al"
t "movb %al, (%rax)"

t "movw %ax, %r9w"
t "movw %ax, %ax"
t "addw %ax, %ax"
t "movq %rax, %rax"
t "movq (%rax), %rax"
t "movq %rax, (%rax)"
t "movl %eax, %eax"
t "movl (%rax), %eax"
t "movl %eax, (%rax)"
t "leaw (%rax), %ax"
t "leaq (%rax), %rax"
t "leal (%rax), %eax"
t "addq (%rax), %rax"
t "andq (%rax), %rax"
t "orq  (%rax), %rax"
t "subq (%rax), %rax"
t "xorq (%rax), %rax"
t "nop"
t "ret"
t "leave"
t "addq %rax, %rax"
t "addl %eax, %eax"
t "subq %rax, %rax"
t "subl %eax, %eax"
t "addq %rax, %rbx"
t "addl %eax, %ebx"
t "addq %rax, (%rax)"
t "addq %rax, (%rbx)"
t "addl %eax, (%rax)"
t "addl %eax, (%r9)"
t "addl %ebx, (%r9)"
t "orq %rax, %rax"
t "orq %rax, (%rax)"
t "orl %eax, %eax"
t "xorq %rax, %rax"
t "xorq %rax, (%rax)"
t "xorl %eax, %eax"
t "andq %rax, %rax"
t "andq %rax, (%rax)"
t "andl %eax, %eax"