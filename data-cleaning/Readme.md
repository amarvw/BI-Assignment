
##The Data Cleaning process :##

**From what I have seen in the offer.csv table, I have written the stored procedure
to highlight such records. Also the table [bi_data].[offer_Outliers] has all the required data.
The comment column tells about the what the issue is with the particular record.**

Based on the data, the issues which I have found are as follow :

1. The selling price was NULL. Need to remove such records  'SELLING PRICE NULL'
2. For some of the records the offer_valid_from was greater than the offer_valid_to date , 'OFFER DATE ISSUE'
3. When I checked with the DATEDIFF between the offer_valid_from and offer_valid_to, there were some records
   where the DATEDIFF was more than 14. The reason I stress on 14 is, till 14 days difference, we have plenty of records.
   But then hardly one of each with DATEDIFF as 35 or more. (This was after removing the default SQL server dates of 1900 and      2999)
   
   Used Standard Deviation , and records having deviation less than -10 and higher than +10 were flagged. The upper and lower
   values can be changed. The comment is : 'DATEDIFF TOO HIGH'
4. Found some records where the currency_id does not exists in the lst_currency table, flagged them off as 'NO CURRENCY ID'
5. Found some cases, where for the same hotel_id, offer_valid_from and offer_valid_to, we found multiple records
   having different valid_offer_flag flag, flagged such records as 'AMBIGUOUS RECORDS'
6. In the **bi_data.getHotelPriceOutliers** procedure, we check for outliers when the change of selling_price for the same
   hotel_id ,currency_id (so that no conversion is needed) between the numberOfdays passed 
   * The parameters
  
