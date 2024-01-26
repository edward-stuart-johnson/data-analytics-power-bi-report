# Data Analytics Power BI Report

In this fictious scenario I have recently been approached by a medium-sized international retailer who is keen on elevating their business intelligence practices. With operations spanning across different regions, they've accumulated large amounts of sales from disparate sources over the years.

Recognizing the value of this data, they aim to transform it into actionable insights for better decision-making. My goal is to use Microsoft Power BI to design a comprehensive Quarterly report. This will involve extracting and transforming data from various origins, designing a robust data model rooted in a star-based schema, and then constructing a multi-page report.

The report will present a high-level business summary tailored for C-suite executives, and also give insights into their highest value customers segmented by sales region, provide a detailed analysis of top-performing products categorised by type against their sales targets, and a visually appealing map visual that spotlights the performance metrics of their retail outlets across different territories.

## Data Loading and Preparation

I connected to an Azure SQL database, a Microsoft Azure Storage Account, and web-hosted CSV files to import useful data for this dataset. I cleaned and organized the data by removing irrelevant columns, splitting date-time details, and ensuring data consistency. I also renamed columns to fit Power BI conventions.

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

## Creating the Data Model

### Generating the date table

I created a date table running from the start of the year containing the earliest date in the Orders['Order Date'] column to the end of the year containing the latest date in the Orders['Shipping Date'] column usign the DAX formula:

Dates = CALENDAR(
STARTOFYEAR(Orders[Order Date]), 
ENDOFYEAR(Orders[Shipping Date])
)

Day Of Week = WEEKDAY(Dates[Date],2)

Month = MONTH(Dates[Date])

Month Name = FORMAT(DATE(1, Dates[Month], 1), "MMMM")

Quarter = QUARTER(Dates[Date])

Year = YEAR(Dates[Date])

Start of Year = STARTOFYEAR(Dates[Date])

Start of Quarter = STARTOFQUARTER(Dates[Date])

Start of Month = STARTOFMONTH(Dates[Date])

Start of Week = Dates[Date] - WEEKDAY(Dates[Date],2) + 1

### Building the Star Schema data model

I created relationships between the tables to form a star schema. The relationships are as follows:

Orders[product_code] to Products[product_code]
Orders[Store Code] to Stores[store code]
Orders[User ID] to Customers[User UUID]
Orders[Order Date] to Date[date]
Orders[Shipping Date] to Date[date]

I ensured that the relationship between Orders[Order Date] and Date[date] is the active relationship, and that all relationships are one-to-many, with a single filter direction from the one side to the many side

### Creating a Measures table

Creating a separate table for measures is a best practice that will help keep the data model organized and easy to navigate. 

I created a new table in the data Model View with Power Query Editor. It is generally better to use the latter approach, as it makes the measures table visible in the Query Editor, which is useful for debugging and troubleshooting.

### Create key measures

I created some of the key measures that will be used in the report. These give me a starting point for building the analysis:

I created a measure called Total Orders that counts the number of orders in the Orders table:

Total Orders = COUNTROWS(Orders)

I created a measure called Total Revenue that multiplies the Orders[Product Quantity] column by the Products[Sale Price] column for each row, and then sums the result:

Total Revenue = SUMX(Orders, Orders[Product Quantity] * RELATED(Products[Sale Price]))

I created a measure called Total Profit which performs the following calculation: For each row, subtract the Products[Cost_Price] from the Products[Sale_Price], and then multiply the result by the Orders[Product Quantity]. then, it sums the result for all rows:

Total Profit = SUMX(Orders, (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])) * Orders[Product Quantity])

I created a measure called Total Customers that counts the number of unique customers in the Orders table:

Total Customers = DISTINCTCOUNT(Orders[User ID])

I created a measure called Total Quantity that counts the number of items sold in the Orders table:

Total Quantity = SUM(Orders[Product Quantity]) 

I created a measure called Profit YTD that calculates the total profit for the current year:

Profit YTD = TOTALYTD(SUMX(Orders, (RELATED(Products[Sale Price]) - RELATED(Products[Cost Price])) * Orders[Product Quantity]), Orders[Order Date])

I created a measure called Revenue YTD that calculates the total revenue for the current year:

Revenue YTD = TOTALYTD(SUMX(Orders, RELATED(Products[Sale Price]) * Orders[Product Quantity]), Orders[Order Date])


### Create Date and Georgraphy hierarchies

Hierarchies allow me to drill down into the data and perform granular analysis within the report. I created two hierarchies in this task: one for dates, to facilitate drill-down in my line charts, and one for geography, to allow me to filter the data by region, country and province/state.

I created a date hierarchy using the following levels:

Start of Year

Start of Quarter

Start of Month

Start of Week

Date

