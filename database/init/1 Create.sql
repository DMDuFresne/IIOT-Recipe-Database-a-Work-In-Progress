----------------------------------------------------------------------------------------------------
-- Add Extensions
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
-- Create Tables
----------------------------------------------------------------------------------------------------

CREATE TABLE materials (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    uom VARCHAR(50) NOT NULL,
    number_format VARCHAR(50) DEFAULT '#,##0.0'
);

CREATE TABLE parameters (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    uom VARCHAR(50) NOT NULL,
    number_format VARCHAR(50) DEFAULT '#,##0.0'
);

CREATE TABLE equipment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    description TEXT
);

CREATE TABLE recipe_master (
    id SERIAL PRIMARY KEY,
    material_id INT NOT NULL REFERENCES materials(id),
    equipment_type VARCHAR(50) NOT NULL
);

CREATE TABLE recipe_materials (
    recipe_id INT NOT NULL,
    material_id INT NOT NULL,
    material_quantity NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (recipe_id, material_id),
    FOREIGN KEY (recipe_id) REFERENCES recipe_master(id),
    FOREIGN KEY (material_id) REFERENCES materials(id)
);

CREATE TABLE recipe_parameters (
    recipe_id INT NOT NULL,
    parameter_id INT NOT NULL,
    parameter_value NUMERIC(10,2) NOT NULL,
    PRIMARY KEY (recipe_id, parameter_id),
    FOREIGN KEY (recipe_id) REFERENCES recipe_master(id),
    FOREIGN KEY (parameter_id) REFERENCES parameters(id)
);

----------------------------------------------------------------------------------------------------
-- Create Views
----------------------------------------------------------------------------------------------------

-- View Recipe Details
CREATE OR REPLACE VIEW view_recipe_details AS
 SELECT r.id AS recipe_id,
    m.name AS product_material,
    r.equipment_type,
    'Material'::text AS field_type,
    rm.material_id AS field_id,
    mat.name AS field_name,
    rm.material_quantity AS field_value,
    mat.uom,
    mat.number_format
   FROM recipe_master r
     JOIN materials m ON r.material_id = m.id
     JOIN recipe_materials rm ON r.id = rm.recipe_id
     JOIN materials mat ON rm.material_id = mat.id
UNION ALL
 SELECT r.id AS recipe_id,
    m.name AS product_material,
    r.equipment_type,
    'Parameter'::text AS field_type,
    p.id AS field_id,
    p.name AS field_name,
    rp.parameter_value AS field_value,
    p.uom,
    p.number_format
   FROM recipe_master r
     JOIN materials m ON r.material_id = m.id
     JOIN recipe_parameters rp ON r.id = rp.recipe_id
     JOIN parameters p ON rp.parameter_id = p.id;

----------------------------------------------------------------------------------------------------
-- Create Indexes
----------------------------------------------------------------------------------------------------

-- Foreign key indexes
CREATE INDEX idx_recipe_master_material_id ON recipe_master(material_id);
CREATE INDEX idx_recipe_materials_recipe_id ON recipe_materials(recipe_id);
CREATE INDEX idx_recipe_materials_material_id ON recipe_materials(material_id);
CREATE INDEX idx_recipe_parameters_recipe_id ON recipe_parameters(recipe_id);
CREATE INDEX idx_recipe_parameters_parameter_id ON recipe_parameters(parameter_id);

-- Indexes on commonly queried columns
CREATE INDEX idx_materials_type ON materials(type);
CREATE INDEX idx_parameters_name ON parameters(name);
CREATE INDEX idx_equipment_type ON equipment(type);

----------------------------------------------------------------------------------------------------
-- Create Audit Tables and Schema
----------------------------------------------------------------------------------------------------

CREATE SCHEMA audit;

CREATE TABLE audit.audit_materials (
    audit_id SERIAL PRIMARY KEY,
    operation_type CHAR(1),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_username VARCHAR(255) DEFAULT CURRENT_USER,
    material_id INT,
    material_name VARCHAR(255),
    description TEXT,
    material_type VARCHAR(50),
    uom VARCHAR(50),
    number_format VARCHAR(50)
);

