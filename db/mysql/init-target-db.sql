-- MySQL initialization script for target database
-- This will create the target schema for ETL data from PostgreSQL

-- Create database if not exists (though it should be created by environment variables)
CREATE DATABASE IF NOT EXISTS targetdb;
USE targetdb;

-- Create target tables with similar structure to PostgreSQL source
-- Note: MySQL syntax differences from PostgreSQL

CREATE TABLE IF NOT EXISTS dim_customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'USA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    etl_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2),
    supplier_id INT,
    description TEXT,
    stock_quantity INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    etl_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_name VARCHAR(100) NOT NULL,
    contact_person VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    address TEXT,
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50) DEFAULT 'USA',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    etl_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fact_orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL,
    shipping_address TEXT,
    billing_address TEXT,
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    etl_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS fact_order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etl_created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    etl_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign key constraints
    FOREIGN KEY (order_id) REFERENCES fact_orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id) ON DELETE SET NULL
);

-- Add foreign key constraint for products table
ALTER TABLE dim_products 
ADD CONSTRAINT fk_products_supplier 
FOREIGN KEY (supplier_id) REFERENCES dim_suppliers(supplier_id) ON DELETE SET NULL;

-- Create indexes for better performance
CREATE INDEX idx_customers_email ON dim_customers(email);
CREATE INDEX idx_customers_created_at ON dim_customers(created_at);
CREATE INDEX idx_customers_etl_updated ON dim_customers(etl_updated_at);

CREATE INDEX idx_products_category ON dim_products(category);
CREATE INDEX idx_products_created_at ON dim_products(created_at);
CREATE INDEX idx_products_etl_updated ON dim_products(etl_updated_at);

CREATE INDEX idx_orders_customer_id ON fact_orders(customer_id);
CREATE INDEX idx_orders_order_date ON fact_orders(order_date);
CREATE INDEX idx_orders_status ON fact_orders(order_status);
CREATE INDEX idx_orders_etl_updated ON fact_orders(etl_updated_at);

CREATE INDEX idx_order_items_order_id ON fact_order_items(order_id);
CREATE INDEX idx_order_items_product_id ON fact_order_items(product_id);
CREATE INDEX idx_order_items_etl_updated ON fact_order_items(etl_updated_at);

-- Create ETL control table to track data loads
CREATE TABLE IF NOT EXISTS etl_control (
    id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    last_extract_timestamp TIMESTAMP NULL,
    last_load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    records_extracted INT DEFAULT 0,
    records_loaded INT DEFAULT 0,
    status VARCHAR(20) DEFAULT 'pending',
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_table_name (table_name)
);

-- Initialize ETL control records
INSERT INTO etl_control (table_name, status) VALUES 
('dim_customers', 'ready'),
('dim_products', 'ready'),
('dim_suppliers', 'ready'),
('fact_orders', 'ready'),
('fact_order_items', 'ready')
ON DUPLICATE KEY UPDATE status = 'ready';

-- Create aggregated tables for analytics
CREATE TABLE IF NOT EXISTS agg_monthly_sales (
    id INT AUTO_INCREMENT PRIMARY KEY,
    year_month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
    total_orders INT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0.00,
    avg_order_value DECIMAL(10,2) DEFAULT 0.00,
    unique_customers INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_year_month (year_month)
);

CREATE TABLE IF NOT EXISTS agg_product_performance (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10,2),
    total_sold INT DEFAULT 0,
    total_revenue DECIMAL(15,2) DEFAULT 0.00,
    last_order_date DATE NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_product_id (product_id),
    FOREIGN KEY (product_id) REFERENCES dim_products(product_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS agg_customer_summary (
    id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    total_orders INT DEFAULT 0,
    total_spent DECIMAL(15,2) DEFAULT 0.00,
    avg_order_value DECIMAL(10,2) DEFAULT 0.00,
    first_order_date DATE NULL,
    last_order_date DATE NULL,
    customer_lifetime_days INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    UNIQUE KEY unique_customer_id (customer_id),
    FOREIGN KEY (customer_id) REFERENCES dim_customers(customer_id) ON DELETE CASCADE
);

-- Create indexes for aggregated tables
CREATE INDEX idx_monthly_sales_year_month ON agg_monthly_sales(year_month);
CREATE INDEX idx_product_perf_category ON agg_product_performance(category);
CREATE INDEX idx_product_perf_revenue ON agg_product_performance(total_revenue);
CREATE INDEX idx_customer_summary_spent ON agg_customer_summary(total_spent);
CREATE INDEX idx_customer_summary_orders ON agg_customer_summary(total_orders);

-- Create views for easy querying
CREATE VIEW v_customer_orders AS
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email,
    o.order_id,
    o.order_date,
    o.order_status,
    o.total_amount,
    o.payment_method
FROM dim_customers c
JOIN fact_orders o ON c.customer_id = o.customer_id;

CREATE VIEW v_order_details AS
SELECT 
    o.order_id,
    o.order_date,
    o.order_status,
    c.first_name,
    c.last_name,
    c.email,
    p.product_name,
    p.category,
    oi.quantity,
    oi.unit_price,
    oi.total_price
FROM fact_orders o
JOIN dim_customers c ON o.customer_id = c.customer_id
JOIN fact_order_items oi ON o.order_id = oi.order_id
JOIN dim_products p ON oi.product_id = p.product_id;

-- Grant permissions to the target user
GRANT ALL PRIVILEGES ON targetdb.* TO 'targetuser'@'%';
FLUSH PRIVILEGES;
