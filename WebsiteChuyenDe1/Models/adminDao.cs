using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebsiteChuyenDe1.Models
{
    public class adminDao
    {
        dbnewEntities1 db = null;
        public adminDao()
        {
            db = new dbnewEntities1();
        }
        public long Insert(AdminAccount entity)
        {
            db.AdminAccounts.Add(entity);
            db.SaveChanges();
            return 2;
        }
        public AdminAccount GetById(string taikhoan)
        {
            return db.AdminAccounts.SingleOrDefault(x => x.TaiKhoan == taikhoan);
        }
        public bool Login(string UserName, string PassWord)
        {

            var res = db.AdminAccounts.Count(x => x.TaiKhoan == UserName && x.MatKhau == PassWord);

            if (res > 0)
            {

                return true;
            }
            else
            {
                return false;
            }
        }

    }
}