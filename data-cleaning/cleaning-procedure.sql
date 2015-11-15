


CREATE PROCEDURE bi_data.cleaning_procedure
AS 
BEGIN

/*

outliers found in the data, primary_data.offer table

1. The selling price is NULL, cannot be
2. The valid_offer_from is lesser than the valid_offer_to, not possible
3. The dateDiff between the valid_offer_from and valid_offer_to is high, when majority are around 14
4. Arbitrarily offer_valid_from and offer_valid_to values
5. for the same hotel_id,valid_offer_from and valid_offer_to records, lead to ambiguity

*/

SET NOCOUNT ON;

DECLARE @stdev FLOAT

/*	
	find out if the standard deviation for the difference between the 
	offer_valid_from and offer_valid_to dates	
*/

SELECT @stdev = STDEVP(DATEDIFF(DAY,offer_valid_from, [offer_valid_to]))
FROM primary_data.offer (NOLOCK)
WHERE offer_valid_from < offer_valid_to
	AND offer_valid_from <> '1900-01-01 00:00:00.000'
	AND offer_valid_to <> '2999-12-31 00:00:00.000'


/*
find all records where the selling price is NULL
*/

INSERT INTO [bi_data].[offer_Outliers]
(	   [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,[comment]
)
SELECT [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,'SELLING PRICE NULL' AS [comment]
FROM primary_data.offer (NOLOCK)
WHERE sellings_price IS NULL


/*
find all records where the offer_valid_from is greater than the offer_valid_to date
*/

INSERT INTO [bi_data].[offer_Outliers]
(	   [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,[comment]
)
SELECT  [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
	  ,'OFFER DATE ISSUE' AS [comment]
FROM primary_data.offer (NOLOCK)
WHERE offer_valid_from > offer_valid_to						

/*
by using the standard deviation, we can find the records
who are not between the -10 and 10 (reason for the -10 and 10 is
HotelQuickly as of now gives offers till 7 days in advance
*/

INSERT INTO [bi_data].[offer_Outliers]
(	   [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,[comment]
)
SELECT  [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
	  ,'DATEDIFF TOO HIGH' AS [comment]
FROM primary_data.offer (NOLOCK)
WHERE offer_valid_from < offer_valid_to
AND offer_valid_from <> '1900-01-01 00:00:00.000'											-- skipping the default values
AND offer_valid_to <> '2999-12-31 00:00:00.000'												-- skipping the default values
AND (@stdev - (DATEDIFF(DAY,offer_valid_from, [offer_valid_to]))) NOT BETWEEN -10 AND 10

/*
records having no currency_id reference from primary_data.lst_currency
*/

INSERT INTO [bi_data].[offer_Outliers]
(	   [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,[comment]
)
SELECT  offer.[id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,'NO CURRENCY ID'
FROM primary_data.offer AS offer (NOLOCk)
LEFT OUTER JOIN primary_data.lst_currency AS curr (NOLOCK)
	ON ISNULL(offer.currency_id,'0') = ISNULL(curr.id,'0')						-- since the currency id is NULL,giving it a default value of 0 when NULL
WHERE curr.id IS NULL


/*
case when for the same hotel_id, valid_offer_from and valid_offer_to, we have multiple records
for different valid_offer_flag. This situation can also lead to wrong results in the bi_data.hotel_offers table
*/

INSERT INTO [bi_data].[offer_Outliers]
(	     [id]
      ,[hotel_id]
      ,[currency_id]
      ,[source_system_code]
      ,[available_cnt]
      ,[sellings_price]
      ,[checkin_date]
      ,[checkout_date]
      ,[valid_offer_flag]
      ,[offer_valid_from]
      ,[offer_valid_to]
      ,[breakfast_included_flag]
      ,[insert_datetime]
      ,[comment]
)
SELECT DISTINCT priTable.[id]														/* 
																					                 DISTINT, because the the inner join
																					                 in the query will give a cross product
																				              	 */
	 ,priTable.[hotel_id]
	 ,priTable.[currency_id]
	 ,priTable.[source_system_code]
	 ,priTable.[available_cnt]
	 ,priTable.[sellings_price]
	 ,priTable.[checkin_date]
	 ,priTable.[checkout_date]
	 ,priTable.[valid_offer_flag]
	 ,priTable.[offer_valid_from]
	 ,priTable.[offer_valid_to]
	 ,priTable.[breakfast_included_flag]
	 ,priTable.[insert_datetime]
	 ,'AMBIGUOUS RECORDS' AS [comment]
FROM primary_data.offer (NOLOCK) AS priTable 
INNER JOIN (
			SELECT hotel_id,offer_valid_from,offer_valid_to,COUNT(DISTINCT valid_offer_flag) AS count_of_records			
			FROM primary_data.offer (NOLOCK)
			GROUP BY hotel_id,offer_valid_from,offer_valid_to										-- grouping on the ambiguity condition
			HAVING COUNT(DISTINCT valid_offer_flag) > 1
		  )  AS groupTable
ON priTable.hotel_id = groupTable.hotel_id
AND priTable.offer_valid_to = groupTable.offer_valid_to
AND priTable.offer_valid_from = groupTable.offer_valid_from
WHERE priTable.offer_valid_from < priTable.offer_valid_to
AND priTable.offer_valid_from <> '1900-01-01 00:00:00.000'											-- skipping the default values
AND priTable.offer_valid_to <> '2999-12-31 00:00:00.000'	


/*
finding outliers in the bi_data.hotel_offers data.
The reason: wrong data in the primary_data.offer would lead to ambiguous results.
For example : from the same hotel_id,date and hour combination, we may find multiple results (offers), rather confusing

NOTE:The amiguous records have been pushed to the bi_data.hotel_offers, the cleaning was 2nd exercise
	 , can be found by the below query

SELECT hotel_id,[date],[hour] ,COUNT(*)
FROM bi_data.hotel_offers (NOLOCK)
GROUP BY hotel_id,[date],[hour] 
HAVING COUNT(*) > 1		
*/


END
















