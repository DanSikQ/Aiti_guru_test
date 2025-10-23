-- 1. Таблица менеджеров
CREATE TABLE dim_managers (
    manager_id SERIAL PRIMARY KEY,
    manager_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_managers IS 'Справочник менеджеров';

-- 2. Таблица команд
CREATE TABLE dim_teams (
    team_id SERIAL PRIMARY KEY,
    team_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_teams IS 'Справочник команд';
COMMENT ON COLUMN dim_teams.team_id IS 'Уникальный идентификатор команды';
COMMENT ON COLUMN dim_teams.team_name IS 'Название команды';

-- 3. Связь менеджеров и команд
CREATE TABLE bridge_team_members (
    bridge_id SERIAL PRIMARY KEY,
    team_id INTEGER NOT NULL,
    manager_id INTEGER NOT NULL,
    role VARCHAR(50) NOT NULL CHECK (role IN ('менеджер', 'руководитель команды')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, manager_id, role)
);

COMMENT ON TABLE bridge_team_members IS 'Связь менеджеров с командами и их роли';

-- 4. Таблица товаров
CREATE TABLE dim_products (
    product_id SERIAL PRIMARY KEY,
    article VARCHAR(50) NOT NULL UNIQUE,
    category VARCHAR(100) NOT NULL,
    cost NUMERIC(15,2) NOT NULL CHECK (cost >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_products IS 'Справочник товаров (номенклатура)';

-- 5. Таблица клиентов
CREATE TABLE dim_clients (
    client_id SERIAL PRIMARY KEY,
    company_name VARCHAR(200) NOT NULL,
    inn VARCHAR(12) NOT NULL,
    manager_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE dim_clients IS 'Справочник клиентов';

-- 6. Таблица заказов (корзина)
CREATE TABLE fact_orders (
    order_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    revenue NUMERIC(15,2) NOT NULL CHECK (revenue >= 0),
    margin NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (order_id, product_id)
);

COMMENT ON TABLE fact_orders IS 'Фактические заказы (корзина)';

-- 7. Таблица продаж (реализации)
CREATE TABLE fact_sales (
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    sale_date DATE NOT NULL,
    revenue NUMERIC(15,2) NOT NULL CHECK (revenue >= 0),
    margin NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (sale_id, product_id)
);

COMMENT ON TABLE fact_sales IS 'Фактические продажи (реализации)';


-- 8. Таблица возвратов
CREATE TABLE fact_returns (
    return_id SERIAL PRIMARY KEY,
    sale_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    client_id INTEGER NOT NULL,
    return_date DATE NOT NULL,
    revenue NUMERIC(15,2) NOT NULL CHECK (revenue >= 0),
    margin NUMERIC(15,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE fact_returns IS 'Корректировки реализаций (возвраты)';


-- 9. Таблица плановых показателей
CREATE TABLE fact_plans (
    plan_id SERIAL PRIMARY KEY,
    manager_id INTEGER NOT NULL,
    period DATE NOT NULL,
    plan_revenue NUMERIC(15,2) NOT NULL CHECK (plan_revenue >= 0),
    plan_margin NUMERIC(15,2) NOT NULL CHECK (plan_margin >= 0),
    plan_avg_ticket NUMERIC(15,2) NOT NULL CHECK (plan_avg_ticket >= 0),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(manager_id, period)
);

COMMENT ON TABLE fact_plans IS 'Плановые показатели по менеджерам';



-- Создание внешних ключей


-- Для bridge_team_members
ALTER TABLE bridge_team_members 
ADD CONSTRAINT fk_bridge_team 
FOREIGN KEY (team_id) REFERENCES dim_teams(team_id) ON DELETE CASCADE;

ALTER TABLE bridge_team_members 
ADD CONSTRAINT fk_bridge_manager 
FOREIGN KEY (manager_id) REFERENCES dim_managers(manager_id) ON DELETE CASCADE;

-- Для dim_clients
ALTER TABLE dim_clients 
ADD CONSTRAINT fk_client_manager 
FOREIGN KEY (manager_id) REFERENCES dim_managers(manager_id) ON DELETE RESTRICT;

-- Для fact_orders
ALTER TABLE fact_orders 
ADD CONSTRAINT fk_order_product 
FOREIGN KEY (product_id) REFERENCES dim_products(product_id) ON DELETE RESTRICT;

ALTER TABLE fact_orders 
ADD CONSTRAINT fk_order_client 
FOREIGN KEY (client_id) REFERENCES dim_clients(client_id) ON DELETE RESTRICT;

-- Для fact_sales
ALTER TABLE fact_sales 
ADD CONSTRAINT fk_sale_product 
FOREIGN KEY (product_id) REFERENCES dim_products(product_id) ON DELETE RESTRICT;

ALTER TABLE fact_sales 
ADD CONSTRAINT fk_sale_client 
FOREIGN KEY (client_id) REFERENCES dim_clients(client_id) ON DELETE RESTRICT;

-- Для fact_returns
ALTER TABLE fact_returns 
ADD CONSTRAINT fk_return_sale 
FOREIGN KEY (sale_id, product_id) REFERENCES fact_sales(sale_id, product_id) ON DELETE RESTRICT;

ALTER TABLE fact_returns 
ADD CONSTRAINT fk_return_product 
FOREIGN KEY (product_id) REFERENCES dim_products(product_id) ON DELETE RESTRICT;

ALTER TABLE fact_returns 
ADD CONSTRAINT fk_return_client 
FOREIGN KEY (client_id) REFERENCES dim_clients(client_id) ON DELETE RESTRICT;

-- Для fact_plans
ALTER TABLE fact_plans 
ADD CONSTRAINT fk_plan_manager 
FOREIGN KEY (manager_id) REFERENCES dim_managers(manager_id) ON DELETE CASCADE;