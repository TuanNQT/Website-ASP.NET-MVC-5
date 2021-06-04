using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;

namespace WebsiteChuyenDe1
{
    public class RouteConfig
    {
        public static void RegisterRoutes(RouteCollection routes)
        {
            routes.IgnoreRoute("{resource}.axd/{*pathInfo}");
            routes.MapRoute(
               name: "Product Details",
               url: "chi-tiet/san-pham-{id}",
               defaults: new { controller = "Home", action = "Details", id = UrlParameter.Optional }
           );
            routes.MapRoute(
              name: "Viewcart",
              url: "xem/gio-hang",
              defaults: new { controller = "Home", action = "Viewcart", id = UrlParameter.Optional }
          );
            routes.MapRoute(
              name: "ViewOrder",
              url: "xem/don-hang-{id}",
              defaults: new { controller = "Home", action = "ViewOrder", id = UrlParameter.Optional }
          );
            routes.MapRoute(
             name: "DetailsOrder",
             url: "chi-tiet/don-hang-{id}",
             defaults: new { controller = "Home", action = "DetailsOrder", id = UrlParameter.Optional }
         );
            routes.MapRoute(
               name: "TrangChu",
               url: "Trang-chu/shop",
               defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
           );
            routes.MapRoute(
                name: "Default",
                url: "{controller}/{action}/{id}",
                defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
            );
        }
    }
}
