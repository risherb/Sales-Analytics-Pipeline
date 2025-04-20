# MongoDB integration with R Studio: Data Analysis Pipeline
# This script demonstrates a complete workflow for connecting R with MongoDB
# It includes data insertion, querying, analysis, and visualization

# Install required packages if not already installed
if (!requireNamespace("mongolite", quietly = TRUE)) install.packages("mongolite")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")
if (!requireNamespace("tibble", quietly = TRUE)) install.packages("tibble")
if (!requireNamespace("tidyr", quietly = TRUE)) install.packages("tidyr")

# Load libraries
library(mongolite)
library(dplyr)
library(ggplot2)
library(jsonlite)
library(tibble)
library(tidyr)

# Connection parameters
connection_string <- "mongodb://localhost:27017/"
db_name <- "sales_analytics"
collection_name <- "product_sales"

# Function to connect to MongoDB
connect_to_mongodb <- function(collection, db, conn_string) {
  mongo_collection <- mongo(collection = collection, 
                            db = db, 
                            url = conn_string)
  return(mongo_collection)
}

# Connect to MongoDB collection
sales_collection <- connect_to_mongodb(collection_name, db_name, connection_string)

# Check if collection exists and create sample data if it doesn't
if (sales_collection$count() == 0) {
  cat("Collection is empty. Generating sample sales data...\n")
  
  # Generate sample sales data
  set.seed(123)
  product_categories <- c("Electronics", "Clothing", "Home", "Sports", "Books")
  regions <- c("North", "South", "East", "West", "Central")
  
  # Create sample data
  sample_data <- tibble(
    product_id = paste0("PROD", 1:500),
    product_name = paste("Product", 1:500),
    category = sample(product_categories, 500, replace = TRUE),
    price = round(runif(500, 10, 500), 2),
    quantity_sold = sample(1:100, 500, replace = TRUE),
    region = sample(regions, 500, replace = TRUE),
    sale_date = as.Date("2023-01-01") + sample(0:365, 500, replace = TRUE)
  ) %>%
    mutate(
      total_revenue = price * quantity_sold,
      month = format(sale_date, "%m"),
      quarter = paste0("Q", ceiling(as.numeric(month)/3)),
      year = format(sale_date, "%Y")
    )
  
  # Convert to list format for MongoDB
  data_list <- jsonlite::fromJSON(jsonlite::toJSON(sample_data, auto_unbox = TRUE))
  
  # Insert data into MongoDB
  sales_collection$insert(data_list)
  cat("Sample data inserted successfully!\n")
} else {
  cat("Collection already exists with data.\n")
}

# Function to perform basic data analysis
analyze_sales_data <- function(collection) {
  # Retrieve all data
  all_data <- collection$find('{}')
  
  # Display basic statistics
  cat("\n=== Sales Data Analysis ===\n")
  cat("Total number of records:", nrow(all_data), "\n")
  cat("Total revenue:", sum(all_data$total_revenue), "\n")
  cat("Average price:", mean(all_data$price), "\n")
  cat("Average quantity sold:", mean(all_data$quantity_sold), "\n")
  
  # Category analysis
  cat("\n=== Sales by Category ===\n")
  category_summary <- all_data %>%
    group_by(category) %>%
    summarize(
      total_sales = sum(total_revenue),
      avg_price = mean(price),
      total_quantity = sum(quantity_sold)
    ) %>%
    arrange(desc(total_sales))
  
  print(category_summary)
  
  # Regional analysis
  cat("\n=== Sales by Region ===\n")
  region_summary <- all_data %>%
    group_by(region) %>%
    summarize(
      total_sales = sum(total_revenue),
      avg_quantity = mean(quantity_sold)
    ) %>%
    arrange(desc(total_sales))
  
  print(region_summary)
  
  # Time-based analysis
  cat("\n=== Sales by Quarter ===\n")
  quarter_summary <- all_data %>%
    group_by(quarter) %>%
    summarize(
      total_sales = sum(total_revenue),
      avg_quantity = mean(quantity_sold)
    ) %>%
    arrange(quarter)
  
  print(quarter_summary)
  
  # Return the data for plotting
  return(list(
    all_data = all_data,
    category_summary = category_summary,
    region_summary = region_summary,
    quarter_summary = quarter_summary
  ))
}

