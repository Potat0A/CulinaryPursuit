ALTER TABLE dbo.Reviews
    ADD CONSTRAINT FK_Reviews_Restaurants
        FOREIGN KEY (RestaurantID)
            REFERENCES dbo.Restaurants(RestaurantID)
            ON DELETE CASCADE;

ALTER TABLE dbo.Reviews
    ADD CONSTRAINT FK_Reviews_Customers
        FOREIGN KEY (CustomerID)
            REFERENCES dbo.Customers(CustomerID)
            ON DELETE CASCADE;
