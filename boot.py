#!/usr/bin/env python

import os
import re
import subprocess
import argparse

# Configurações
NASM_CMD = "nasm"  # Comando para chamar o NASM
QEMU_CMD = "qemu-system-x86_64"  # Comando para chamar o QEMU

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

def create_disk_image(boot_bin, sector2_bin, output_img):
    """
    Cria uma imagem de disco combinando o setor de boot e o segundo setor.
    """
    try:
        with open(output_img, 'wb') as outfile:
            # Copia o setor de boot
            with open(boot_bin, 'rb') as bootfile:
                outfile.write(bootfile.read())
            # Copia o segundo setor
            with open(sector2_bin, 'rb') as sector2file:
                outfile.write(sector2file.read())
        print(f"Imagem de disco {output_img} criada com sucesso.")
    except IOError as e:
        print(f"Erro ao criar imagem de disco: {e}")
        exit(1)

def run_qemu(img_file):
    """
    Executa o QEMU com a imagem de disco gerada.
    """
    try:
        subprocess.run([QEMU_CMD, "-fda", img_file], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Erro ao executar o QEMU: {e}")
        exit(1)

def main():
    parser = argparse.ArgumentParser(description="Compila e executa um sistema operacional simples.")
    parser.add_argument("boot_file", help="Arquivo principal de boot (ex: boot.asm)")
    parser.add_argument("--sector2", help="Arquivo do segundo setor", default="sector2.asm")
    args = parser.parse_args()

    # Nomes dos arquivos de saída
    boot_bin = "boot.bin"
    sector2_bin = "sector2.bin"
    output_img = "hwOS.img"

    # Compilar bootloader
    compile_asm_file(args.boot_file, boot_bin)

    # Compilar segundo setor
    if os.path.exists(args.sector2):
        compile_asm_file(args.sector2, sector2_bin)
    else:
        print(f"Aviso: Arquivo do segundo setor {args.sector2} não encontrado.")
        sector2_bin = None

    # Criar imagem de disco
    if sector2_bin and os.path.exists(sector2_bin):
        create_disk_image(boot_bin, sector2_bin, output_img)
        run_file = output_img
    else:
        run_file = boot_bin

    # Executar no QEMU
    print(f"Iniciando QEMU com o arquivo {run_file}...")
    run_qemu(run_file)

if __name__ == "__main__":
    main()