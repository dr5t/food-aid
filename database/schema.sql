


CREATE TABLE users (
    uid VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role ENUM('donor', 'ngo', 'logisticsCompany', 'logisticsEmployee') NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE donations (
    id VARCHAR(255) PRIMARY KEY,
    donor_id VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    food_type VARCHAR(50),
    quantity INT,
    status ENUM('pending', 'accepted', 'picked', 'inTransit', 'delivered', 'cancelled') DEFAULT 'pending',
    pickup_address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (donor_id) REFERENCES users(uid)
);


CREATE TABLE emergency_requests (
    id VARCHAR(255) PRIMARY KEY,
    ngo_id VARCHAR(255),
    meal_type VARCHAR(50),
    quantity INT,
    status ENUM('open', 'donorAccepted', 'assigned', 'picked', 'delivered', 'cancelled') DEFAULT 'open',
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ngo_id) REFERENCES users(uid)
);