CREATE TABLE audit.audit_parameters (
    audit_id SERIAL PRIMARY KEY,
    operation_type CHAR(1),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_username VARCHAR(255) DEFAULT CURRENT_USER,
    parameter_id INT,
    parameter_name VARCHAR(255),
    description TEXT,
    uom VARCHAR(50),
    number_format VARCHAR(50)
);

CREATE TABLE audit.audit_equipment (
    audit_id SERIAL PRIMARY KEY,
    operation_type CHAR(1),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_username VARCHAR(255) DEFAULT CURRENT_USER,
    equipment_id INT,
    equipment_name VARCHAR(255),
    equipment_type VARCHAR(50),
    description TEXT
);

CREATE TABLE audit.audit_recipe_master (
    audit_id SERIAL PRIMARY KEY,
    operation_type CHAR(1),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_username VARCHAR(255) DEFAULT CURRENT_USER,
    recipe_id INT,
    material_id INT,
    equipment_type VARCHAR(50)
);

CREATE TABLE audit.audit_recipe_materials (
    audit_id SERIAL PRIMARY KEY,
    operation_type CHAR(1),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_username VARCHAR(255) DEFAULT CURRENT_USER,
    recipe_id INT,
    material_id INT,
    material_quantity NUMERIC(10,2)
);

CREATE TABLE audit.audit_recipe_parameters (
    audit_id SERIAL PRIMARY KEY,
    operation_type CHAR(1),
    operation_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operator_username VARCHAR(255) DEFAULT CURRENT_USER,
    recipe_id INT,
    parameter_id INT,
    parameter_value NUMERIC(10,2)
);

----------------------------------------------------------------------------------------------------
-- Trigger Functions and Triggers
----------------------------------------------------------------------------------------------------

-- Trigger Functions and Triggers for Auditing All Tables

