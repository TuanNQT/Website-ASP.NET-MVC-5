using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using WebsiteChuyenDe1.Models;

namespace WebsiteChuyenDe1.Areas.Admin.Controllers
{
    public class OrderController : BaseController
    {
        dbnewEntities1 db = new dbnewEntities1();
        // GET: Admin/Order
        public ActionResult Index(int? idorder,/*int? ClientId*/int? cusid, bool? trangthai, DateTime? startDate, DateTime? endDate)
        {
           var data = db.Orders.ToList();
            if (idorder != null)
            {
                data = data.Where(x => x.OrderID.Equals(idorder)).ToList();
            }
            if (cusid !=null)
            {
                data = data.Where(x => x.CustomerID.Equals(cusid)).ToList();
            }
            if (trangthai!=null)
            {
                data = data.Where(x => x.status.Equals(trangthai)).ToList();
            }
            if (!String.IsNullOrEmpty(startDate.ToString()) && !String.IsNullOrEmpty(endDate.ToString()))
            {
                data = (List<Order>)
                        (from o in db.Orders
                         where
                           o.OrderDate >= startDate && o.OrderDate <= endDate
                         orderby
                           o.OrderDate descending
                         select o).ToList();
            }
            return View(data.ToList());
        }
        public ActionResult Details(int? id)
        {
            var data = db.OrderDetails.ToList();
            if (id !=null)
            {
                 data = db.OrderDetails.Where(x=>x.OrderID == id).ToList();
            }
            
            return View(data);
        }
        public ActionResult Delete(int id)
        {
            /* var orderdetails = db.OrderDetails.Where(x => x.OrderID == id).ToList();
             var order = db.Orders.Where(x => x.OrderID == id);
             db.OrderDetails.Remove(orderdetails);*/
            Order order = db.Orders.Single(x => x.OrderID == id);
            foreach (OrderDetail item in db.OrderDetails.ToList())
            {
                if (item.OrderID==id)
                {
                    db.OrderDetails.Remove(item);
                }
            }
            db.Orders.Remove(order);
            db.SaveChanges();
            return RedirectToAction("Index");
        }
        public ActionResult checkorder(int? id)
        {
           
            var queryOrders = from Orders in db.Orders
                              where Orders.OrderID == id
                              select Orders;
            foreach (var Orders in queryOrders)
            {
                Orders.status =true;
            }
            db.SaveChanges();
            return RedirectToAction("Index");
        }
        public ActionResult Add()
        {
            ViewBag.CustomerID = new SelectList(db.Customers, "CustomerID", "FullName");
            return View();
        }
        [HttpPost]
        public ActionResult Add(Customer customer)
        {
            
            var data = db.ShoppingCarts.ToList();
            bool check = false;
            foreach (var item in data)
            {
                if (item.CustomerID.Equals(customer.CustomerID))
                {
                    check = true;
                 
                }
            }
            if (check==true)
            {
                db.OrderAdd(customer.CustomerID, DateTime.Now, DateTime.Now.AddDays(3), false, null);
                db.ShoppingCartRemoveItem(customer.CustomerID);
                return RedirectToAction("Index");
            }
            else {
                ViewBag.Message = "Giỏ hàng này trống!!";
                ViewBag.CustomerID = new SelectList(db.Customers, "CustomerID", "FullName");
                return View();
            }

        }
        public ActionResult Addshopingcart()
        {
            ViewBag.CustomerID = new SelectList(db.Customers, "CustomerID", "FullName");
            ViewBag.ProductID = new SelectList(db.Products, "ProductID", "ProductID");
            return View();
        }
        [HttpPost]
        public ActionResult Addshopingcart(Customer customer,Product product,int soluong)
        {

            ViewBag.CustomerID = new SelectList(db.Customers, "CustomerID", "FullName");
            ViewBag.ProductID = new SelectList(db.Products, "ProductID", "ProductID");
          
            var data = db.ShoppingCarts.ToList();
            foreach (var item in data) //Cập nhật số lượng sản phẩm ok
            {
                if (item.CustomerID.Equals(customer.CustomerID) && item.ProductID.Equals(product.ProductID))
                {
                    item.Quantity = item.Quantity + soluong;
                    db.SaveChanges();
                    ViewBag.Message = "Cập nhật thành công !!";
                    return View();
                }
            }
            db.ShoppingCartAddItem(null, product.ProductID, soluong, customer.CustomerID);
            ViewBag.Message = "Thêm thành công !!";
            db.SaveChanges();
            return View();
        }
    }
}