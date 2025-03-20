package ezen;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBManager 
{
	private Connection conn;
	private Statement  stmt;
	private ResultSet  rs;
	
	private String     host;   //DB연결정보
	private String     userid; //DB 사용자 ID
	private String     userpw; //DB 사용자 암호 
	
	public DBManager()
	{
		conn   = null;
		userid = "root";
		userpw = "1234";
		host   = "jdbc:mysql://192.168.0.92:3306/MyStock";
		host  += "?useUnicode=true&characterEncoding=utf-8";
		host  += "&serverTimezone=UTC";		
	}
	
	public void setHost(String host) 
	{
		this.host = host;
	}

	public void setUserid(String userid) 
	{
		this.userid = userid;
	}

	public void setUserpw(String userpw) 
	{
		this.userpw = userpw;
	}

	//DB에 연결한다.
	//리턴값 : true-연결성공, false-연결실패
	public boolean DBOpen()
	{
		//jdbc 라이브러리 로딩
		try
		{
			Class.forName("com.mysql.cj.jdbc.Driver");
		}catch(Exception e)
		{
			e.printStackTrace();
			return false;
		}		
		//데이터베이스에 연결한다.	
		try 
		{
			conn =  DriverManager.getConnection(host,userid,userpw);
		} catch (SQLException e) 
		{
			e.printStackTrace();
			return false;
		}		
		return true;
	}
		
	//DB 연결을 종료한다.
	public void DBClose()
	{
		try 
		{
			conn.close();
		} catch (SQLException e) 
		{
			e.printStackTrace();
		}		
	}
	
	//CUD(Insert,Delete,Update) 구문을 실행
	public boolean RunCommand(String sql)
	{
		try
		{
			stmt = conn.createStatement();
			System.out.println(sql);
			stmt.executeUpdate(sql);
		}catch (SQLException e) 
		{
			e.printStackTrace();
			return false;
		}		
		return true;
	}
	
	//R(Select) 구문을 실행한다. 
	public boolean RunSelect(String sql)
	{
		try
		{
			stmt = conn.createStatement();
			System.out.println(sql);
			rs = stmt.executeQuery(sql);
		}catch(Exception e)
		{
			e.printStackTrace();
			return false;
		}
		return true;
	}	
	
	//ResultSet의 next() 호출
	public boolean GetNext()
	{
		try 
		{		
			return rs.next();
		} catch (SQLException e) 
		{
			e.printStackTrace();
			return false;
		}		
	}	
	
	//ResultSet의 getString() 호출
	public String GetValue(String colname)
	{
		try 
		{		
			return rs.getString(colname);
		} catch (SQLException e) 
		{
			e.printStackTrace();
			return null;
		}				
	}	
}
