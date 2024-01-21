# data-analytics-power-bi-report937

## Data Loading and Preparation

I connected to an Azure SQL database, a Microsfot Azure Storage Account, and web-hosted CSV files to import useful data for this dataset. I cleaned and organized the data by removing irrelevant columns, splitting date-time details, and ensuring data consistency. I also renamed columns to fit Power BI conventions.

I connected to the Azure SQL Database and imported the orders_powerbi table using the Import option in Power BI. 

The Orders table is the main fact table. It contains information about each order, including the order and shipping dates, the customer, store and product IDs for associating with dimension tables, and the amount of each product ordered. Each order in this table consists of an order of a single product type, so there is only one product code per order. 

I used the Power Query Editor and delete the column named [Card Number] to ensure data privacy.

I used the Split Column feature to separate the [Order Date] and [Shipping Date] columns into two distinct columns each: one for the date and another for the time

I filtered out and removed any rows where the [Order Date] column has missing or null values to maintain data integrity

I renamed the columns in my dataset to align with Power BI naming conventions (e.g. captilaisign first letters, using spaces instead of underscores), ensuring consistency and clarity in your report

I downloaded the Products.csv file  and then used Power BI's Get Data option to import the file into my project.

The Products table contains information about each product sold by the company, including the product code, name, category, cost price, sale price, and weight.

In the Data view, I used the Remove Duplicates function on the product_code column to ensure each product code is unique.

In Power Query Editor, I used the Column From Examples feature to generate two new columns from the weight column - one for the weight values and another for the units (e.g. kg, g, ml). 

For the newly created units column, replaced any blank entries with kg using the Replace Values feature.
I converted the data type of the values column to a decimal number
I replaced error values with the number 1

In the Data view, I created a new calculated column, such that if the unit in the units column is not kg, divide the corresponding value in the values column by 1000 to convert it to kilograms.

I returned to the Power Query Editor and delete any columns that are no longer needed.

I renamed the columns in your dataset to match Power BI naming conventions, ensuring a consistent and clear presentation in my report.

I used Power BI's Get Data option to connect to Azure Blob Storage and import the Stores table into my project. The Stores table contains information about each store, including the store code, store type, country, region, and address.

I downloaded the Customers.zip file - inside the zip file is a folder containing three CSV files, each with the same column format, one for each of the regions in which the company operates.

I used the Get Data option (using the Folder data connector) in Power BI to import the Customers folder into my project. I selected Combine and Transform to import the data; Power BI automatically appended the three files into one query.

Once the data are loaded into Power BI, I create a Full Name column by combining the [First Name] and [Last Name] columns using the DAX language's CONCATENATE function.

I delete any obviously unused columns (eg. index columns) and renamed the remaining columns to align with Power BI naming conventions.

