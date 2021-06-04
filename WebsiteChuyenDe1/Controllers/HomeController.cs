using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebsiteChuyenDe1.Models;
using PagedList;
using System.Net;

namespace WebsiteChuyenDe1.Controllers
{
    public class HomeController : Controller
    {
        dbnewEntities1 db = new dbnewEntities1();
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Listproducts(string searchString, int? cid, int? page, string sortOrder, string currentFilter, float? rating)
        {
            ViewBag.CurrentSort = sortOrder;
            if (searchString != null)
            {
                page = 1;
            }
            else
            {
                searchString = currentFilter;
            }

            ViewBag.CurrentFilter = searchString;
            var data = db.Products.ToList();
            if (cid != null)
            {
                data = data.Where(x => x.CategoryID == cid).ToList();
            }

            if (!String.IsNullOrEmpty(searchString))
            {
                data = data.Where(x => x.ModelName.Contains(searchString) || x.ModelNumber.Contains(searchString)).ToList();
            }
            if (rating != null)
            {
                data = (from pr in db.Products
                        join rv in db.Reviews on pr.ProductID equals rv.ProductID
                        where rv.Rating >= rating
                        select pr).ToList();
            }
            int pageSize = 6;
            int pageNumber = (page ?? 1);
            return View(data.ToPagedList(pageNumber, pageSize));
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
        public ActionResult Reviewshow(int rv)
        {
            var reviewdata = db.Reviews.Where(s => s.ProductID.Equals(rv));
            return View(reviewdata.ToList());
        }
        public ActionResult ViewOrder(int id)
        {
            var order = db.Orders.Where(s => s.CustomerID.Equals(id));
            return View(order.ToList());
        }
        
        public ActionResult DetailsOrder(int id)
        {
            var orderDetail = db.OrderDetails.Where(x => x.OrderID.Equals(id)).ToList();
            return View(orderDetail);
        }
        public ActionResult Addreview()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Addreview(int id, int? rating, string comment)
        {
            if (rating == null)
            {
                rating = 1;
            }
            var session = (UserLogin)Session[WebsiteChuyenDe1.Models.CommonConstants.USER_SESSION];
            string name = session.UserName;
            if (session != null)
            {
                Review review = new Review();
                review.ProductID = id;
                review.Rating = (int)rating;
                review.CustomerName = name;
                review.CustomerEmail = null;
                review.Comments = comment;
                db.Reviews.Add(review);
                db.SaveChanges();
                return Redirect(Request.UrlReferrer.ToString());
            }
            else
            {
                return RedirectToAction("Index", "Home");
            }
        }
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Product product = db.Products.Find(id);
            if (product == null)
            {
                return HttpNotFound();
            }
            return View(product);
        }
        public ActionResult Category()
        {
            var data = db.Categories.ToList();

            return PartialView(data);
        }
        public ActionResult Categoryindex()
        {
            var data = db.Categories.ToList();

            return PartialView(data);
        }
        public ActionResult Viewcart(int? cartid)
        {
            var session = (UserLogin)Session[WebsiteChuyenDe1.Models.CommonConstants.USER_SESSION];
            cartid = session.UserID;
            /* var data = db.ShoppingCarts.Where(x=>x.CustomerID.Equals(cartid)).ToList();*/
            var  data =(from spc in db.ShoppingCarts
                                          where
                                         spc.CustomerID == cartid
                                          select spc);
               /*    select new
                   {
                       ShoppingCart.Products.ProductID,
                       ShoppingCart.Products.ModelName,
                       ShoppingCart.Products.ModelNumber,
                       ShoppingCart.Quantity,
                       ShoppingCart.Products.UnitCost,
                       ExtendedAmount = (decimal?)Convert.ToDecimal((ShoppingCart.Products.UnitCost * ShoppingCart.Quantity))
                   }*/
            return View(data.ToList());
        }
        public ActionResult Addtocart(int soluong,int id,int? cusid)
        {
            try
            {
                var data = db.ShoppingCarts.ToList();
                if (cusid != null)
                {
                    foreach (var item in data) //Cập nhật số lượng sản phẩm ok
                    {
                        if (item.CustomerID.Equals(cusid) && item.ProductID.Equals(id))
                        {
                            item.Quantity = item.Quantity + soluong;
                            db.SaveChanges();
                            ViewBag.Message = "Cập nhật thành công !!";
                            return RedirectToAction("Index");
                        }
                    }
                    db.ShoppingCartAddItem(null, id, soluong, cusid);
                    ViewBag.Message = "Thêm thành công !!";
                    db.SaveChanges();
                    return RedirectToAction("Index");
                }
            }
            catch (Exception)
            {

                    ViewBag.Message = "Vui lòng đăng nhập trước !!";
                    return View("Index");
                
            }
            return View("Index");

        }
        public ActionResult Update(int soluong, int id, int? cusid)
        {
            try
            {
                var data = db.ShoppingCarts.ToList();
                if (cusid != null)
                {
                    foreach (var item in data) //Cập nhật số lượng sản phẩm ok
                    {
                        if (item.CustomerID.Equals(cusid) && item.ProductID.Equals(id))
                        {
                            item.Quantity =soluong;
                            db.SaveChanges();
                            ViewBag.Message = "Cập nhật thành công !!";
                            return RedirectToAction("Viewcart");
                        }
                    }
                    db.ShoppingCartAddItem(null, id, soluong, cusid);
                    ViewBag.Message = "Thêm thành công !!";
                    db.SaveChanges();
                    return RedirectToAction("Viewcart");
                }
            }
            catch (Exception)
            {

                ViewBag.Message = "Vui lòng đăng nhập trước !!";
                return View("Index");
            }
            return View("Index");

        }
        public ActionResult AddOrder(int cusid)
        {

            var data = db.ShoppingCarts.ToList();
            bool check = false;
            foreach (var item in data)
            {
                if (item.CustomerID.Equals(cusid))
                {
                    check = true;

                }
            }
            if (check == true)
            {
                db.OrderAdd(cusid, DateTime.Now, DateTime.Now.AddDays(3), false, null);
                db.ShoppingCartRemoveItem(cusid);
                ViewBag.Message = "Đặt hàng thành công";
                return RedirectToAction("Index");
            }
            else
            {
                ViewBag.Message = "Giỏ hàng này trống!!";
                return View("Viewcart");
            }

        }
        public ActionResult Xoacart(int cusid,int cartid)
        {
            var data = db.ShoppingCarts.ToList();
            foreach (var item in data)
            {
                if (item.CustomerID.Equals(cusid) && item.CartID.Equals(cartid))
                {
                    db.ShoppingCarts.Remove(item);
                }
            }
            db.SaveChanges();
            return RedirectToAction("Viewcart");
        }
        public ActionResult Top5sphot()
        {
            //Lấy top 5 sản phẩm 
            List<sellerBest> query = (from OrderDetails in db.OrderDetails
                                      join product in db.Products
                                             on OrderDetails.ProductID equals product.ProductID
                                      group new { OrderDetails, product } by new
                                      {
                                          OrderDetails.ProductID,
                                          product.ModelName,
                                          product.CategoryID,
                                          product.ProductImage,
                                          product.UnitCost
                                      } into g
                                      orderby
                                        g.Sum(p => p.OrderDetails.Quantity) descending
                                      select new sellerBest
                                      {
                                          categr = g.Key.CategoryID,
                                          ProID = g.Key.ProductID,
                                          Qty = (int)g.Sum(p => p.OrderDetails.Quantity),
                                          ProName = g.Key.ModelName,
                                          Hinh = g.Key.ProductImage,
                                          DoanhThu = (float)(g.Key.UnitCost * g.Sum(p => p.OrderDetails.Quantity))
                                      }).Take(5).ToList();
            return View(query);
        }
        public ActionResult GoiY(int? gy)
        {
            List<GoiYSP> query = (from od1 in db.OrderDetails
                                  join od2 in db.OrderDetails on od1.OrderID equals od2.OrderID
                                  join p in db.Products on od2.ProductID equals p.ProductID
                                  where
                                    od1.ProductID == gy &&
                                    od2.ProductID != gy
                                  group new { od2, p } by new
                                  {
                                      od2.ProductID,
                                      p.ModelName,
                                      p.ModelNumber,
                                      p.UnitCost,
                                      p.ProductImage,
                                      p.CategoryID,
                                      p.Description
                                  } into g
                                  orderby
                                    g.Count(c => c.od2.ProductID != null) descending
                                  select new GoiYSP
                                  {
                                      prid = g.Key.ProductID,
                                      ten = g.Key.ModelName,
                                      gia = (float)g.Key.UnitCost,
                                      masp = g.Key.ModelNumber,
                                      categoryid = g.Key.CategoryID,
                                      hinh = g.Key.ProductImage,
                                      mota = g.Key.Description
                                  }).Take(5).ToList();
            return PartialView(query);
        }
    }
}