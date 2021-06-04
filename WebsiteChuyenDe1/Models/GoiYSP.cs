using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace WebsiteChuyenDe1.Models
{
    public class GoiYSP
    {
        [Key]
        public int prid { get; set; }
        public int categoryid { get; set; }
        public string ten { get; set; }
        public string masp { get; set; }
        public string hinh { get; set; }
        public string mota { get; set; }
        public float gia { get; set; }
    }
}