# Function to create visualizations
create_visualizations <- function(analysis_data) {
  # Plot 1: Sales by Category
  cat("\nCreating visualizations...\n")
  
  p1 <- ggplot(analysis_data$category_summary, aes(x = reorder(category, -total_sales), y = total_sales)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    theme_minimal() +
    labs(title = "Total Revenue by Category",
         x = "Category",
         y = "Total Revenue") +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  print(p1)
  
  # Plot 2: Regional Sales Distribution
  p2 <- ggplot(analysis_data$region_summary, aes(x = reorder(region, -total_sales), y = total_sales)) +
    geom_bar(stat = "identity", fill = "coral") +
    theme_minimal() +
    labs(title = "Sales Distribution by Region",
         x = "Region",
         y = "Total Sales")
  
  print(p2)
  
  # Plot 3: Sales trend by quarter
  p3 <- ggplot(analysis_data$quarter_summary, aes(x = quarter, y = total_sales, group = 1)) +
    geom_line(color = "darkgreen", size = 1) +
    geom_point(color = "darkgreen", size = 3) +
    theme_minimal() +
    labs(title = "Sales Trend by Quarter",
         x = "Quarter",
         y = "Total Sales")
  
  print(p3)
  
  # Return the plots
  return(list(p1 = p1, p2 = p2, p3 = p3))
}

# Function to demonstrate MongoDB queries
run_mongodb_queries <- function(collection) {
  cat("\n=== MongoDB Query Examples ===\n")
  
  # Example 1: Find top 5 products by revenue
  cat("\nTop 5 products by revenue:\n")
  top_products <- collection$find(
    '{}',
    fields = '{"product_name": 1, "total_revenue": 1, "_id": 0}',
    sort = '{"total_revenue": -1}',
    limit = 5
  )
  print(top_products)
  
  # Example 2: Count products by category
  cat("\nProduct count by category:\n")
  category_counts <- collection$aggregate('[
    {"$group": {"_id": "$category", "count": {"$sum": 1}}},
    {"$sort": {"count": -1}}
  ]')
  print(category_counts)
  
  # Example 3: Average price by region
  cat("\nAverage price by region:\n")
  avg_price_by_region <- collection$aggregate('[
    {"$group": {"_id": "$region", "avg_price": {"$avg": "$price"}}},
    {"$sort": {"avg_price": -1}}
  ]')
  print(avg_price_by_region)
  
  # Example 4: Total revenue by month
  cat("\nTotal revenue by month:\n")
  monthly_revenue <- collection$aggregate('[
    {"$group": {"_id": "$month", "total_revenue": {"$sum": "$total_revenue"}}},
    {"$sort": {"_id": 1}}
  ]')
  print(monthly_revenue)
}

# Function to demonstrate advanced MongoDB features
advanced_mongodb_features <- function(collection) {
  cat("\n=== Advanced MongoDB Features ===\n")
  
  # Example 1: Create an index to improve query performance
  cat("\nCreating index on category and region fields...\n")
  collection$index(add = '{"category": 1, "region": 1}')
  
  # List all indexes
  cat("\nIndexes in the collection:\n")
  indexes <- collection$index()
  print(indexes)
  
  # Example 2: Complex aggregation pipeline - Sales performance matrix
  cat("\nSales performance matrix (category by region):\n")
  category_region_matrix <- collection$aggregate('[
    {"$group": {
      "_id": {"category": "$category", "region": "$region"}, 
      "total_sales": {"$sum": "$total_revenue"},
      "avg_quantity": {"$avg": "$quantity_sold"}
    }},
    {"$sort": {"total_sales": -1}},
    {"$limit": 10}
  ]')
  print(category_region_matrix)
  
  # Example 3: Using MongoDB filters
  cat("\nHigh-value items (price > 300) in Electronics category:\n")
  high_value_electronics <- collection$find(
    '{"category": "Electronics", "price": {"$gt": 300}}',
    fields = '{"product_name": 1, "price": 1, "_id": 0}'
  )
  print(high_value_electronics)
}

# Function to update data in MongoDB
update_mongodb_data <- function(collection) {
  cat("\n=== Updating Data in MongoDB ===\n")
  
  # Example 1: Apply a 10% discount to all Electronics items
  cat("\nApplying 10% discount to all Electronics items...\n")
  result <- collection$update(
    query = '{"category": "Electronics"}',
    update = '{"$mul": {"price": 0.9}}',
    multiple = TRUE
  )
  cat("Updated", result$nModified, "products\n")
  
  # Example 2: Recalculate total revenue after price update
  cat("\nRecalculating total_revenue after price updates...\n")
  
  # First, get all records with updated prices
  updated_records <- collection$find('{"category": "Electronics"}')
  
  # Update each record's total_revenue based on new price
  for (i in 1:nrow(updated_records)) {
    record <- updated_records[i,]
    new_total_revenue <- record$price * record$quantity_sold
    
    collection$update(
      query = paste0('{"_id": "', record$`_id`, '"}'),
      update = paste0('{"$set": {"total_revenue": ', new_total_revenue, '}}')
    )
  }
  
  cat("Total revenue recalculated for", nrow(updated_records), "products\n")
}

# Main function to run the entire workflow
run_mongodb_r_workflow <- function() {
  cat("=== MongoDB-R Integration Workflow ===\n")
  
  # Step 1: Run data analysis
  analysis_results <- analyze_sales_data(sales_collection)
  
  # Step 2: Create visualizations
  plots <- create_visualizations(analysis_results)
  
  # Step 3: Run MongoDB queries
  run_mongodb_queries(sales_collection)
  
  # Step 4: Demonstrate advanced MongoDB features
  advanced_mongodb_features(sales_collection)
  
  # Step 5: Update data in MongoDB
  update_mongodb_data(sales_collection)
  
  # Step 6: Re-analyze data after updates
  cat("\n=== Re-analyzing data after updates ===\n")
  updated_analysis <- analyze_sales_data(sales_collection)
  
  # Export updated data to CSV
  export_data <- sales_collection$find('{}')
  csv_filename <- "sales_data_export.csv"
  write.csv(export_data, csv_filename, row.names = FALSE)
  cat("\nData exported to", csv_filename, "\n")
  
  cat("\nWorkflow completed successfully!\n")
}

# Run the entire workflow
run_mongodb_r_workflow()

# Example of how to drop the collection if needed (commented out by default)
# sales_collection$drop()