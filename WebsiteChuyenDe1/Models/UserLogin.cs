using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace WebsiteChuyenDe1.Models
{
    [Serializable]
    public class UserLogin
    {
        public int UserID { set; get; }
        public string UserName { set; get; }
    }
}