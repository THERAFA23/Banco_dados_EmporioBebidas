
-- VIEW 1: Resumo das Vendas

CREATE OR REPLACE VIEW v_resumo_vendas AS
SELECT
    v.id_venda,
    v.data_venda,
    v.horario_venda,
    c.id_cliente,
    c.nome AS cliente,
    v.tipo AS tipo_venda,
    p.id_produto,
    p.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal_item,
    v.valor_total,
    v.valor_frete,
    v.numero_retirada
FROM venda v
JOIN cliente c
    ON c.id_cliente = v.id_cliente
JOIN item_pedido ip
    ON ip.id_venda = v.id_venda
JOIN produto p
    ON p.id_produto = ip.id_produto;



-- VIEW 2: Produtos Mais Vendidos

CREATE OR REPLACE VIEW v_produtos_mais_vendidos AS
SELECT
    p.id_produto,
    p.nome AS produto,
    c.id_categoria,
    c.nome AS categoria,
    COUNT(DISTINCT ip.id_venda) AS quantidade_vendas,
    COALESCE(SUM(ip.quantidade), 0) AS unidades_vendidas,
    COALESCE(
        SUM(ip.quantidade * ip.preco_unitario),
        0
    ) AS faturamento_produto
FROM produto p
JOIN categoria c
    ON c.id_categoria = p.id_categoria
LEFT JOIN item_pedido ip
    ON ip.id_produto = p.id_produto
GROUP BY
    p.id_produto,
    p.nome,
    c.id_categoria,
    c.nome;



-- VIEW 3: Resumo dos Clientes

CREATE OR REPLACE VIEW v_resumo_clientes AS
SELECT
    c.id_cliente,
    c.nome AS cliente,
    c.cpf,
    COUNT(DISTINCT v.id_venda) AS quantidade_compras,
    COALESCE(SUM(ip.quantidade), 0) AS unidades_compradas,
    COALESCE(
        SUM(ip.quantidade * ip.preco_unitario),
        0
    ) AS total_gasto
FROM cliente c
LEFT JOIN venda v
    ON v.id_cliente = c.id_cliente
LEFT JOIN item_pedido ip
    ON ip.id_venda = v.id_venda
GROUP BY
    c.id_cliente,
    c.nome,
    c.cpf;