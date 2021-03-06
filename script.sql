USE [master]
GO
/****** Object:  Database [dbnew]    Script Date: 12/21/2020 11:28:22 PM ******/
CREATE DATABASE [dbnew]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'dbnew', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\dbnew.mdf' , SIZE = 3136KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'dbnew_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.SQLEXPRESS\MSSQL\DATA\dbnew_log.ldf' , SIZE = 784KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [dbnew] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [dbnew].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [dbnew] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [dbnew] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [dbnew] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [dbnew] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [dbnew] SET ARITHABORT OFF 
GO
ALTER DATABASE [dbnew] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [dbnew] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [dbnew] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [dbnew] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [dbnew] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [dbnew] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [dbnew] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [dbnew] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [dbnew] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [dbnew] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [dbnew] SET  ENABLE_BROKER 
GO
ALTER DATABASE [dbnew] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [dbnew] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [dbnew] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [dbnew] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [dbnew] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [dbnew] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [dbnew] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [dbnew] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [dbnew] SET  MULTI_USER 
GO
ALTER DATABASE [dbnew] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [dbnew] SET DB_CHAINING OFF 
GO
ALTER DATABASE [dbnew] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [dbnew] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [dbnew]
GO
/****** Object:  StoredProcedure [dbo].[curdProduct]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[curdProduct]
(
@id int = null,
@cateid int=null,
@ma nvarchar(50)=null,
@ten nvarchar(50)=null,
@anh nvarchar(50)=null,
@gia money=null,
@mota nvarchar(max)=null,
@option nvarchar(50)=null
)
as
begin
	if(@option='them')
	begin
	insert into Products values(@cateid,@ma,@ten,@anh,@gia,@mota)
	end
	if(@option='chitiet')
	begin
	select * from Products where ProductID=@id
	end
	if(@option='sua')
	begin
	update  Products set CategoryID=@cateid,ModelNumber= @ma,ModelName= @ten,ProductImage= @anh,UnitCost= @gia,Description=@mota where ProductID=@id 
	end
	if(@option='xoa')
	begin
	Delete from Products where ProductID =@id
	end
end

GO
/****** Object:  StoredProcedure [dbo].[CustomerAdd]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE Procedure [dbo].[CustomerAdd]
(
    @FullName   nvarchar(50),
    @Email      nvarchar(50),
    @Password   nvarchar(50),
    @CustomerID int OUTPUT
)
AS

INSERT INTO Customers
(
    FullName,
    EMailAddress,
    Password
)

VALUES
(
    @FullName,
    @Email,
    @Password
)

SELECT
    @CustomerID = @@Identity


GO
/****** Object:  StoredProcedure [dbo].[GetCategories]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO

CREATE PROCEDURE [dbo].[GetCategories] AS
SELECT * FROM Categories

GO
/****** Object:  StoredProcedure [dbo].[GetProducts]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetProducts] AS
SELECT * FROM Products 
GO
/****** Object:  StoredProcedure [dbo].[OrderAdd]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[OrderAdd]
(
	@CustomerID int,
	@OrderDate datetime,
	@ShipDate datetime,
	@status bit,
	@OrderID int OUTPUT
)
AS
BEGIN TRAN AddOrder /*Transaction giúp hành động được thực thi nếu như các câu lệnh bên trong thực hiện được toàn bộ. Nếu không rẽ Rollback về dl ban đầu*/
	INSERT INTO Orders
	(
		CustomerID,
		OrderDate,
		ShipDate,
		status
	)
	VALUES
	(
		@CustomerID,
		@OrderDate,
		@ShipDate,
		@status
	)

	SELECT @OrderID = @@IDENTITY

	/*Đưa các mặt hàng có trong bảng Shopping Cart vào bảng OrderDetails*/

	INSERT INTO OrderDetails
	(
		OrderID,
		ProductID,
		Quantity,
		UnitCost
	)
	SELECT
		@OrderID,
		ShoppingCart.ProductID,
		ShoppingCart.Quantity,
		Products.UnitCost
	FROM
		ShoppingCart
		INNER JOIN Products ON ShoppingCart.ProductID = Products.ProductID
	WHERE CustomerID = @CustomerID
