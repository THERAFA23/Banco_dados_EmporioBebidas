-- =====================================================================
-- 04_triggers.sql
-- Gatilho (TRIGGER) de baixa/reposição automática de estoque.
--
-- Regra de negócio automatizada:
--   Sempre que um item é vendido (linha inserida em item_pedido), o
--   estoque do produto correspondente é debitado automaticamente.
--   Ao remover ou editar itens de uma venda, o estoque é reposto/ajustado.
--   Também impede que uma venda seja registrada sem estoque suficiente.
--
-- Observação de projeto:
--   Este script é executado APÓS o povoamento (02_dml.sql). Logo, as
--   vendas do povoamento inicial NÃO passaram pelo gatilho (foram
--   inseridas antes de ele existir). O gatilho controla integralmente
--   as vendas criadas, editadas e excluídas através do sistema.
-- =====================================================================

CREATE OR REPLACE FUNCTION fn_controla_estoque()
RETURNS TRIGGER AS $$
DECLARE
    v_estoque_atual INT;
    v_nome_produto  VARCHAR(150);
BEGIN
    -- INSERÇÃO DE ITEM (nova venda) -> debita o estoque
    IF (TG_OP = 'INSERT') THEN
        SELECT quantidade_estoque, nome
          INTO v_estoque_atual, v_nome_produto
          FROM produto
         WHERE id_produto = NEW.id_produto;

        IF v_estoque_atual < NEW.quantidade THEN
            RAISE EXCEPTION
                'Estoque insuficiente para o produto "%" (disponivel: %, solicitado: %).',
                v_nome_produto, v_estoque_atual, NEW.quantidade;
        END IF;

        UPDATE produto
           SET quantidade_estoque = quantidade_estoque - NEW.quantidade
         WHERE id_produto = NEW.id_produto;

        RETURN NEW;

    -- REMOÇÃO DE ITEM (exclusão/edição de venda) -> repõe o estoque
    ELSIF (TG_OP = 'DELETE') THEN
        UPDATE produto
           SET quantidade_estoque = quantidade_estoque + OLD.quantidade
         WHERE id_produto = OLD.id_produto;

        RETURN OLD;

    -- ALTERAÇÃO DE ITEM -> repõe a quantidade antiga e debita a nova
    ELSIF (TG_OP = 'UPDATE') THEN
        -- devolve ao estoque o que havia sido debitado pelo item antigo
        UPDATE produto
           SET quantidade_estoque = quantidade_estoque + OLD.quantidade
         WHERE id_produto = OLD.id_produto;

        SELECT quantidade_estoque, nome
          INTO v_estoque_atual, v_nome_produto
          FROM produto
         WHERE id_produto = NEW.id_produto;

        IF v_estoque_atual < NEW.quantidade THEN
            RAISE EXCEPTION
                'Estoque insuficiente para o produto "%" (disponivel: %, solicitado: %).',
                v_nome_produto, v_estoque_atual, NEW.quantidade;
        END IF;

        UPDATE produto
           SET quantidade_estoque = quantidade_estoque - NEW.quantidade
         WHERE id_produto = NEW.id_produto;

        RETURN NEW;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;


DROP TRIGGER IF EXISTS trg_controla_estoque ON item_pedido;

CREATE TRIGGER trg_controla_estoque
AFTER INSERT OR UPDATE OR DELETE ON item_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_controla_estoque();
