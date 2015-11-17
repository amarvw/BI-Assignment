
The order of looking at the files should be as follows :

1.  **Folder Name : Database and Schema creation scripts :**
    * The file contains script to create the DB named, "HQ Assignment" and the two schemans "primary_data" and "bi_data"
    
	
2.  **Folder Name : primary_data-table-scripts :**
    * This folder has scripts along with all the keys and indexes
    * fileNameAndPaths : This table is made to make the import process of files more dynamic. No need to hard code the path.
    * fx_rate : The table creation script for the fx_rate, in the primary_data schema with all the required keys and indexes
    * lst_currency : The table creation script for the lst_currency, in the primary_data schema with all the required keys  	      and indexes
    * offer : The table creation script for the offer, in the primary_data schema with all the required keys and indexes
	
3.  **Folder Name : bi_data-table-scripts :**
    * hotel_offers : The table script as per the requirement 
    * valid_offers : The table script as per the requirement
    * offer_Outliers : The table used in the data cleaning process. The table has "comment" column, which tells about the 
      data issue and outliers.

4.  **Folder Name : Stored-Procedures-to-import_files :**
     * fx_rate	 : the stored procedure to import the fx_rate file on a daily basis
     * lst_currency : the stored procedure to import the lst_currency file on a daily basis

	**_There is no procedure to import the offer.csv file. The reason for the same being is that,
	importing a file on size 777 MB, I would not suggest a T-SQL Bulk Insert method. I would prefer
	a SSIS approach. Let me know, would give the SSIS appraoch as well_**
	
5.  **Folder Name : Stored-Procedures-to-populate-bi_data-tables:**
     * insert_into_hotel_offers : Stored procedure with all the required comments and logic to populate the hotel_offers 		table
     * insert_into_valid_offers : Stored procedure to populate the valid_offers tables with all the required comments and           logic