commit
GO
/****** Object:  StoredProcedure [dbo].[OrderList]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OrderList]	
AS

SELECT 
	Orders.OrderID,
	CAST(SUM(OrderDetails.Quantity * OrderDetails.UnitCost) AS money) AS 'Tổng tiền',
	Orders.OrderDate,
	Orders.ShipDate,
	Customers.FullName
FROM Orders
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
GROUP BY
	Orders.CustomerID,
	Orders.OrderID,
	Orders.OrderDate,
	Orders.ShipDate,
	Customers.FullName

GO
/****** Object:  StoredProcedure [dbo].[OrderListbycustomer]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[OrderListbycustomer]
AS

SELECT 
	Orders.OrderID,
	CAST(SUM(OrderDetails.Quantity * OrderDetails.UnitCost) AS money) AS 'Tổng tiền',
	Orders.OrderDate,
	Orders.ShipDate,
	Customers.FullName
FROM Orders
INNER JOIN OrderDetails ON OrderDetails.OrderID = Orders.OrderID
INNER JOIN Customers ON Orders.CustomerID = Customers.CustomerID
GROUP BY
	Orders.CustomerID,
	Orders.OrderID,
	Orders.OrderDate,
	Orders.ShipDate,
	Customers.FullName

GO
/****** Object:  StoredProcedure [dbo].[ProductsByCategory]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[ProductsByCategory]
(
	@CatergoryID int
)
AS

SELECT 
	Products.ProductID,
	Products.ModelNumber,
	Products.ModelName,
	Products.ProductImage,
	Products.UnitCost,
	Products.[Description]
FROM Products
WHERE Products.CategoryID = @CatergoryID
GO
/****** Object:  StoredProcedure [dbo].[ShoppingCartAddItem]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[ShoppingCartAddItem]
(
	@CartID int output,
	@ProductID int,
	@Quantity int,
	@CustomerID int
)
AS

DECLARE @CountItems int

SELECT 
	@CountItems = COUNT(ProductID)
FROM ShoppingCart
WHERE ShoppingCart.ProductID = @ProductID
  AND ShoppingCart.CartID = @CartID

 IF @CountItems > 0 /*Đây là trường cần UPDATE*/
 BEGIN
	UPDATE ShoppingCart
	SET Quantity = (@Quantity + ShoppingCart.Quantity)
	WHERE 
		ProductID = @ProductID
	AND CartID = @CartID
END
ELSE
BEGIN
	INSERT INTO ShoppingCart
	(
		Quantity,
		ProductID,
		DateCreated,
		CustomerID
	)
	Values
	(
		@Quantity,
		@ProductID,
		CURRENT_TIMESTAMP,
		@CustomerID
	)
END

