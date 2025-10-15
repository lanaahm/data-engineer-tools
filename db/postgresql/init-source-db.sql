-- PostgreSQL initialization script for source database
-- Based on: https://github.com/lanaahm/airflow-dbt-postgres/blob/main/postgresql/initdb.sql

-- PostgreSQL initialization script for source database
-- Note: Database 'sourcedb' is already created by environment variables

-- Connect to the source database (already created by POSTGRES_DB env var)
-- \c sourcedb;

-- Create schema for raw data
CREATE SCHEMA IF NOT EXISTS raw_data;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Create sample tables for ETL demonstration
CREATE TABLE IF NOT EXISTS raw_data.customers (
    customer_id SERIAL PRIMARY KEY,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_data.products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2) NOT NULL,
    cost DECIMAL(10,2),
    supplier_id INTEGER,
    description TEXT,
    stock_quantity INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_data.orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES raw_data.customers(customer_id),
    order_date DATE NOT NULL,
    order_status VARCHAR(20) DEFAULT 'pending',
    total_amount DECIMAL(12,2) NOT NULL,
    shipping_address TEXT,
    billing_address TEXT,
    payment_method VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_data.order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES raw_data.orders(order_id),
    product_id INTEGER REFERENCES raw_data.products(product_id),
    quantity INTEGER NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total_price DECIMAL(12,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS raw_data.suppliers (
    supplier_id SERIAL PRIMARY KEY,
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
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraint for products table
ALTER TABLE raw_data.products 
ADD CONSTRAINT fk_products_supplier 
FOREIGN KEY (supplier_id) REFERENCES raw_data.suppliers(supplier_id);

-- Create indexes for better performance
CREATE INDEX idx_customers_email ON raw_data.customers(email);
CREATE INDEX idx_customers_created_at ON raw_data.customers(created_at);
CREATE INDEX idx_products_category ON raw_data.products(category);
CREATE INDEX idx_products_created_at ON raw_data.products(created_at);
CREATE INDEX idx_orders_customer_id ON raw_data.orders(customer_id);
CREATE INDEX idx_orders_order_date ON raw_data.orders(order_date);
CREATE INDEX idx_orders_status ON raw_data.orders(order_status);
CREATE INDEX idx_order_items_order_id ON raw_data.order_items(order_id);
CREATE INDEX idx_order_items_product_id ON raw_data.order_items(product_id);

-- Insert sample data for testing
INSERT INTO raw_data.suppliers (supplier_name, contact_person, email, phone, address, city, state, zip_code) VALUES
('Tech Supplies Inc', 'John Smith', 'john@techsupplies.com', '555-0101', '123 Tech Street', 'San Francisco', 'CA', '94105'),
('Global Electronics', 'Sarah Johnson', 'sarah@globalelec.com', '555-0102', '456 Electronics Ave', 'Austin', 'TX', '73301'),
('Premium Components', 'Mike Wilson', 'mike@premiumcomp.com', '555-0103', '789 Component Blvd', 'Seattle', 'WA', '98101');

INSERT INTO raw_data.customers (first_name, last_name, email, phone, address, city, state, zip_code) VALUES
('Alice', 'Johnson', 'alice.johnson@email.com', '555-1001', '123 Main St', 'New York', 'NY', '10001'),
('Bob', 'Smith', 'bob.smith@email.com', '555-1002', '456 Oak Ave', 'Los Angeles', 'CA', '90210'),
('Charlie', 'Brown', 'charlie.brown@email.com', '555-1003', '789 Pine Rd', 'Chicago', 'IL', '60601'),
('Diana', 'Davis', 'diana.davis@email.com', '555-1004', '321 Elm St', 'Houston', 'TX', '77001'),
('Eve', 'Wilson', 'eve.wilson@email.com', '555-1005', '654 Maple Dr', 'Phoenix', 'AZ', '85001');

INSERT INTO raw_data.products (product_name, category, price, cost, supplier_id, description, stock_quantity) VALUES
('Laptop Pro 15"', 'Electronics', 1299.99, 899.99, 1, 'High-performance laptop with 15-inch display', 50),
('Wireless Mouse', 'Electronics', 29.99, 15.99, 1, 'Ergonomic wireless mouse with USB receiver', 200),
('Mechanical Keyboard', 'Electronics', 89.99, 49.99, 2, 'RGB backlit mechanical gaming keyboard', 75),
('USB-C Hub', 'Electronics', 49.99, 25.99, 2, '7-in-1 USB-C hub with multiple ports', 120),
('Webcam HD', 'Electronics', 79.99, 45.99, 3, '1080p HD webcam with built-in microphone', 80),
('Bluetooth Headphones', 'Electronics', 159.99, 89.99, 3, 'Noise-cancelling wireless headphones', 60);

INSERT INTO raw_data.orders (customer_id, order_date, order_status, total_amount, shipping_address, billing_address, payment_method) VALUES
(1, '2024-01-15', 'completed', 1329.98, '123 Main St, New York, NY 10001', '123 Main St, New York, NY 10001', 'credit_card'),
(2, '2024-01-16', 'completed', 119.98, '456 Oak Ave, Los Angeles, CA 90210', '456 Oak Ave, Los Angeles, CA 90210', 'paypal'),
(3, '2024-01-17', 'processing', 239.97, '789 Pine Rd, Chicago, IL 60601', '789 Pine Rd, Chicago, IL 60601', 'credit_card'),
(4, '2024-01-18', 'shipped', 49.99, '321 Elm St, Houston, TX 77001', '321 Elm St, Houston, TX 77001', 'debit_card'),
(5, '2024-01-19', 'pending', 159.99, '654 Maple Dr, Phoenix, AZ 85001', '654 Maple Dr, Phoenix, AZ 85001', 'credit_card');

INSERT INTO raw_data.order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1, 1, 1299.99, 1299.99),
(1, 2, 1, 29.99, 29.99),
(2, 3, 1, 89.99, 89.99),
(2, 2, 1, 29.99, 29.99),
(3, 4, 2, 49.99, 99.98),
(3, 5, 1, 79.99, 79.99),
(3, 6, 1, 159.99, 159.99),
(4, 4, 1, 49.99, 49.99),
(5, 6, 1, 159.99, 159.99);

-- Create views for common queries
CREATE VIEW staging.customer_orders AS
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
FROM raw_data.customers c
JOIN raw_data.orders o ON c.customer_id = o.customer_id;

CREATE VIEW analytics.monthly_sales AS
SELECT 
    DATE_TRUNC('month', order_date) as month,
    COUNT(*) as total_orders,
    SUM(total_amount) as total_revenue,
    AVG(total_amount) as avg_order_value
FROM raw_data.orders
WHERE order_status = 'completed'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;

CREATE VIEW analytics.product_performance AS
SELECT 
    p.product_id,
    p.product_name,
    p.category,
    p.price,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    COALESCE(SUM(oi.total_price), 0) as total_revenue
FROM raw_data.products p
LEFT JOIN raw_data.order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_id, p.product_name, p.category, p.price
ORDER BY total_revenue DESC;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA raw_data TO sourceuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA staging TO sourceuser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA analytics TO sourceuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA raw_data TO sourceuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA staging TO sourceuser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA analytics TO sourceuser;
