-- ANPR System Database Tables

-- Table for ANPR cameras
CREATE TABLE IF NOT EXISTS `anpr_cameras` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `x` float NOT NULL,
    `y` float NOT NULL,
    `z` float NOT NULL,
    `heading` float NOT NULL DEFAULT 0.0,
    `deployed_by` varchar(50) NOT NULL,
    `deployed_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `deployed_by` (`deployed_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table for flagged vehicles
CREATE TABLE IF NOT EXISTS `anpr_flagged_vehicles` (
    `plate` varchar(8) NOT NULL,
    `reason` varchar(255) NOT NULL,
    `priority` int(1) NOT NULL DEFAULT 1,
    `flagged_by` varchar(50) NOT NULL,
    `date_added` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `notes` text DEFAULT NULL,
    PRIMARY KEY (`plate`),
    KEY `flagged_by` (`flagged_by`),
    KEY `priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table for ANPR detections (log)
CREATE TABLE IF NOT EXISTS `anpr_detections` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `plate` varchar(8) NOT NULL,
    `camera_id` int(11) NOT NULL,
    `coords` text NOT NULL,
    `reason` varchar(255) DEFAULT NULL,
    `priority` int(1) DEFAULT NULL,
    `detection_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `plate` (`plate`),
    KEY `camera_id` (`camera_id`),
    KEY `detection_time` (`detection_time`),
    KEY `priority` (`priority`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table for ANPR system logs
CREATE TABLE IF NOT EXISTS `anpr_logs` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `action` varchar(50) NOT NULL,
    `plate` varchar(8) DEFAULT NULL,
    `officer_id` varchar(50) NOT NULL,
    `details` text DEFAULT NULL,
    `timestamp` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `action` (`action`),
    KEY `officer_id` (`officer_id`),
    KEY `timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;