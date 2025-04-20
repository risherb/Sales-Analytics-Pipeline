# MongoDB + R Studio Integration

A simple project that connects MongoDB with R for sales data analysis. This script lets you store data in MongoDB and analyze it with R's statistical tools.

## What's This?

This project is a single R script that does the following:

- Connects R Studio to MongoDB
- Creates sample sales data if your MongoDB collection is empty
- Analyzes sales data by category, region, and time
- Makes charts to visualize the data
- Shows how to run different types of MongoDB queries
- Demonstrates data updates and exports

## Getting Started

### What You Need

- R Studio installed on your computer
- MongoDB running on localhost:27017
- Internet connection (for package installation)

### How to Run

1. Copy the entire R script to R Studio
2. Run it - that's it!

The script will:
- Install any packages it needs
- Connect to your local MongoDB 
- Create a database called `sales_analytics` with a collection called `product_sales`
- Run the analysis and show you the results

## What You'll See

When you run the script, you'll get:

- Basic stats about the sales data
- Breakdown of sales by product category
- Regional sales analysis
- Quarterly and monthly trends
- Three visualizations (charts)
- Examples of different MongoDB queries

## Customizing

Want to use your own data? Just change these variables at the top:

```r
connection_string <- "mongodb://localhost:27017/"
db_name <- "sales_analytics"
collection_name <- "product_sales"
```

## Features

- **Data Generation**: Creates realistic sales data if none exists
- **Analysis**: Breaks down sales by category, region, and time
- **Visualization**: Makes charts showing sales trends
- **MongoDB Operations**: Shows how to query, update, and index data
- **Export**: Saves data to CSV file

## Common Issues

- If MongoDB isn't running, you'll get a connection error
- If packages don't install automatically, try installing them manually
- If you already have data in the collection, the script will use that instead of creating new data

## Next Steps

- Add your own data to MongoDB
- Modify the analysis for your specific needs
- Create new visualizations
- Set up scheduled runs to keep your analysis up to date

---
