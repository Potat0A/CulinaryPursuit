ALTER TABLE dbo.Restaurants
    ADD
        Rating DECIMAL(3,2) NOT NULL CONSTRAINT DF_Restaurants_Rating DEFAULT 0,
    TotalReviews INT NOT NULL CONSTRAINT DF_Restaurants_TotalReviews DEFAULT 0;
