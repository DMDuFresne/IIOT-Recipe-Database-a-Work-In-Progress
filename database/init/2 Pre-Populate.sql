----------------------------------------------------------------------------------------------------
-- Insert Materials
----------------------------------------------------------------------------------------------------
INSERT INTO materials (name, type, description, uom, number_format) VALUES
('Flour', 'Raw', 'Used for making dough', 'kg', '#,##0.0'),
('Water', 'Raw', 'Used in various recipes', 'liters', '#,##0.0'),
('Yeast', 'Raw', 'Used for fermentation in dough', 'grams', '#,##0.0'),
('Salt', 'Raw', 'Used for flavoring in dough', 'grams', '#,##0.0'),
('Sugar', 'Raw', 'Used as sweetener in dough', 'grams', '#,##0.0'),
('White Dough', 'WIP', 'Intermediate product: white bread dough', 'kg', '#,##0.0'),
('Wheat Dough', 'WIP', 'Intermediate product: wheat bread dough', 'kg', '#,##0.0');

----------------------------------------------------------------------------------------------------
-- Insert Parameters
----------------------------------------------------------------------------------------------------
INSERT INTO parameters (name, uom, description, number_format) VALUES
('Batch Size', 'lbs', 'Number of batches produced in a single production run', '#,##0'),
('Mixing Time', 'minutes', 'Time to mix ingredients', '#,##0'),
('Mixing Speed', 'rpm', 'Speed setting for mixing operations', '#'),
('Proof Time', 'minutes', 'Time required for dough to rise', '#,##0');

----------------------------------------------------------------------------------------------------
-- Insert Equipment
----------------------------------------------------------------------------------------------------
INSERT INTO equipment (name, type, description) VALUES
('Mixer 1', 'Mixer', 'Used for mixing ingredients into dough'),
('Mixer 2', 'Mixer', 'Used for mixing ingredients into dough'),
('Mixer 3', 'Mixer', 'Used for mixing ingredients into dough'),
('Ingredient Doser 1', 'Doser', 'Equipment that doses measured quantities of ingredients into the mixer'),
('Ingredient Doser 2', 'Doser', 'Equipment that doses measured quantities of ingredients into the mixer'),
('Oven', 'Oven', 'Used for baking bread');

----------------------------------------------------------------------------------------------------
-- Insert Recipes and Define Product Material and Equipment
----------------------------------------------------------------------------------------------------
-- Recipe for White Dough using Mixer 1
INSERT INTO recipe_master (material_id, equipment_type) VALUES
((SELECT id FROM materials WHERE name = 'White Dough'), 'Mixer');

-- Recipe for Wheat Dough using Mixer 2
INSERT INTO recipe_master (material_id, equipment_type) VALUES
((SELECT id FROM materials WHERE name = 'Wheat Dough'), 'Mixer');

----------------------------------------------------------------------------------------------------
-- Insert Recipe Materials
----------------------------------------------------------------------------------------------------
-- Materials for White Dough
INSERT INTO recipe_materials (recipe_id, material_id, material_quantity) VALUES
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM materials WHERE name = 'Flour'), '0.5'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM materials WHERE name = 'Water'), '0.3'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM materials WHERE name = 'Yeast'), '0.01'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM materials WHERE name = 'Salt'), '0.005'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM materials WHERE name = 'Sugar'), '0.02');

-- Materials for Wheat Dough
INSERT INTO recipe_materials (recipe_id, material_id, material_quantity) VALUES
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM materials WHERE name = 'Flour'), '0.45'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM materials WHERE name = 'Water'), '0.35'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM materials WHERE name = 'Yeast'), '0.015'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM materials WHERE name = 'Salt'), '0.008');

----------------------------------------------------------------------------------------------------
-- Insert Recipe Parameters
----------------------------------------------------------------------------------------------------
-- Parameters for White Dough Recipe (e.g., Mixing time, speed, batch size, and proof time)
INSERT INTO recipe_parameters (recipe_id, parameter_id, parameter_value) VALUES
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM parameters WHERE name = 'Mixing Time'), '15'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM parameters WHERE name = 'Mixing Speed'), '60'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM parameters WHERE name = 'Batch Size'), '1'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'White Dough')), (SELECT id FROM parameters WHERE name = 'Proof Time'), '30');

-- Parameters for Wheat Dough Recipe
INSERT INTO recipe_parameters (recipe_id, parameter_id, parameter_value) VALUES
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM parameters WHERE name = 'Mixing Time'), '20'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM parameters WHERE name = 'Mixing Speed'), '80'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM parameters WHERE name = 'Batch Size'), '1'),
((SELECT id FROM recipe_master WHERE material_id = (SELECT id FROM materials WHERE name = 'Wheat Dough')), (SELECT id FROM parameters WHERE name = 'Proof Time'), '45');
