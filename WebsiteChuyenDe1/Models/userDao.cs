using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebsiteChuyenDe1.Models
{
    public class userDao
    {
        dbnewEntities1 db = null;
        public userDao()
        {
            db = new dbnewEntities1();
        }
        public long Insert(Customer entity)
        {
            db.Customers.Add(entity);
            db.SaveChanges();
            return 2;
        }
        public Customer GetById(string name)
        {
            return db.Customers.SingleOrDefault(x => x.FullName == name || x.EmailAddress==name);
        }
        public bool Login(string UserName, string PassWord)
        {

            var res = db.Customers.Count(x => (x.FullName== UserName || x.EmailAddress == UserName )&& x.Password == PassWord);

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