-- Materials
CREATE OR REPLACE FUNCTION audit_material_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.audit_materials(
            operation_type, material_id, material_name, material_type, description, uom, number_format, operator_username)
        VALUES ('I', NEW.id, NEW.name, NEW.type, NEW.description, NEW.uom, NEW.number_format, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_materials(
            operation_type, material_id, material_name, material_type, description, uom, number_format, operator_username)
        VALUES ('U', NEW.id, NEW.name, NEW.type, NEW.description, NEW.uom, NEW.number_format, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_materials(
            operation_type, material_id, material_name, material_type, description, uom, number_format, operator_username)
        VALUES ('D', OLD.id, OLD.name, OLD.type, OLD.description, OLD.uom, OLD.number_format, current_user);
    END IF;
    PERFORM pg_notify('audit_notifications', 'materials:' || TG_OP || ':' || COALESCE(NEW.id::text, OLD.id::text));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_material_changes
AFTER INSERT OR UPDATE OR DELETE ON materials
FOR EACH ROW EXECUTE PROCEDURE audit_material_changes();

-- Parameters
CREATE OR REPLACE FUNCTION audit_parameter_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.audit_parameters(
            operation_type, parameter_id, parameter_name, description, uom, number_format, operator_username)
        VALUES ('I', NEW.id, NEW.name, NEW.description, NEW.uom, NEW.number_format, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_parameters(
            operation_type, parameter_id, parameter_name, description, uom, number_format, operator_username)
        VALUES ('U', NEW.id, NEW.name, NEW.description, NEW.uom, NEW.number_format, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_parameters(
            operation_type, parameter_id, parameter_name, description, uom, number_format, operator_username)
        VALUES ('D', OLD.id, OLD.name, OLD.description, OLD.uom, OLD.number_format, current_user);
    END IF;
    PERFORM pg_notify('audit_notifications', 'parameters:' || TG_OP || ':' || COALESCE(NEW.id::text, OLD.id::text));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_parameter_changes
AFTER INSERT OR UPDATE OR DELETE ON parameters
FOR EACH ROW EXECUTE PROCEDURE audit_parameter_changes();

-- Equipment
CREATE OR REPLACE FUNCTION audit_equipment_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.audit_equipment(
            operation_type, equipment_id, equipment_name, equipment_type, description, operator_username)
        VALUES ('I', NEW.id, NEW.name, NEW.type, NEW.description, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_equipment(
            operation_type, equipment_id, equipment_name, equipment_type, description, operator_username)
        VALUES ('U', NEW.id, NEW.name, NEW.type, NEW.description, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_equipment(
            operation_type, equipment_id, equipment_name, equipment_type, description, operator_username)
        VALUES ('D', OLD.id, OLD.name, OLD.type, OLD.description, current_user);
    END IF;
    PERFORM pg_notify('audit_notifications', 'equipment:' || TG_OP || ':' || COALESCE(NEW.id::text, OLD.id::text));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_equipment_changes
AFTER INSERT OR UPDATE OR DELETE ON equipment
FOR EACH ROW EXECUTE PROCEDURE audit_equipment_changes();

-- Recipe Master
CREATE OR REPLACE FUNCTION audit_recipe_master_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.audit_recipe_master(
            operation_type, recipe_id, material_id, equipment_type, operator_username)
        VALUES ('I', NEW.id, NEW.material_id, NEW.equipment_type, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_recipe_master(
            operation_type, recipe_id, material_id, equipment_type, operator_username)
        VALUES ('U', NEW.id, NEW.material_id, NEW.equipment_type, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_recipe_master(
            operation_type, recipe_id, material_id, equipment_type, operator_username)
        VALUES ('D', OLD.id, OLD.material_id, OLD.equipment_type, current_user);
    END IF;
    PERFORM pg_notify('audit_notifications', 'recipe_master:' || TG_OP || ':' || COALESCE(NEW.id::text, OLD.id::text));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_recipe_master_changes
AFTER INSERT OR UPDATE OR DELETE ON recipe_master
FOR EACH ROW EXECUTE PROCEDURE audit_recipe_master_changes();

-- Recipe Materials
CREATE OR REPLACE FUNCTION audit_recipe_materials_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.audit_recipe_materials(
            operation_type, recipe_id, material_id, material_quantity, operator_username)
        VALUES ('I', NEW.recipe_id, NEW.material_id, NEW.material_quantity, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_recipe_materials(
            operation_type, recipe_id, material_id, material_quantity, operator_username)
        VALUES ('U', NEW.recipe_id, NEW.material_id, NEW.material_quantity, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_recipe_materials(
            operation_type, recipe_id, material_id, material_quantity, operator_username)
        VALUES ('D', OLD.recipe_id, OLD.material_id, OLD.material_quantity, current_user);
    END IF;
    PERFORM pg_notify('audit_notifications', 'recipe_materials:' || TG_OP || ':' || COALESCE(NEW.recipe_id::text, OLD.recipe_id::text));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_recipe_materials_changes
AFTER INSERT OR UPDATE OR DELETE ON recipe_materials
FOR EACH ROW EXECUTE PROCEDURE audit_recipe_materials_changes();

-- Recipe Parameters
CREATE OR REPLACE FUNCTION audit_recipe_parameters_changes()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        INSERT INTO audit.audit_recipe_parameters(
            operation_type, recipe_id, parameter_id, parameter_value, operator_username)
        VALUES ('I', NEW.recipe_id, NEW.parameter_id, NEW.parameter_value, current_user);
    ELSIF TG_OP = 'UPDATE' THEN
        INSERT INTO audit.audit_recipe_parameters(
            operation_type, recipe_id, parameter_id, parameter_value, operator_username)
        VALUES ('U', NEW.recipe_id, NEW.parameter_id, NEW.parameter_value, current_user);
    ELSIF TG_OP = 'DELETE' THEN
        INSERT INTO audit.audit_recipe_parameters(
            operation_type, recipe_id, parameter_id, parameter_value, operator_username)
        VALUES ('D', OLD.recipe_id, OLD.parameter_id, OLD.parameter_value, current_user);
    END IF;
    PERFORM pg_notify('audit_notifications', 'recipe_parameters:' || TG_OP || ':' || COALESCE(NEW.recipe_id::text, OLD.recipe_id::text));
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_recipe_parameters_changes
AFTER INSERT OR UPDATE OR DELETE ON recipe_parameters
FOR EACH ROW EXECUTE PROCEDURE audit_recipe_parameters_changes();

----------------------------------------------------------------------------------------------------
-- General Functions
----------------------------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION insert_recipe(data JSON)
RETURNS TEXT AS $$
DECLARE
    v_recipe_id INTEGER;
    v_material JSON;
    v_parameter JSON;
BEGIN
    -- Insert into recipe_master and capture the newly inserted recipe ID
    INSERT INTO recipe_master (material_id, equipment_type)
    VALUES ((data->>'outputMaterial_id')::INT, (data->>'equipmentType')::VARCHAR)
    RETURNING id INTO v_recipe_id;

    -- Debugging output
    RAISE NOTICE 'Recipe ID: %', v_recipe_id;

    -- Loop through each material in the JSON array
    FOR v_material IN SELECT * FROM json_array_elements(data->'material') LOOP
        RAISE NOTICE 'Material ID: %, Quantity: %', (v_material->>'id')::INT, (v_material->>'quantity')::NUMERIC;
        INSERT INTO recipe_materials (recipe_id, material_id, material_quantity)
        VALUES (v_recipe_id, (v_material->>'id')::INT, (v_material->>'quantity')::NUMERIC);
    END LOOP;

    -- Loop through each parameter in the JSON array
    FOR v_parameter IN SELECT * FROM json_array_elements(data->'parameters') LOOP
        RAISE NOTICE 'Parameter ID: %, Value: %', (v_parameter->>'id')::INT, (v_parameter->>'quantity')::NUMERIC;
        INSERT INTO recipe_parameters (recipe_id, parameter_id, parameter_value)
        VALUES (v_recipe_id, (v_parameter->>'id')::INT, (v_parameter->>'quantity')::NUMERIC);
    END LOOP;

    -- Return the new recipe ID as text
    RETURN v_recipe_id::TEXT;

EXCEPTION
    WHEN OTHERS THEN
        -- Return the error message as text
        RETURN 'Error occurred: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION delete_recipe(input_recipe_id INT)
RETURNS TEXT AS $$
BEGIN
    -- Attempt to delete entries from recipe_materials
    DELETE FROM recipe_materials WHERE recipe_id = input_recipe_id;
    RAISE NOTICE 'Deleted materials for recipe ID: %', input_recipe_id;

    -- Attempt to delete entries from recipe_parameters
    DELETE FROM recipe_parameters WHERE recipe_id = input_recipe_id;
    RAISE NOTICE 'Deleted parameters for recipe ID: %', input_recipe_id;

    -- Finally, delete the recipe from recipe_master
    DELETE FROM recipe_master WHERE id = input_recipe_id;
    RAISE NOTICE 'Deleted recipe from master table with ID: %', input_recipe_id;

    -- Return a success message
    RETURN 'Recipe deleted successfully.';

EXCEPTION
    WHEN OTHERS THEN
        -- In case of error, roll back any partial changes and report error
        RETURN 'Error occurred during deletion: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_recipe_material(p_recipe_id INT, p_material_id INT, p_quantity NUMERIC)
RETURNS TEXT AS $$
BEGIN
    -- Check if the material already exists for the recipe
    IF EXISTS (
        SELECT 1 FROM recipe_materials
        WHERE recipe_id = p_recipe_id AND material_id = p_material_id
    ) THEN
        RETURN 'Material already exists for this recipe.';
    ELSE
        -- Insert new material into the recipe
        INSERT INTO recipe_materials (recipe_id, material_id, material_quantity)
        VALUES (p_recipe_id, p_material_id, p_quantity);
        RETURN 'Material added successfully.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error occurred: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION add_recipe_parameter(p_recipe_id INT, p_parameter_id INT, p_value NUMERIC)
RETURNS TEXT AS $$
BEGIN
    -- Check if the parameter already exists for the recipe
    IF EXISTS (
        SELECT 1 FROM recipe_parameters
        WHERE recipe_id = p_recipe_id AND parameter_id = p_parameter_id
    ) THEN
        RETURN 'Parameter already exists for this recipe.';
    ELSE
        -- Insert new parameter into the recipe
        INSERT INTO recipe_parameters (recipe_id, parameter_id, parameter_value)
        VALUES (p_recipe_id, p_parameter_id, p_value);
        RETURN 'Parameter added successfully.';
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'Error occurred: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;
