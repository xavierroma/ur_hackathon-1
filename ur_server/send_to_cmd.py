#!/usr/bin/python
# This Python file uses the following encoding: utf-8

import subprocess

#TODO: posar la ruta on es troben tots els fitxers .installation (vigilar amb les barres, no posar contrabarres)
RUTA_INSTALLATION = "/programs"

#envia comandes a cmd per a que les executi
def send_command(command, path):
    subprocess.call(command, shell=True, cwd = path)

#s'encarrega de descomprimir el fitxer que se li diu en el parametre nom_fitxer. el nom_fitxer ha de ser del tipus .installation (NECESSITA TENIR INSTALLAT: sudo apt-get install p7zip-full p7zip-rar)
#No deixa installar-ho al robot
def old_descomprimir_fitxer(nom_fitxer):
    #busquem on esta el punt
    lloc_punt = nom_fitxer.find(".")
    #el nom nou que tindra el fitxer sera el mateix pero sense el .installation
    nom_nou = nom_fitxer[:lloc_punt]
    #copiem el fitxer que ens donen i el convertim en un rar
    send_command("cp "+nom_fitxer+ " "+ nom_nou+".rar", RUTA_INSTALLATION)
    #es descomprimeix
    send_command("7z x "+ nom_nou+".rar", RUTA_INSTALLATION)
    #retorna el nom del nou fitxer descomprimit
    return nom_nou    

#s'encarrega de descomprimir el fitxer que se li diu en el parametre nom_fitxer. el nom_fitxer ha de ser del tipus .installation
def descomprimir_fitxer(nom_fitxer):
    #busquem on esta el punt
    lloc_punt = nom_fitxer.find(".")
    #el nom nou que tindra el fitxer sera el mateix pero sense el .installation
    nom_nou = nom_fitxer[:lloc_punt] + ".txt"
    #es descomprimeix
    send_command("zcat "+ nom_fitxer+" > " + nom_nou, RUTA_INSTALLATION)
    #retorna el nom del nou fitxer descomprimit
    return nom_nou

#s'encarrega de comprimir el fitxer que se li diu en el parametre nom_fitxer. Creara un fitxer .installation
def comprimir_fitxer(nom_fitxer):
    #busquem on esta el punt
    lloc_punt = nom_fitxer.find(".")
    #el nom nou que tindra el fitxer sera el mateix pero amb el .installation
    nom_nou = nom_fitxer[:lloc_punt] + ".installation"
    #es comprimeix
    send_command("gzip "+ nom_fitxer, RUTA_INSTALLATION)
    #Li treiem el .gz del final
    send_command("mv "+ nom_fitxer + ".gz " + nom_nou, RUTA_INSTALLATION)
    #retorna el nom del nou fitxer comprimit
    return nom_nou        