GO
/****** Object:  StoredProcedure [dbo].[ShoppingCartRemoveItem]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE Procedure [dbo].[ShoppingCartRemoveItem]
(
    @CustomerID int 
)
AS

DELETE FROM ShoppingCart

WHERE
    CustomerID = @CustomerID
GO
/****** Object:  StoredProcedure [dbo].[showproduct]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[showproduct]
as
select * from Products
GO
/****** Object:  StoredProcedure [dbo].[TopProduct]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [dbo].[TopProduct]
AS
SELECT TOP(5) OrderDetails.ProductID, SUM(Quantity) AS TotalQuantity,Products.ModelName,Products.ProductImage,Products.UnitCost * SUM(Quantity) AS N'Doanh Thu'
FROM OrderDetails join  Products on Products.ProductID = OrderDetails.ProductID 
GROUP BY OrderDetails.ProductID,Products.ModelName,Products.ProductImage,Products.UnitCost
ORDER BY SUM(Quantity) DESC;
GO
/****** Object:  Table [dbo].[AdminAccount]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AdminAccount](
	[TaiKhoan] [nvarchar](50) NOT NULL,
	[MatKhau] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_AdminAccount] PRIMARY KEY CLUSTERED 
(
	[TaiKhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Categories]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryName] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Customers]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customers](
	[CustomerID] [int] IDENTITY(1,1) NOT NULL,
	[FullName] [nvarchar](50) NULL,
	[EmailAddress] [nvarchar](50) NULL,
	[Password] [nvarchar](50) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[OrderDetails]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[OrderDetails](
	[OrderID] [int] NOT NULL,
	[ProductID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitCost] [money] NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Orders]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Orders](
	[OrderID] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[OrderDate] [datetime] NOT NULL CONSTRAINT [DF_Orders_OrderDate]  DEFAULT (getdate()),
	[ShipDate] [datetime] NOT NULL CONSTRAINT [DF_Orders_ShipDate]  DEFAULT (getdate()),
	[status] [bit] NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Products]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Products](
	[ProductID] [int] IDENTITY(1,1) NOT NULL,
	[CategoryID] [int] NOT NULL,
	[ModelNumber] [nvarchar](50) NULL,
	[ModelName] [nvarchar](50) NULL,
	[ProductImage] [nvarchar](50) NULL,
	[UnitCost] [money] NOT NULL,
	[Description] [nvarchar](3800) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Reviews]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Reviews](
	[ReviewID] [int] IDENTITY(1,1) NOT NULL,
	[ProductID] [int] NOT NULL,
	[CustomerName] [nvarchar](50) NULL,
	[CustomerEmail] [nvarchar](50) NULL,
	[Rating] [int] NOT NULL,
	[Comments] [nvarchar](3850) NULL
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[ShoppingCart]    Script Date: 12/21/2020 11:28:22 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ShoppingCart](
	[CartID] [int] IDENTITY(1,1) NOT NULL,
	[Quantity] [int] NOT NULL CONSTRAINT [DF_ShoppingCart_Quantity]  DEFAULT ((1)),
	[ProductID] [int] NOT NULL,
	[DateCreated] [datetime] NOT NULL CONSTRAINT [DF_ShoppingCart_DateCreated]  DEFAULT (getdate()),
	[CustomerID] [int] NOT NULL,
 CONSTRAINT [PK_ShoppingCart_1] PRIMARY KEY CLUSTERED 
(
	[CartID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
INSERT [dbo].[AdminAccount] ([TaiKhoan], [MatKhau]) VALUES (N'admin', N'21232f297a57a5a743894a0e4a801fc3')
INSERT [dbo].[AdminAccount] ([TaiKhoan], [MatKhau]) VALUES (N'tuan', N'21232f297a57a5a743894a0e4a801fc3')
INSERT [dbo].[AdminAccount] ([TaiKhoan], [MatKhau]) VALUES (N'Tuấn', N'21232f297a57a5a743894a0e4a801fc3')
SET IDENTITY_INSERT [dbo].[Categories] ON 

INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (14, N'Đồ ăn')
INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (15, N'Đồ uống')
INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (16, N'Đồ dùng')
INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (17, N'Đồ chơi')
INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (18, N'Gia dụng')
INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (19, N'Đa dạng')
INSERT [dbo].[Categories] ([CategoryID], [CategoryName]) VALUES (20, N'Bấm bài')
SET IDENTITY_INSERT [dbo].[Categories] OFF
SET IDENTITY_INSERT [dbo].[Customers] ON 

INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (1, N'James Bondwell', N'jb@ibuyspy.com', N'IBS_007')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (2, N'Sarah Goodpenny', N'sg@ibuyspy.com', N'IBS_001')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (3, N'Gordon Que', N'gq@ibuyspy.com', N'IBS_000')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (19, N'Guest Account', N'guest', N'guest')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (16, N'Test Account', N'd', N'd')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (20, N'Tuấn', N'Ngocandrong0@gmail.com', N'96e79218965eb72c92a549dd5a330112')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (21, N'20011830194', N'takeyourloves@gmail.com', N'e882b72bccfc2ad578c27b0d9b472a14')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (22, N'ntn', N'takeyourloves@gmail.com', N'04aa15dec4b94f1fe7bd3e275a9f1de3')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (23, N'Thần', N'and@gmail', N'd6b8cc42803ea100735c719f1d7f5e11')
INSERT [dbo].[Customers] ([CustomerID], [FullName], [EmailAddress], [Password]) VALUES (24, N'quangtuấn', N'quangtuan@gmail.com', N'd6b8cc42803ea100735c719f1d7f5e11')
SET IDENTITY_INSERT [dbo].[Customers] OFF
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (99, 404, 2, 459.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (93, 363, 1, 1.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (101, 378, 2, 14.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (131, 356, 22, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (96, 378, 1, 14.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (103, 363, 1, 1.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (104, 355, 1, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (104, 378, 1, 14.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (104, 406, 1, 399.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (100, 404, 2, 459.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (101, 401, 1, 599.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (131, 357, 3, 2.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (104, 362, 1, 1.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (104, 404, 1, 459.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (105, 355, 2, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (132, 356, 1, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (132, 357, 1, 2.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (107, 368, 2, 19999.9800)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (112, 355, 5, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (112, 356, 5, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (113, 355, 5, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (113, 356, 5, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (114, 355, 5, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (114, 356, 5, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (131, 358, 1, 199.0000)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (129, 355, 4, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (129, 356, 4, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (129, 357, 4, 2.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (129, 358, 4, 199.0000)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (132, 355, 1, 1499.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (130, 356, 6, 3.9900)
INSERT [dbo].[OrderDetails] ([OrderID], [ProductID], [Quantity], [UnitCost]) VALUES (130, 359, 3, 1299.9900)
SET IDENTITY_INSERT [dbo].[Orders] ON 

INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (99, 19, CAST(N'2000-07-06 01:01:00.000' AS DateTime), CAST(N'2000-07-07 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (93, 16, CAST(N'2000-07-03 01:01:00.000' AS DateTime), CAST(N'2000-07-04 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (101, 16, CAST(N'2000-07-10 01:01:00.000' AS DateTime), CAST(N'2000-07-11 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (103, 16, CAST(N'2000-07-10 01:01:00.000' AS DateTime), CAST(N'2000-07-10 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (96, 19, CAST(N'2000-07-03 01:01:00.000' AS DateTime), CAST(N'2000-07-03 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (104, 19, CAST(N'2000-07-10 01:01:00.000' AS DateTime), CAST(N'2000-07-11 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (105, 16, CAST(N'2000-10-30 01:01:00.000' AS DateTime), CAST(N'2000-10-31 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (132, 20, CAST(N'2020-12-05 19:53:10.080' AS DateTime), CAST(N'2020-12-08 19:53:10.080' AS DateTime), 0)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (107, 16, CAST(N'2000-10-30 01:01:00.000' AS DateTime), CAST(N'2000-10-31 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (100, 19, CAST(N'2000-07-06 01:01:00.000' AS DateTime), CAST(N'2000-07-08 01:01:00.000' AS DateTime), NULL)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (131, 20, CAST(N'2020-12-05 14:20:09.733' AS DateTime), CAST(N'2020-12-08 14:20:09.733' AS DateTime), 0)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (112, 20, CAST(N'2019-05-05 00:00:00.000' AS DateTime), CAST(N'2020-05-05 00:00:00.000' AS DateTime), 0)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (113, 20, CAST(N'2019-05-05 00:00:00.000' AS DateTime), CAST(N'2020-05-05 00:00:00.000' AS DateTime), 1)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (114, 20, CAST(N'2019-05-05 00:00:00.000' AS DateTime), CAST(N'2020-05-05 00:00:00.000' AS DateTime), 1)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (129, 20, CAST(N'2020-12-03 20:53:30.437' AS DateTime), CAST(N'2020-12-06 20:53:30.437' AS DateTime), 0)
INSERT [dbo].[Orders] ([OrderID], [CustomerID], [OrderDate], [ShipDate], [status]) VALUES (130, 3, CAST(N'2020-12-04 00:57:23.447' AS DateTime), CAST(N'2020-12-07 00:57:23.447' AS DateTime), 0)
SET IDENTITY_INSERT [dbo].[Orders] OFF
SET IDENTITY_INSERT [dbo].[Products] ON 

INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (355, 16, N'RU007', N'Racing', N'a1.jpg', 1499.9900, N'Looks like an ordinary bumbershoot, but don''t be fooled! Simply place Rain Racer''s tip on the ground and press the release latch. Within seconds, this ordinary rain umbrella converts into a two-wheeled gas-powered mini-scooter. Goes from 0 to 60 in 7.5 seconds - even in a driving rain! Comes in black, blue, and candy-apple red.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (356, 20, N'STKY1', N'Phú phò', N'a2.jpg', 3.9900, N'The latest in personal survival gear, the STKY1 looks like a roll of ordinary office tape, but can save your life in an emergency.  Just remove the tape roll and place in a kettle of boiling water with mixed vegetables and a ham shank. In just 90 minutes you have a great tasking soup that really sticks to your ribs! Herbs and spices not included.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (357, 16, N'P38', N'Máy sấy', N'a3.jpg', 2.9900, N'In a jam, need a quick escape? Just whip out a sheet of our patented P38 paper and, with a few quick folds, it converts into a lighter-than-air escape vehicle! Especially effective on windy days - no fuel required. Comes in several sizes including letter, legal, A10, and B52.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (358, 19, N'NOZ119', N'Tủ lạnh', N'a4.jpg', 199.0000, N'High-tech miniaturized extracting tool. Excellent for extricating foreign objects from your person. Good for picking up really tiny stuff, too! Cleverly disguised as a pair of tweezers. ')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (359, 16, N'PT109', N'Tivi', N'a5.jpg', 1299.9900, N'Camouflaged as stylish wing tips, these ''shoes'' get you out of a jam on the high seas instantly. Exposed to water, the pair transforms into speedy miniature inflatable rafts. Complete with 76 HP outboard motor, these hip heels will whisk you to safety even in the roughest of seas. Warning: Not recommended for beachwear.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (360, 14, N'RED1', N'Bánh quy', N'a6.jpg', 49.9900, N'Subversively stay in touch with this miniaturized wireless communications device. Speak into the pointy end and listen with the other end! Voice-activated dialing makes calling for backup a breeze. Excellent for undercover work at schools, rest homes, and most corporate headquarters. Comes in assorted colors.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (362, 14, N'LK4TLNT', N'Bánh gạo', N'a7.jpg', 1.9900, N'Persuade anyone to see your point of view!  Captivate your friends and enemies alike!  Draw the crime-scene or map out the chain of events.  All you need is several years of training or copious amounts of natural talent. You''re halfway there with the Persuasive Pencil. Purchase this item with the Retro Pocket Protector Rocket Pack for optimum disguise.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (363, 18, N'NTMBS1', N'Nồi cơm', N'a8.jpg', 1.9900, N'One of our most popular items!  A band of rubber that stretches  20 times the original size. Uses include silent one-to-one communication across a crowded room, holding together a pack of Persuasive Pencils, and powering lightweight aircraft. Beware, stretching past 20 feet results in a painful snap and a rubber strip.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (364, 19, N'NE1RPR', N'Súng ngắn', N'a9.jpg', 4.9900, N'Few people appreciate the awesome repair possibilities contained in a single roll of duct tape. In fact, some houses in the Midwest are made entirely out of the miracle material contained in every roll! Can be safely used to repair cars, computers, people, dams, and a host of other items.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (365, 19, N'BRTLGT1', N'Quạt cây', N'a10.jpg', 9.9900, N'The most powerful darkness-removal device offered to creatures of this world.  Rather than amplifying existing/secondary light, this handy product actually REMOVES darkness allowing you to see with your own eyes.  Must-have for nighttime operations. An affordable alternative to the Night Vision Goggles.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (409, 19, N'TNCH', N'Tiêu Sắt x Vô Tâm', N'Phim-Thiếu-Niên-Ca-Hành.jpg', 30300.0000, N'Tiêu Sở Hà')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (423, 14, N'TN', N'Thảo ngơ ngác', N's8.jpg', 30000.0000, N'Free Ship')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (367, 18, N'INCPPRCLP', N'Bàn học', N'a11.jpg', 1.4900, N'This 0. 01 oz piece of metal is the most versatile item in any respectable spy''s toolbox and will come in handy in all sorts of situations. Serves as a wily lock pick, aerodynamic projectile (used in conjunction with Multi-Purpose Rubber Band), or escape-proof finger cuffs.  Best of all, small size and pliability means it fits anywhere undetected.  Order several today!')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (368, 16, N'DNTRPR', N'Giày', N'a12.jpg', 19999.9800, N'Turn breakfast into a high-speed chase! In addition to toasting bagels and breakfast pastries, this inconspicuous toaster turns into a speedboat at the touch of a button. Boasting top speeds of 60 knots and an ultra-quiet motor, this valuable item will get you where you need to be ... fast! Best of all, Toaster Boat is easily repaired using a Versatile Paperclip or a standard butter knife. Manufacturer''s Warning: Do not submerge electrical items.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (370, 17, N'TGFDA', N'Xích đu', N'd1.jpg', 12.9900, N'Don''t leave home without your monogrammed towelette! Made from lightweight, quick-dry fabric, this piece of equipment has more uses in a spy''s day than a Swiss Army knife. The perfect all-around tool while undercover in the locker room: serves as towel, shield, disguise, sled, defensive weapon, whip and emergency food source. Handy bail gear for the Toaster Boat. Monogram included with purchase price.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (371, 18, N'WOWPEN', N'Bếp Từ', N'd2.jpg', 129.9900, N'Some spies claim this item is more powerful than a sword. After examining the titanium frame, built-in blowtorch, and Nerf dart-launcher, we tend to agree! ')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (372, 20, N'ICNCU', N'Thảo ngơ', N'thaongo2.jpg', 129.9900, N'Avoid painful and potentially devastating laser eye surgery and contact lenses. Cheaper and more effective than a visit to the optometrist, these Perfect-Vision Glasses simply slide over nose and eyes and hook on ears. Suddenly you have 20/20 vision! Glasses also function as HUD (Heads Up Display) for most European sports cars manufactured after 1992.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (373, 17, N'LKARCKT', N'Xe tăng', N'd4.jpg', 1.9900, N'Any debonair spy knows that this accoutrement is coming back in style. Flawlessly protects the pockets of your short-sleeved oxford from unsightly ink and pencil marks. But there''s more! Strap it on your back and it doubles as a rocket pack. Provides enough turbo-thrust for a 250-pound spy or a passel of small children. Maximum travel radius: 3000 miles.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (374, 15, N'DNTGCGHT', N'Coca Cola', N'd5.jpg', 999.9900, N'Don''t be caught penniless in Prague without this hot item! Instantly creates replicas of most common currencies! Simply place rocks and water in the wallet, close, open up again, and remove your legal tender!')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (375, 16, N'WRLD00', N'Đèn Pin', N'k1.jpg', 29.9900, N'No spy should be without one of these premium devices. Determine your exact location with a quick flick of the finger. Calculate destination points by spinning, closing your eyes, and stopping it with your index finger.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (376, 15, N'CITSME9', N'7Up', N'k2.jpg', 9999.9900, N'Worried about detection on your covert mission? Confuse mission-threatening forces with this cloaking device. Powerful new features include string-activated pre-programmed phrases such as "Danger! Danger!", "Reach for the sky!", and other anti-enemy expressions. Hyper-reactive karate chop action deters even the most persistent villain.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (377, 15, N'BME007', N'Pepsi', N'k3.jpg', 6.9900, N'Never leave on an undercover mission without our Identity Confusion Device! If a threatening person approaches, deploy the device and point toward the oncoming individual. The subject will fail to recognize you and let you pass unnoticed. Also works well on dogs.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (379, 17, N'SHADE01', N'Ôto mô hình', N'k4.jpg', 89.9900, N'Be safe and suave. A spy wearing this trendy article of clothing is safe from ultraviolet ray-gun attacks. Worn correctly, the Defender deflects rays from ultraviolet weapons back to the instigator. As a bonus, also offers protection against harmful solar ultraviolet rays, equivalent to SPF 50.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (378, 17, N'SQUKY1', N'Súng mô hình', N'k5.jpg', 14.9900, N'Pesky guard dogs become a spy''s best friend with the Guard Dog Pacifier. Even the most ferocious dogs suddenly act like cuddly kittens when they see this prop.  Simply hold the device in front of any threatening dogs, shaking it mildly.  For tougher canines, a quick squeeze emits an irresistible squeak that never fails to  place the dog under your control.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (382, 20, N'CHEW99', N'Thảo', N's8.jpg', 6.9900, N'Survive for up to four days in confinement with this handy item. Disguised as a common eraser, it''s really a high-calorie food bar. Stranded in hostile territory without hope of nourishment? Simply break off a small piece of the eraser and chew vigorously for at least twenty minutes. Developed by the same folks who created freeze-dried ice cream, powdered drink mix, and glow-in-the-dark shoelaces.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (402, 20, N'C00LCMB1', N'Phú', N'a2.jpg', 399.9900, N'Use the Telescoping Comb to track down anyone, anywhere! Deceptively simple, this is no normal comb. Flip the hidden switch and two telescoping lenses project forward creating a surprisingly powerful set of binoculars (50X). Night-vision add-on is available for midnight hour operations.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (384, 19, N'FF007', N'Xe đạp', N'k8.jpg', 99.9900, N'Worried that counteragents have placed listening devices in your home or office? No problem! Use our bug-sweeping wiener to check your surroundings for unwanted surveillance devices. Just wave the frankfurter around the room ... when bugs are detected, this "foot-long" beeps! Comes complete with bun, relish, mustard, and headphones for privacy.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (385, 16, N'LNGWADN', N'Mũ len', N'k9.jpg', 13.9900, N'Any agent assigned to mountain terrain should carry this ordinary-looking extension cord ... except that it''s really a rappelling rope! Pull quickly on each end to convert the electrical cord into a rope capable of safely supporting up to two agents. Comes in various sizes including Mt McKinley, Everest, and Kilimanjaro. WARNING: To prevent serious injury, be sure to disconnect from wall socket before use.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (386, 17, N'1MOR4ME', N'Súng aka', N'k10.jpg', 69.9900, N'Do your assignments have you flitting from one high society party to the next? Worried about keeping your wits about you as you mingle witih the champagne-and-caviar crowd? No matter how many drinks you''re offered, you can safely operate even the most complicated heavy machinery as long as you use our model 1MOR4ME alcohol-neutralizing coaster. Simply place the beverage glass on the patented circle to eliminate any trace of alcohol in the drink.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (387, 20, N'SQRTME1', N'Lệ rơi', N'k11.jpg', 9.9900, N'Even spies need to care for their office plants.  With this handy remote watering device, you can water your flowers as a spy should, from the comfort of your chair.  Water your plants from up to 50 feet away.  Comes with an optional aiming system that can be mounted to the top for improved accuracy.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (388, 20, N'ICUCLRLY00', N'Nhung ngu', N'k12.jpg', 59.9900, N'Traditional binoculars and night goggles can be bulky, especially for assignments in confined areas. The problem is solved with these patent-pending contact lenses, which give excellent visibility up to 100 miles. New feature: now with a night vision feature that permits you to see in complete darkness! Contacts now come in a variety of fashionable colors for coordinating with your favorite ensembles.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (389, 20, N'OPNURMIND', N'Lươn Thái Phúc', N's1.jpg', 2.9900, N'Learn to move things with your mind! Broaden your mental powers using this training device to hone telekinesis skills. Simply look at the device, concentrate, and repeat "There is no spoon" over and over.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (390, 19, N'ULOST007', N'Xe moto', N's2.jpg', 129.9900, N'With the Rubber Stamp Beacon, you''ll never get lost on your missions again. As you proceed through complicated terrain, stamp a stationary object with this device. Once an object has been stamped, the stamp''s patented ink will emit a signal that can be detected up to 153.2 miles away by the receiver embedded in the device''s case. WARNING: Do not expose ink to water.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (391, 17, N'BSUR2DUC', N'Súng đại bác', N's3.jpg', 79.9900, N'Being a spy can be dangerous work. Our patented Bulletproof Facial Tissue gives a spy confidence that any bullets in the vicinity risk-free. Unlike traditional bulletproof devices, these lightweight tissues have amazingly high tensile strength. To protect the upper body, simply place a tissue in your shirt pocket. To protect the lower body, place a tissue in your pants pocket. If you do not have any pockets, be sure to check out our Bulletproof Tape. 100 tissues per box. WARNING: Bullet must not be moving for device to successfully stop penetration.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (393, 20, N'NOBOOBOO4U', N'Duy Karry Hương', N's4.jpg', 3.9900, N'Even spies make mistakes.  Barbed wire and guard dogs pose a threat of injury for the active spy.  Use our special bandages on cuts and bruises to rapidly heal the injury.  Depending on the severity of the wound, the bandages can take between 10 to 30 minutes to completely heal the injury.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (394, 15, N'BHONST93', N'Beer', N's5.jpg', 1.9900, N'Disguised as typewriter correction fluid, this scientific truth serum forces subjects to correct anything not perfectly true. Simply place a drop of the special correction fluid on the tip of the subject''s nose. Within seconds, the suspect will automatically correct every lie. Effects from Correction Fluid last approximately 30 minutes per drop. WARNING: Discontinue use if skin appears irritated.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (396, 19, N'BPRECISE00', N'Laptop', N's6.jpg', 11.9900, N'Facing a brick wall? Stopped short at a long, sheer cliff wall?  Carry our handy lightweight calculator for just these emergencies. Quickly enter in your dilemma and the calculator spews out the best solutions to the problem.   Manufacturer Warning: Use at own risk. Suggestions may lead to adverse outcomes.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (397, 14, N'LSRPTR1', N'Humberger', N's7.jpg', 29.9900, N'Contrary to popular spy lore, not all cigars owned by spies explode! Best used during mission briefings, our Nonexplosive Cigar is really a cleverly-disguised, top-of-the-line, precision laser pointer. Make your next presentation a hit.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (399, 20, N'QLT2112', N'Yang Hồ Hải Yang', N's8.jpg', 299.9900, N'Keep your stolen Top Secret documents in a place they''ll never think to look!  This patent leather briefcase has multiple pockets to keep documents organized.  Top quality craftsmanship to last a lifetime.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (400, 15, N'THNKDKE1', N'Aquaria', N's9.jpg', 799.9900, N'Just point, and a turn of the wrist will project a hologram of you up to 100 yards away. Sneaking past guards will be child''s play when you''ve sent them on a wild goose chase. Note: Hologram adds ten pounds to your appearance.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (401, 14, N'TCKLR1', N'Bánh Bao', N'se1.jpg', 599.9900, N'Fake Moustache Translator attaches between nose and mouth to double as a language translator and identity concealer. Sophisticated electronics translate your voice into the desired language. Wriggle your nose to toggle between Spanish, English, French, and Arabic. Excellent on diplomatic missions.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (404, 14, N'JWLTRANS6', N'Bánh Mỳ', N'se2.jpg', 459.9900, N'The simple elegance of our stylish monosex earrings accents any wardrobe, but their clean lines mask the sophisticated technology within. Twist the lower half to engage a translator function that intercepts spoken words in any language and converts them to the wearer''s native tongue. Warning: do not use in conjunction with our Fake Moustache Translator product, as the resulting feedback loop makes any language sound like Pig Latin.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (406, 19, N'GRTWTCH9', N'Điện Thoại', N's3.jpg', 399.9900, N'In the tradition of famous spy movies, the Multi Purpose Watch comes with every convenience! Installed with lighter, TV, camera, schedule-organizing software, MP3 player, water purifier, spotlight, and tire pump. Special feature: Displays current date and time. Kitchen sink add-on will be available in the fall of 2001.')
INSERT [dbo].[Products] ([ProductID], [CategoryID], [ModelNumber], [ModelName], [ProductImage], [UnitCost], [Description]) VALUES (410, 18, N'NKLTY', N'Bếp Gas', N'NKLTY.jpg', 50000.0000, N'Tiểu thuyết ngôn tình')
SET IDENTITY_INSERT [dbo].[Products] OFF
SET IDENTITY_INSERT [dbo].[Reviews] ON 

INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (21, 404, N'Sarah Goodpenny', N'sg@ibuyspy.com', 5, N'Really smashing! &nbsp;Don''t know how I''d get by without them!')
INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (22, 378, N'James Bondwell', N'jb@ibuyspy.com', 3, N'Well made, but only moderately effective. &nbsp;Ouch!')
INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (25, 359, N'Tuấn', NULL, 3, N'~~~~~~~~~~~~~~')
INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (24, 355, N'James Bondwell', N'jb@ibuyspy.com', 3, N'tuyệt!!')
INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (26, 359, N'Thần', NULL, 1, N'===========')
INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (27, 358, N'Tuấn', NULL, 5, N'Xịn!!!!!!')
INSERT [dbo].[Reviews] ([ReviewID], [ProductID], [CustomerName], [CustomerEmail], [Rating], [Comments]) VALUES (28, 358, N'Tuấn', NULL, 1, N'Đẹp!!!!!')
SET IDENTITY_INSERT [dbo].[Reviews] OFF
SET IDENTITY_INSERT [dbo].[ShoppingCart] ON 

INSERT [dbo].[ShoppingCart] ([CartID], [Quantity], [ProductID], [DateCreated], [CustomerID]) VALUES (19, 12, 355, CAST(N'2020-12-03 21:41:21.707' AS DateTime), 1)
INSERT [dbo].[ShoppingCart] ([CartID], [Quantity], [ProductID], [DateCreated], [CustomerID]) VALUES (30, 3, 357, CAST(N'2020-12-05 18:43:56.923' AS DateTime), 23)
INSERT [dbo].[ShoppingCart] ([CartID], [Quantity], [ProductID], [DateCreated], [CustomerID]) VALUES (33, 1, 355, CAST(N'2020-12-05 22:35:16.420' AS DateTime), 20)
INSERT [dbo].[ShoppingCart] ([CartID], [Quantity], [ProductID], [DateCreated], [CustomerID]) VALUES (34, 1, 356, CAST(N'2020-12-05 22:35:18.557' AS DateTime), 20)
INSERT [dbo].[ShoppingCart] ([CartID], [Quantity], [ProductID], [DateCreated], [CustomerID]) VALUES (35, 1, 359, CAST(N'2020-12-05 22:35:21.220' AS DateTime), 20)
INSERT [dbo].[ShoppingCart] ([CartID], [Quantity], [ProductID], [DateCreated], [CustomerID]) VALUES (36, 1, 358, CAST(N'2020-12-05 22:35:23.487' AS DateTime), 20)
SET IDENTITY_INSERT [dbo].[ShoppingCart] OFF
/****** Object:  Index [PK_Categories]    Script Date: 12/21/2020 11:28:22 PM ******/
ALTER TABLE [dbo].[Categories] ADD  CONSTRAINT [PK_Categories] PRIMARY KEY NONCLUSTERED 
(
	[CategoryID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_Customers]    Script Date: 12/21/2020 11:28:22 PM ******/
ALTER TABLE [dbo].[Customers] ADD  CONSTRAINT [PK_Customers] PRIMARY KEY NONCLUSTERED 
(
	[CustomerID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_OrderDetails]    Script Date: 12/21/2020 11:28:22 PM ******/
ALTER TABLE [dbo].[OrderDetails] ADD  CONSTRAINT [PK_OrderDetails] PRIMARY KEY NONCLUSTERED 
(
	[OrderID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_Orders]    Script Date: 12/21/2020 11:28:22 PM ******/
ALTER TABLE [dbo].[Orders] ADD  CONSTRAINT [PK_Orders] PRIMARY KEY NONCLUSTERED 
(
	[OrderID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_Products]    Script Date: 12/21/2020 11:28:22 PM ******/
ALTER TABLE [dbo].[Products] ADD  CONSTRAINT [PK_Products] PRIMARY KEY NONCLUSTERED 
(
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [PK_Reviews]    Script Date: 12/21/2020 11:28:22 PM ******/
ALTER TABLE [dbo].[Reviews] ADD  CONSTRAINT [PK_Reviews] PRIMARY KEY NONCLUSTERED 
(
	[ReviewID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_ShoppingCart]    Script Date: 12/21/2020 11:28:22 PM ******/
CREATE NONCLUSTERED INDEX [IX_ShoppingCart] ON [dbo].[ShoppingCart]
(
	[CartID] ASC,
	[ProductID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH NOCHECK ADD  CONSTRAINT [FK_OrderDetails_Orders] FOREIGN KEY([OrderID])
REFERENCES [dbo].[Orders] ([OrderID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Orders]
GO
ALTER TABLE [dbo].[OrderDetails]  WITH NOCHECK ADD  CONSTRAINT [FK_OrderDetails_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[OrderDetails] CHECK CONSTRAINT [FK_OrderDetails_Products]
GO
ALTER TABLE [dbo].[Orders]  WITH NOCHECK ADD  CONSTRAINT [FK_Orders_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Orders] CHECK CONSTRAINT [FK_Orders_Customers]
GO
ALTER TABLE [dbo].[Products]  WITH CHECK ADD  CONSTRAINT [FK_Products_Categories] FOREIGN KEY([CategoryID])
REFERENCES [dbo].[Categories] ([CategoryID])
GO
ALTER TABLE [dbo].[Products] CHECK CONSTRAINT [FK_Products_Categories]
GO
ALTER TABLE [dbo].[Reviews]  WITH NOCHECK ADD  CONSTRAINT [FK_Reviews_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
NOT FOR REPLICATION 
GO
ALTER TABLE [dbo].[Reviews] CHECK CONSTRAINT [FK_Reviews_Products]
GO
ALTER TABLE [dbo].[ShoppingCart]  WITH CHECK ADD  CONSTRAINT [FK_ShoppingCart_Customers] FOREIGN KEY([CustomerID])
REFERENCES [dbo].[Customers] ([CustomerID])
GO
ALTER TABLE [dbo].[ShoppingCart] CHECK CONSTRAINT [FK_ShoppingCart_Customers]
GO
ALTER TABLE [dbo].[ShoppingCart]  WITH CHECK ADD  CONSTRAINT [FK_ShoppingCart_Products] FOREIGN KEY([ProductID])
REFERENCES [dbo].[Products] ([ProductID])
GO
ALTER TABLE [dbo].[ShoppingCart] CHECK CONSTRAINT [FK_ShoppingCart_Products]
GO
USE [master]
GO
ALTER DATABASE [dbnew] SET  READ_WRITE 
GO
