DO NOT USE THIS IS A IN DEVELOPMENT STILL AND WILL BE FOR A WHILE.

ALTER TABLE `anpr_cameras` ADD COLUMN `model` varchar(50) DEFAULT 'prop_cctv_cam_01a';

-- Add item_type column to track which ANPR item was used to deploy the camera
ALTER TABLE `anpr_cameras` ADD COLUMN `item_type` varchar(50) DEFAULT 'anpr_camera';

-- Update existing cameras to have default values (optional, but recommended)
UPDATE `anpr_cameras` SET `model` = 'prop_cctv_cam_01a', `item_type` = 'anpr_camera' WHERE `model` IS NULL OR `item_type` IS NULL;
