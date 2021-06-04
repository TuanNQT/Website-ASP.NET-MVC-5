using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebsiteChuyenDe1.Models;

namespace WebsiteChuyenDe1.Controllers
{

    [OutputCache(NoStore = true, Duration = 0, VaryByParam = "None")]

    public class LoginUserController : Controller
    {
        // GET: LoginUser

        dbnewEntities1 db = new dbnewEntities1();
        // GET: Admin/LoginAdmin
        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Reg()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Reg(regmodel reg)
        {
            var data = db.Customers.ToList();
        
                if (!(reg.PassWord.Equals(reg.ConfirmPassWord)))
                {
                    ViewBag.Message = "Mật khẩu xác nhận không khớp !!";
                    return View();
                }
                foreach (var item in data)
                {
                    if (item.EmailAddress.Equals(reg.Email) && item.FullName.Equals(reg.UserName))
                    {
                        ViewBag.Message = "Tài khoản đã tồn tại!!";
                        return View("regerror");
                    }
                }
                var dao = new userDao();
                Customer customer = new Customer();
                customer.FullName = reg.UserName;
                customer.EmailAddress = reg.Email;
                customer.Password = HashMD5.MD5Hash(reg.PassWord);
                var res = dao.Insert(customer);
                if (res == 2)
                {
                /*ViewBag.Message = "Đăng ký thành công";
                return View("regsuccess");*/
                var reslogin = dao.Login(reg.UserName, HashMD5.MD5Hash(reg.PassWord));
                if (reslogin)
                {
                    var user = dao.GetById(reg.UserName);
                    var usersession = new UserLogin();
                    usersession.UserID = user.CustomerID;
                    usersession.UserName = user.FullName;
                    Session.Add(CommonConstants.USER_SESSION, usersession);
                    return Redirect(Request.UrlReferrer.ToString());
                    /*return RedirectToAction("Index","Home");*/
                }
            }
            
            return View();
        }
        public ActionResult Login(loginmodel model)
        {
            Session.Clear();
            if (ModelState.IsValid)
            {
                var dao = new userDao();
                var res = dao.Login(model.UserName, HashMD5.MD5Hash(model.PassWord));
                if (res)
                {
                    var user = dao.GetById(model.UserName);
                    var usersession = new UserLogin();
                    usersession.UserID = user.CustomerID;
                    usersession.UserName = user.FullName;
                    Session.Add(CommonConstants.USER_SESSION, usersession);
                    return Redirect(Request.UrlReferrer.ToString());
                    /*return RedirectToAction("Index","Home");*/
                }
                else
                {
                    ViewBag.Message = "Thông tin đăng nhập không chính xác";
                    return View("loginError");
                }
            }
            ViewBag.Message = "Thông tin đăng nhập không chính xác";
            return View("loginError");
        }
        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Index","Home");

        }
        public ActionResult loginError()
        {
            ViewBag.Message = "Thông tin đăng nhập không chính xác";
            return View("Error");

        }
        public ActionResult regerror()
        {
            ViewBag.Message = "Đăng ký không thành công";
            return View();

        }
        public ActionResult regsuccess()
        {
            ViewBag.Message = "Đăng ký tại khoản thành công";
            return View();

        }

    }
}