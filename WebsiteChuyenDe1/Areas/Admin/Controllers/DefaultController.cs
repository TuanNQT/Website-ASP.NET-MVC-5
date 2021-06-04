using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebsiteChuyenDe1.Models;

namespace WebsiteChuyenDe1.Areas.Admin.Controllers
{
    public class DefaultController : BaseController
    {
         dbnewEntities1 db = new dbnewEntities1();
        // GET: Admin/Default
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Products(int? cid ,string searchname)
        {
            var data = db.showproduct().ToList();
            if (cid!=null)
            {
                data = data.Where(x => x.CategoryID == cid).ToList();
            }
            if (!String.IsNullOrEmpty(searchname))
            {
                data = data.Where(x => x.ModelName.Contains(searchname) || x.ModelNumber.Contains(searchname)).ToList();
            }
            ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName");
            return View(data);
        }
        // GET: Admin/Default/Details/5
        public ActionResult Details(int id)
        {
            var data = db.curdProduct(id, null, null, null, null, null, null, "chitiet").Single(x => x.ProductID == id);
            return View(data);
        }

        // GET: Admin/Default/Create
        public ActionResult Create()
        {
            ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName");
            return View();
        }

        // POST: Admin/Default/Create
        [HttpPost]
        public ActionResult Create(Product collection, HttpPostedFileBase file)
        {
            var pro = db.Products.ToList();
            foreach (var item in pro)
            {
                if (item.ModelNumber.Equals(collection.ModelNumber) && item.ModelName.Equals(collection.ModelName) && item.CategoryID.Equals(collection.CategoryID))
                {
                    ViewBag.Message = "Sản phẩm này đã tồn tại!!";
                    ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName");
                    return View("Create");
                }
            }
            try
            {
                if (file != null)
                {
                    string pic = System.IO.Path.GetFileName(file.FileName);
                    string path = System.IO.Path.Combine(
                                           Server.MapPath("~/images"), pic);
                    // file is uploaded
                    file.SaveAs(path);
                    collection.ProductImage = pic;
                    // save the image path path to the database or you can send image 
                    // directly to database
                    // in-case if you want to store byte[] ie. for DB
                    using (MemoryStream ms = new MemoryStream())
                    {
                        file.InputStream.CopyTo(ms);
                        byte[] array = ms.GetBuffer();
                    }

                }
                // TODO: Add insert logic here
                db.curdProduct(null, collection.CategoryID, collection.ModelNumber, collection.ModelName, collection.ProductImage, collection.UnitCost, collection.Description, "them");
                db.SaveChanges();
                ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName");
                return RedirectToAction("Products");
            }
            catch
            {
                return RedirectToAction("Products");
            }
        }

        // GET: Admin/Default/Edit/5
        public ActionResult Edit(int id)
        {
            var data = db.curdProduct(id, null, null, null, null, null, null, "chitiet").Single(x => x.ProductID == id);
            Product product = db.Products.Find(id);
            ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName", product.CategoryID);
            return View(data);
        }

        // POST: Admin/Default/Edit/5
        [HttpPost]
        public ActionResult Edit(int id, Product collection, HttpPostedFileBase file)
        {
            try
            {

                if (file != null)
                {
                    string pic = System.IO.Path.GetFileName(file.FileName);
                    string path = System.IO.Path.Combine(
                                           Server.MapPath("~/images"), pic);
                    // file is uploaded
                    file.SaveAs(path);
                    collection.ProductImage = pic;
                    // save the image path path to the database or you can send image 
                    // directly to database
                    // in-case if you want to store byte[] ie. for DB
                    using (MemoryStream ms = new MemoryStream())
                    {
                        file.InputStream.CopyTo(ms);
                        byte[] array = ms.GetBuffer();
                    }

                }
                // TODO: Add update logic here
                db.curdProduct(id, collection.CategoryID, collection.ModelNumber, collection.ModelName, collection.ProductImage, collection.UnitCost, collection.Description, "sua");
                db.SaveChanges();
                ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName", collection.CategoryID);
                return RedirectToAction("Products");
            }
            catch
            {
                ViewBag.CategoryID = new SelectList(db.Categories, "CategoryID", "CategoryName");
                return RedirectToAction("Products");
            }
        }

        // GET: Admin/Default/Delete/5
        public ActionResult Delete(int id)
        {
            var data = db.curdProduct(id, null, null, null, null, null, null, "chitiet").Single(x => x.ProductID == id);
            return View(data);
        }

        // POST: Admin/Default/Delete/5
        [HttpPost]
        public ActionResult Delete(int id, Product collection)
        {
            try
            {
                // TODO: Add delete logic here
                db.curdProduct(id, collection.CategoryID, collection.ModelNumber, collection.ModelName, collection.ProductImage, collection.UnitCost, collection.Description, "xoa");
                db.SaveChanges();
                return RedirectToAction("Products");
            }
            catch
            {
                return RedirectToAction("Products");
            }
        }
    }
}
