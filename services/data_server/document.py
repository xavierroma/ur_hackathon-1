# -*- coding: utf-8 -*-
"""
Created on Mon Feb 04 19:12:45 2019

Document to create documents

@author: Selene


"""

class doc:

    def __init__(self, name_file, r_w_a):
        if (r_w_a == "r" or r_w_a == "w+" or r_w_a == "a"):
            self.file = open(name_file, r_w_a)
        else:
            print ("ERROR. Wrong format.")
        
    def close_doc(self):
        self.file.close()
        
        
    def get_position(self):
        return self.file.tell()
    
    #n_byte: number of bytes to move
    #from_where: 0 --> from the beggining, 1 --> from the actual position, 2 --> from the end
    def move_position(self, n_byte, from_where):
        if (from_where >= 0 & from_where <= 2):
            self.file.seek(n_byte, from_where)
        else:
            print("ERROR. The second parameter is incorrect")
        
    def get_line(self):
        return self.file.readline()
    
    def add_line(self, text):
        self.file.write(text)