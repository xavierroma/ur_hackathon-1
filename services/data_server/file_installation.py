import document as doc
import send_to_cmd as cmd

INICI_DADES_PARET = "[SafetyLimits BoundaryPlane"
ID_PARET = "sourceFeatureId"
#TODO: s'ha de canviar el nom del fitxer perque utilitzaven un altre (la ruta la sap el send_to_cmd)
name_file = "schmalz.installation"

class Plane:
    def __init__(self):
        self.name = "plane"
        self.id = "-"
        self.offset = 0.0
        self.normal_x = 0.0
        self.normal_y = 0.0
        self.normal_z = 0.0
        self.mode = "DISABLED"
    def __repr__(self):
         return "[{0},{1},{2},{3}]".format(self.normal_x, self.normal_y, self.normal_z, self.offset)


def buscar_parets():
    plane_list = []
    
    name_f = cmd.descomprimir_fitxer(name_file)

    f = doc.doc(name_f, "r")
    line = f.get_line()
    while (line):
        if(line.find(INICI_DADES_PARET) != -1):
            plane = Plane()
            #en aquesta linia hi ha el nom de la paret
            line = f.get_line()
            #ens guardem el nom de la paret
            plane.name = line[7:]
            #en aquesta linia pot haver-hi o l'id si la paret ha estat configurada o l'offset, que sera 0 perque no hi ha paret
            line = f.get_line()
            #mirem si es l'id de la paret
            if(line.find(ID_PARET) != -1):
                #ens guardem l'id de la paret
                plane.id = line[18:]
                #en aquesta linia tinc l'offset
                line = f.get_line()
                #guardem l'offset
                plane.offset = float(line[15:])
                #en aquesta linia tinc el mode
                line = f.get_line()
                #guardem el mode
                plane.mode = line[7:]
                #en aquesta linia tinc el vector normal
                line = f.get_line()
                #guardem el normal x
                max_x = line.find(",")
                plane.normal_x = float(line[15 : max_x-1])
                #guardem el normal y
                max_y = line.rfind(",")
                plane.normal_y = float(line[max_x+2 : max_y-1])
                #guardem el normal z
                max_z = line.rfind("]")
                plane.normal_z = float(line[max_y+2 : max_z-1])
                #augmentem la posicio de l'index de plans a fi de poder trobar un de nou i guardar-lo
                plane_list.append(plane)
            
        line = f.get_line()
    f.close_doc()
    #posem totes les parets en un string
    i = 0
    string = "["
    while i < len(plane_list):
        string = string + plane_list[i].__repr__() + ","
        i = i+1
        
    string = string[:len(string)-1] + "]"
    return string