using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Helpers;
using System.Web.Mvc;
using System.Web.Script.Services;
using System.Web.Services;
using WebsiteChuyenDe1.Models;
namespace WebsiteChuyenDe1.Areas.Admin.Controllers
{
    public class ThongKeController : BaseController
    {
        dbnewEntities1 db = new dbnewEntities1();
        // GET: Admin/ThongKe
        public ActionResult Top5()
        {
           var data= db.TopProduct().ToList();
            return View(data);
        }
        public ActionResult Bieudo()
        {

            List<DataPoint> data = (from c in db.Customers
                                    join od in db.Orders on c.CustomerID equals od.CustomerID
                                    join ol in db.OrderDetails on od.OrderID equals ol.OrderID
                                    join p in db.Products on ol.ProductID equals p.ProductID
                                   /* where od.OrderDate.Year == DateTime.Now.Year*/
                                    group new { c, p, ol } by new
                                    {
                                        c.FullName
                                    } into g
                                    orderby
                                   g.Sum(p => p.p.UnitCost * p.ol.Quantity) descending
                                    select new DataPoint
                                    {
                                        Label = g.Key.FullName,
                                        Y = (float)g.Sum(p => p.p.UnitCost * p.ol.Quantity)
                                    }).ToList();

            ViewBag.DataPoints = JsonConvert.SerializeObject(data);
            List<DataPoint> data2 = (from od in db.OrderDetails
                                     join o in db.Orders on od.OrderID equals o.OrderID
                                     join p in db.Products on od.ProductID equals p.ProductID
                                     where
                                       o.OrderDate.Year == DateTime.Now.Year
                                     group new { od,o,p } by new
                                     {
                                         Column1 = (int?)o.OrderDate.Month
                                     } into g
                                     select new DataPoint
                                     {
                                         Label = g.Key.Column1.ToString(),
                                         Y = (float)(float?)g.Sum(p => p.p.UnitCost * p.od.Quantity)
                                     }).ToList();

            ViewBag.DataPoints2 = JsonConvert.SerializeObject(data2);
            List<DataPoint> data3 = (from od in db.OrderDetails
                                     join p in db.Products on od.ProductID equals p.ProductID
                                     join cate in db.Categories on p.CategoryID equals cate.CategoryID
                                     group new { od, p, cate } by new
                                     {
                                         column = cate.CategoryName
                                     } into g
                                     select new DataPoint
                                     {
                                         Label = g.Key.column.ToString(),
                                         Y= (float)(int ?)g.Sum(p => p.od.Quantity)
                                     }).ToList();

            ViewBag.DataPoints3 = JsonConvert.SerializeObject(data3);
            return View();
        }
      
        public ActionResult ByCustomer(string SearchString)
        {
            var data = db.OrderListbycustomer().ToList();
            if (!String.IsNullOrEmpty(SearchString))
            {
                data = db.OrderListbycustomer().Where(x=>x.FullName.Contains(SearchString)).ToList();
            }
          
            ViewBag.FullName = new SelectList(db.Customers, "FullName", "FullName");
            return View(data.ToList());
        }
    }
}