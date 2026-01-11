INSERT INTO dbo.MenuItems
(RestaurantID, Name, Description, Price, ImagePath, Category,
 IsAvailable, IsVegetarian, IsVegan, IsHalal, SpicyLevel, PrepTime, CreatedDate)
VALUES
    (@RestaurantID, @Name, @Description, @Price, @ImagePath, @Category,
     @IsAvailable, @IsVegetarian, @IsVegan, @IsHalal, @SpicyLevel, @PrepTime, GETDATE());
