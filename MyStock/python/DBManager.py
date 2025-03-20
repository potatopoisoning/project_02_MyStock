import pymysql

class DBManager :
    def DBOpen(self,host,dbname,id,pw) :
        try :
            self.con = pymysql.connect(
                host=host,
                port=3306, 
                user=id, 
                passwd=pw,
                db=dbname, charset ="euckr")
            if self.con != None :
                self.cursor = self.con.cursor()
                return True
            return False
        except :
            return False
    
    def DBClose(self) :
        self.con.close()
        
    
    def RunSQL(self,sql) :
        try :
            self.cursor.execute(sql)
            self.con.commit()
            return True
        except :
            return False
    
    def OpenQuery(self,sql):
        try :
            self.cursor.execute(sql)
            self.data = self.cursor.fetchall()
            self.num_fields = len(self.cursor.description)
            return True
        except :
            return False       
        
    def CloseQuery(self) :
        self.cursor.close()
        
    def GetTotal(self):
        return len(self.data)
    
    def GetValue(self,index,column):
        count = -1
        for name in self.cursor.description:
            count = count + 1
            #print(name[0])
            if name[0] == column :            
                return self.data[index][count]
        return ""

    
