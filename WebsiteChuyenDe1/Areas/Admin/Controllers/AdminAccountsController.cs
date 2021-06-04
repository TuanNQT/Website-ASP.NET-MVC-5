using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using WebsiteChuyenDe1.Models;

namespace WebsiteChuyenDe1.Areas.Admin.Controllers
{
    public class AdminAccountsController : BaseController
    {
        private dbnewEntities1 db = new dbnewEntities1();

        // GET: Admin/AdminAccounts
        public ActionResult Index()
        {
            return View(db.AdminAccounts.ToList());
        }

        // GET: Admin/AdminAccounts/Details/5
        public ActionResult Details(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            AdminAccount adminAccount = db.AdminAccounts.Find(id);
            if (adminAccount == null)
            {
                return HttpNotFound();
            }
            return View(adminAccount);
        }

        // GET: Admin/AdminAccounts/Create
        public ActionResult Create()
        {
            return View();
        }

        // POST: Admin/AdminAccounts/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "TaiKhoan,MatKhau")] AdminAccount adminAccount)
        {
            var data = db.AdminAccounts.ToList();
            if (ModelState.IsValid)
            {
                foreach (var item in data)
                {
                    if (item.TaiKhoan.Equals(adminAccount.TaiKhoan))
                    {
                        ViewBag.Message = "Tên đăng nhập đã tồn tại!!";
                        return View();
                    }
                }
                adminAccount.MatKhau = HashMD5.MD5Hash(adminAccount.MatKhau);
                db.AdminAccounts.Add(adminAccount);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            return View(adminAccount);
        }

        // GET: Admin/AdminAccounts/Edit/5
        public ActionResult Edit(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            AdminAccount adminAccount = db.AdminAccounts.Find(id);
            if (adminAccount == null)
            {
                return HttpNotFound();
            }
            return View(adminAccount);
        }

        // POST: Admin/AdminAccounts/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "TaiKhoan,MatKhau")] AdminAccount adminAccount)
        {
            var data = db.AdminAccounts.ToList();
            if (ModelState.IsValid)
            {
                foreach (var item in data)
                {
                    if (item.TaiKhoan.Equals(adminAccount.TaiKhoan))
                    {
                        ViewBag.Message = "Tên đăng nhập đã tồn tại!!";
                        return View();
                    }
                }
                adminAccount.MatKhau = HashMD5.MD5Hash(adminAccount.MatKhau);
                db.Entry(adminAccount).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            return View(adminAccount);
        }

        // GET: Admin/AdminAccounts/Delete/5
        public ActionResult Delete(string id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            AdminAccount adminAccount = db.AdminAccounts.Find(id);
            if (adminAccount == null)
            {
                return HttpNotFound();
            }
            return View(adminAccount);
        }

        // POST: Admin/AdminAccounts/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(string id)
        {
            AdminAccount adminAccount = db.AdminAccounts.Find(id);
            db.AdminAccounts.Remove(adminAccount);
            db.SaveChanges();
            return RedirectToAction("Index");
        }

        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                db.Dispose();
            }
            base.Dispose(disposing);
        }
    }
}
