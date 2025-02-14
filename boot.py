#!/usr/bin/env python

import os
import re
import subprocess
import argparse

# Configurações
NASM_CMD = "nasm"  # Comando para chamar o NASM
QEMU_CMD = "qemu-system-i386"  # Alterado de qemu-system-x86_64 para i386
GCC_CMD = "gcc"
OBJCOPY_CMD = "objcopy"

def find_included_files(asm_file):
    """
    Encontra todos os arquivos incluídos no arquivo .asm usando a diretiva %include.
    """
    included_files = []
    with open(asm_file, "r") as file:
        for line in file:
            match = re.match(r'^\s*%include\s+"([^"]+)"', line)
            if match:
                included_files.append(match.group(1))
    return included_files

def compile_asm_file(asm_file, output_bin):
    """
    Compila um arquivo .asm usando o NASM.
    """
    try:
        subprocess.run([NASM_CMD, "-f", "bin", "-o", output_bin, asm_file], check=True)
        print(f"Arquivo {asm_file} compilado com sucesso para {output_bin}.")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao compilar {asm_file}: {e}")
        exit(1)

def compile_c_program(c_file, output_bin):
    """
    Compila um programa C para código binário puro.
    """
    try:
        # Compilar para objeto
        obj_file = c_file.replace('.c', '.o')
        subprocess.run([
            GCC_CMD,
            "-m16",            # Mudado para -m16
            "-c",
            "-O2",
            "-fno-pie",
            "-fno-asynchronous-unwind-tables",
            "-fno-jump-tables",
            "-nostdlib",
            "-nostdinc",
            "-fno-stack-protector",
            "-fomit-frame-pointer",
            "-mpreferred-stack-boundary=2",
            "-march=i386",
            "-fno-pic",           # Changed from -fpic to -fno-pic
            "-o", obj_file,
            c_file
        ], check=True)
        
        # Compilar command_hw.asm para objeto
        hw_obj = "command_hw.o"
        subprocess.run([
            NASM_CMD,
            "-f", "elf32",    # Changed from bin to elf32
            "-o", hw_obj,
            "command_hw.asm"
        ], check=True)
        
        # Linkar os objetos
        subprocess.run([
            "ld",
            "-m", "elf_i386",
            "-T", "linker.ld",
            "--oformat=binary",
            "-nostdlib",
            "-static",         # Added static linking
            "-o", output_bin,
            obj_file,
            hw_obj
        ], check=True)

        # Limpar arquivos temporários
        os.remove(obj_file)
        os.remove(hw_obj)
        
        print(f"Arquivo {c_file} compilado com sucesso para {output_bin}.")
    except subprocess.CalledProcessError as e:
        print(f"Erro ao compilar {c_file}: {e}")
        exit(1)

def create_disk_image(boot_bin, sector2_bin, hello_bin, output_img):
    """
    Cria uma imagem de disco combinando todos os binários necessários.
    """
    try:
        with open(output_img, 'wb') as outfile:
            # Copia o setor de boot (512 bytes)
            with open(boot_bin, 'rb') as bootfile:
                outfile.write(bootfile.read())
            
            # Copia o segundo setor
            with open(sector2_bin, 'rb') as sector2file:
                outfile.write(sector2file.read())
            
            # Copia o programa hello
            with open(hello_bin, 'rb') as hellofile:
                hello_data = hellofile.read()
                # Pad para 512 bytes se necessário
                if len(hello_data) < 512:
                    hello_data += b'\x00' * (512 - len(hello_data))
                outfile.write(hello_data)
            
        print(f"Imagem de disco {output_img} criada com sucesso.")
    except IOError as e:
        print(f"Erro ao criar imagem de disco: {e}")
        exit(1)

def run_qemu(img_file):
    """
    Executa o QEMU com a imagem de disco gerada.
    """
    try:
        subprocess.run([
            QEMU_CMD,
            "-drive", f"format=raw,file={img_file}"
        ], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o QEMU: {e}")
        exit(1)

def main():
    parser = argparse.ArgumentParser(description="Compila e executa um sistema operacional simples.")
    parser.add_argument("boot_file", help="Arquivo principal de boot (ex: boot.asm)")
    args = parser.parse_args()

    # Nomes dos arquivos de saída
    boot_bin = "boot.bin"
    sector2_bin = "sector2.bin"
    hello_bin = "hello.bin"
    output_img = "hwOS.img"

    # Compilar programa C hello.c
    if os.path.exists("hello.c"):
        compile_c_program("hello.c", hello_bin)
    else:
        print("Erro: hello.c não encontrado!")
        exit(1)

    # Compilar bootloader
    compile_asm_file(args.boot_file, boot_bin)

    # Criar imagem do disco
    create_disk_image(boot_bin, sector2_bin, hello_bin, output_img)

    # Executar QEMU
    run_qemu(output_img)

if __name__ == "__main__":
    main()