I created a new calculated column in the Stores table called Country that creates a full country name for each row, based on the Stores[Country Code] column, according to the following scheme:
GB : United Kingdom
US : United States
DE : Germany

Here is the DAX language formula:

Country = SWITCH([Country Code], 
"GB", "United Kingdom",
"US", "United States",
"DE", "Germany")

In addition to the country hierarchy, it can sometimes be helpful to have a full geography column, as in some cases this makes mapping more accurate. I created a new calculated column in the Stores table called Geography that creates a full geography name for each row, based on the Stores[Country Region], and Stores[Country] columns, separated by a comma and a space:

Geography = CONCATENATE(CONCATENATE(Stores[Country Region], ", "), Stores[Country])

I ensured that the following columns have the correct data category assigned, as follows:

World Region : Continent

Country : Country

Country Region : State or Province

I created a Geography hierarchy using the following levels:

World Region

Country

Country Region

![](Data_Model_Screenshot.png)

## Building the Customer Detail Page

I created a report page focussed on custoemr-level analysis.

I created headline card visuals: I created two rectangles as the backgrounds for the card visuals and added a card visual for the [Total Customers] measure I created earlier and renamed the field Unique Customers.

I created a new measure in my Measures Table called [Revenue per Customer], which is the [Total Revenue] divided by the [Total Customers]:

Revenue per Customer = DIVIDE([Total Revenue], [Total Customers])

I added a card visual for the [Revenue per Customer] measure.

I created summary charts: I added a Donut Chart visual showing the total customers for each country, using the Users[Country] column to filter the [Total Customers] measure:

![](donut_chart_filters_screenshot.png)

I added a Column Chart visual showing the number of customers who purchased each product category, using the Products[Category] column to filter the [Total Customers] measure:

![](column_chart_setup_screenshot.png)

I added a Line Chart visual to the top of the page. It shows [Total Customers] on the Y axis, and uses the created Date Hierarchy for the X axis. Users area allowed to drill down to the month level, but not to weeks or individual dates.

![](line_chart_setup_screenshot.png)

I added a trend line, and a forecast for the next 10 periods with a 95% confidence interval:

![](line_chart_forecast_setup_screenshot.png)

I created a new table which displays the top 20 customers, filtered by revenue. The table shows each customer's full name, revenue, and number of orders.

![](top_20_customers_filters_screenshot.png)

I added conditional formatting to the revenue column, to display data bars for the revenue values.

![](top_20_customers_filters_and_conditional_formatting_screenshot.png)

I created  a set of three card visuals that provide insights into the top customer by revenue. They display the top customer's name, the number of orders made by the customer, and the total revenue generated by the customer.

I added a date slicer to allow users to filter the page by year, using the "between" slicer-style.

![](Customer_Detail_Page_Screenshot.png)

## Creating an Executive Summary Page

I created a page to give an overview of the company's performance as a whole, so that C-suite executives and quickly get insights and check otucomes against key targets. 

I created cards visuals for my Total Revenue, Total Orders and Total Profit measures. I used the Format > Callout Value pane to ensure no more than 2 decimal places in the case of the revenue and profit cards, and only 1 decimal place in the case of the Total Orders measure.

I added a revneue trendign line chart by copying the line graph from my Customer Detail page, and change the Y-axis to Total Revenue.

I added a pair of donut charts, showing Total Revenue broken down by Store[Country] and Store[Store Type] respectively.

I added  a bar chart showing number of orders by product category. I copied the Total Customers by Product Category donut chart from the Customer Detail page

I went to the visual's "Build a visual" pane to change the visual type to Clustered bar chart

I changed  the X-axis field from Total Customers to Total Orders

With the Format pane open, I clicked on one of the bars to bring up the Colors tab, and sleeced a colour from my chsoen theme.

###  KPI Visuals

I created KPIs for Quarterly Revenue, Orders and Profit. 

I created a set of new measures for the quarterly targets:

Previous Quarter Profit

Previous Quarter Revenue

Previous Quarter Orders

Target Profit, Revenue, and Orders, equal to 5% growth in each measure compared to the previous quarter e.g.

  Target Profit = 1.05 * [Previous Quarter Profit]

I was then able to create a  KPI visual for the revenue:

The Value field is Total Revenue

The Trend Axis is Start of Quarter

The Target is Target Revenue

In the Format pane, I set the Trend Axis to On, expand the associated tab, and set the values as follows:

Direction : High is Good
Bad Colour : red
Transparency : 15%

I formatted the Callout Value so that it only shows to 1 decimal place

I duplicated the card two more times, and set the appropriate values for the Profit and Orders cards.

![](executive_summary_page_screenshot.png)

## Product Detail Page

I created a table of Top 10 Products ranked by Total Orders.

![](slicer_bar_closed_screenshot.png)

![](slicer_bar_open_screenshot.png)
