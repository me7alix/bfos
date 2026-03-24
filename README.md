# BFOS
BFOS is a brainfuck interpter written in nasm that fits into 512 bytes of bootloader and works without OS.

## Usage
After writing the program you need to press ENTER to run it. When the program finished you can press ENTER to go back to "the editor".

## Examples
To compile BFOS and run the examples you need this programs:
 - nasm
 - qemu
 - netcat

```
make test FILE=./examples/sierpinski.bf
make test FILE=./examples/golden.bf
```

## License
This project is released under the MIT License.
