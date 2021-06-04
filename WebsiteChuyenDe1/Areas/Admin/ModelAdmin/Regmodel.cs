using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebsiteChuyenDe1.Areas.Admin.ModelAdmin
{
    public class Regmodel
    {
        [Key]
        [Required(ErrorMessage = "Mời bạn nhập Username.")]
        public string UserName { set; get; }
        [Required(ErrorMessage = "Mời bạn nhập Password.")]
        public string PassWord { set; get; }
        public string ConfirmPassWord { set; get; }
    }
}