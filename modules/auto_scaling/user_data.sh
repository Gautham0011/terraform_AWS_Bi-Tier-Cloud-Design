#!/bin/bash

yum install -y httpd
systemctl enable httpd
systemctl start httpd

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AVAILABILITY_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
INSTANCE_TYPE=$(curl -s http://169.254.169.254/latest/meta-data/instance-type)
IPV=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
IPVV=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)


cat > /var/www/html/index.html <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Server Status</title>
    <style>
        body { 
            font-family: Arial, sans-serif; 
            margin: 40px; 
            background-color: #f5f5f5;
        }
        h1 { 
            color: #333; 
            text-align: center;
            background: linear-gradient(45deg, #2196F3, #21CBF3);
            color: white;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 30px;
        }
        .db-section { 
            margin: 20px 0; 
            padding: 20px; 
            border: 2px solid #ddd; 
            border-radius: 8px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        .primary { 
            background: linear-gradient(135deg, #e8f5e8, #c8e6c9); 
            border-color: #4caf50;
        }
        .replica { 
            background: linear-gradient(135deg, #fff3e0, #ffcc80); 
            border-color: #ff9800;
        }
        .db-section h3 {
            margin-top: 0;
            color: #333;
            font-size: 20px;
        }
        .db-section p {
            margin: 10px 0;
            font-size: 16px;
        }
        .primary h3 {
            color: #2e7d32;
        }
        .replica h3 {
            color: #f57c00;
        }
        .status-indicator {
            display: inline-block;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            margin-right: 8px;
            animation: pulse 2s infinite;
        }
        .online { background-color: #4caf50; }
        .standby { background-color: #ff9800; }
        
        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.5; }
        }
    </style>
</head>
<body>
    <h1>Web Server DB status</h1>
    <p><strong>Instance ID:</strong> <span class="metadata-value"> $INSTANCE_ID</span></p>
    <p><strong>Availability Zone:</strong> <span class="metadata-value"> $AVAILABILITY_ZONE</span></p>
    <p><strong>Region:</strong> <span class="metadata-value"> $REGION</span></p>
    <p><strong>Priavte Ipv4 :</strong> <span class="metadata-value"> $IPV</span></p>
    <p><strong>Public Ipv4 :</strong> <span class="metadata-value"> $IPVV</span></p>
    <p><strong>Instance Type:</strong> <span class="metadata-value"> $INSTANCE_TYPE</span></p>
    <p><strong>Web Server Port running Apache:</strong> <span class="metadata-value">${server_port}</span></p>  
    
    <div class="db-section primary">
        <h3><span class="status-indicator online"></span>Primary Database</h3>
        <p><strong>Database Name:</strong> ${db_name}</p>
        <p><strong>DB Endpoint:</strong> ${db_endpoint}</p>
        <p><strong>DB Port:</strong> ${db_port}</p>
        <p><strong>DB AZ:</strong> ${db_az}</p>
        <p><strong>Status:</strong> Online</p>
    </div>
    
    <div class="db-section replica">
        <h3><span class="status-indicator standby"></span>Replica Database</h3>
        <p><strong>Replica Database Name:</strong> ${replica_name}</p>
        <p><strong>DB Address:</strong> ${replica_address}</p>
        <p><strong>DB Port:</strong> ${replica_port}</p>
        <p><strong>DB AZ:</strong> ${replica_az}</p>
        <p><strong>Status:</strong> Standby</p>
    </div>

    <div style="text-align: center; margin-top: 30px; color: #666; font-size: 14px;">
        <p>Web server http:${server_port} | Last updated: <span id="timestamp"></span></p>
    </div>

    <script>
        // Add current timestamp
        document.getElementById('timestamp').textContent = new Date().toLocaleString();
        
        // Simple auto-refresh every 30 seconds
        setTimeout(() => {
            location.reload();
        }, 30000);
    </script>
</body>
</html>
EOF