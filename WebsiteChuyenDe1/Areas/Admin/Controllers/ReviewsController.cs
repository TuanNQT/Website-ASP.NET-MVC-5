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
    public class ReviewsController : BaseController
    {
        private dbnewEntities1 db = new dbnewEntities1();

        // GET: Admin/Reviews
        public ActionResult Index()
        {
            var reviews = db.Reviews.Include(r => r.Product);
            return View(reviews.ToList());
        }

        // GET: Admin/Reviews/Details/5
        public ActionResult Details(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Review review = db.Reviews.Find(id);
            if (review == null)
            {
                return HttpNotFound();
            }
            return View(review);
        }

        // GET: Admin/Reviews/Create
        public ActionResult Create()
        {
            ViewBag.ProductID = new SelectList(db.Products, "ProductID", "ModelNumber");
            ViewBag.CustomerName = new SelectList(db.Customers, "FullName", "FullName");
            ViewBag.CustomerEmail = new SelectList(db.Customers, "EmailAddress", "EmailAddress");
            return View();
        }

        // POST: Admin/Reviews/Create
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "ReviewID,ProductID,CustomerName,CustomerEmail,Rating,Comments")] Review review)
        {
            if (ModelState.IsValid)
            {
                if (review.Rating < 1)
                {
                    review.Rating = 1;
                }
                db.Reviews.Add(review);
                db.SaveChanges();
                return RedirectToAction("Index");
            }

            ViewBag.ProductID = new SelectList(db.Products, "ProductID", "ModelNumber", review.ProductID);
            ViewBag.CustomerName = new SelectList(db.Customers, "FullName", "FullName", review.CustomerName);
            ViewBag.CustomerEmail = new SelectList(db.Customers, "EmailAddress", "EmailAddress", review.CustomerEmail);
            return View(review);
        }

        // GET: Admin/Reviews/Edit/5
        public ActionResult Edit(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Review review = db.Reviews.Find(id);
            if (review == null)
            {
                return HttpNotFound();
            }
            ViewBag.ProductID = new SelectList(db.Products, "ProductID", "ModelNumber");
            ViewBag.CustomerName = new SelectList(db.Customers, "FullName", "FullName");
            ViewBag.CustomerEmail = new SelectList(db.Customers, "EmailAddress", "EmailAddress");
            return View(review);
        }

        // POST: Admin/Reviews/Edit/5
        // To protect from overposting attacks, enable the specific properties you want to bind to, for 
        // more details see https://go.microsoft.com/fwlink/?LinkId=317598.
        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "ReviewID,ProductID,CustomerName,CustomerEmail,Rating,Comments")] Review review)
        {
            if (ModelState.IsValid)
            {
                if (review.Rating < 1)
                {
                    review.Rating = 1;
                }
                db.Entry(review).State = EntityState.Modified;
                db.SaveChanges();
                return RedirectToAction("Index");
            }
            ViewBag.ProductID = new SelectList(db.Products, "ProductID", "ModelNumber", review.ProductID);
            ViewBag.CustomerName = new SelectList(db.Customers, "FullName", "FullName", review.CustomerName);
            ViewBag.CustomerEmail = new SelectList(db.Customers, "EmailAddress", "EmailAddress", review.CustomerEmail);
            return View(review);
        }

        // GET: Admin/Reviews/Delete/5
        public ActionResult Delete(int? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Review review = db.Reviews.Find(id);
            if (review == null)
            {
                return HttpNotFound();
            }
            return View(review);
        }

        // POST: Admin/Reviews/Delete/5
        [HttpPost, ActionName("Delete")]
        [ValidateAntiForgeryToken]
        public ActionResult DeleteConfirmed(int id)
        {
            Review review = db.Reviews.Find(id);
            db.Reviews.Remove(review);
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
