using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using WebsiteChuyenDe1.Models;
using WebsiteChuyenDe1.Areas.Admin.ModelAdmin;

namespace WebsiteChuyenDe1.Areas.Admin.Controllers
{

    [OutputCache(NoStore = true, Duration = 0, VaryByParam = "None")]
    public class LoginAdminController : Controller
    {
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
        public ActionResult Reg(Regmodel regmodel)
        {
            var data = db.AdminAccounts.ToList();
            if (ModelState.IsValid)
            {
                if (!(regmodel.PassWord.Equals(regmodel.ConfirmPassWord)))
                {
                    ViewBag.Message = "Mật khẩu xác nhận không khớp !!";
                    return View();
                }
                foreach (var item in data)
                {
                    if (item.TaiKhoan.Equals(regmodel.UserName))
                    {
                        ViewBag.Message = "Tài khoản đã tồn tại!!";
                        return View();
                    }
                }
                var dao = new adminDao();
                AdminAccount adminAccount = new AdminAccount();
                adminAccount.TaiKhoan = regmodel.UserName;
                adminAccount.MatKhau = HashMD5.MD5Hash( regmodel.PassWord);
                var res = dao.Insert(adminAccount);
                if (res ==2)
                {
                    /* ViewBag.Message = "Đăng ký thành công";
                     RedirectToAction("Index");*/
                    var resreg = dao.Login(regmodel.UserName, HashMD5.MD5Hash(regmodel.PassWord));
                    if (resreg)
                    {
                        var user = dao.GetById(regmodel.UserName);
                        var adminSession = new AdminLogin();
                        adminSession.AdminName = user.TaiKhoan;
                        /*userSession.UserID = user.id;*/
                        Session.Add(CommonConstants.ADMIN_SESSION, adminSession);
                        return RedirectToAction("Index", "Default");
                    }
                }
            }
            return View();
        }
        public ActionResult Login(LoginModel model)
        {
                if (ModelState.IsValid)
                {
                    var dao = new adminDao();
                    var res = dao.Login(model.UserName, HashMD5.MD5Hash(model.PassWord));
                    if (res)
                    {
                        var user = dao.GetById(model.UserName);
                        var adminSession = new AdminLogin();
                    adminSession.AdminName = user.TaiKhoan;
                    /*userSession.UserID = user.id;*/
                    Session.Add(CommonConstants.ADMIN_SESSION, adminSession);
                    return RedirectToAction("Index", "Default");
                    }
                    else
                    {
                    ViewBag.Message = "Thông tin đăng nhập không chính xác";
                    return View("Index");
                }
                }
            return View();
        }
        public ActionResult Logout()
        {
            Session.Clear();
            return RedirectToAction("Index");

        }
    }
}